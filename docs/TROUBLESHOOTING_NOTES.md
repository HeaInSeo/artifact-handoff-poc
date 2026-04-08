# Troubleshooting Notes

This note exists to quickly summarize the problems that blocked the Sprint 1 validation work.

For the full validation timeline, see [VALIDATION_HISTORY.md](VALIDATION_HISTORY.md). For infrastructure-side incident details, see `multipass-k8s-lab/docs/TROUBLESHOOTING_HISTORY.md`.

## 1. Why The Initial `multipass-k8s-lab` 3-Node Bring-Up Failed

Symptoms:
- `scripts/k8s-tool.sh up` did not complete successfully at first.
- The VM and cluster setup appeared to stop partway through.

Actual cause:
- The original guest/image baseline was not a good fit for the current Multipass environment.
- The `rocky-8` alias based path was not stable enough as-is.

Summary:
- Once the lab baseline was moved to Ubuntu 24.04, VM bring-up itself became workable again.

## 2. What Actually Destabilized The Control Plane

Symptoms:
- `kube-apiserver` kept dying and port `6443` often refused connections.
- The `etcd` and `kube-apiserver` static pods were recreated repeatedly.
- Nodes were visible, but stayed `NotReady`.

What looked suspicious at first:
- a mismatch between `kubelet=systemd` and live CRI output showing `systemdCgroup=false`

What was actually confirmed:
- `containerd` in this environment was `1.7.28`.
- The runtime was `io.containerd.runc.v2`.
- In this combination, forcing top-level `systemd_cgroup=true` could actually break the CRI plugin.
- The value that mattered more was `runc.options.SystemdCgroup = true`.

Key point:
- Do not change the setup just because `crictl info` shows top-level `systemdCgroup=false`.
- You have to look at the live runtime option and whether the CRI plugin is still healthy.

## 3. Why The Cluster Recovered

Actual recovery path:
- The invalid top-level `containerd` change was reverted.
- `containerd` was restarted.
- `kubelet` was restarted.
- After that, the control-plane static pods stabilized.
- Flannel/CNI came back and all three nodes returned to `Ready`.

Verification points:
- `kubectl get nodes`
- `crictl info`
- `ss -lntp | egrep '6443|2379|2380|10257|10259'`

## 4. What The Cross-Node Validation Confirmed

Successful scenario:
- parent on `lab-worker-0`
- child on `lab-worker-1`
- child result `source=peer-fetch`
- digest matched
- the catalog recorded producer and replica node information

So the result was:
- not only same-node reuse, but also cross-node peer fetch, worked in the actual lab.

## 5. What To Check First If It Breaks Again

1. `kubectl get nodes -o wide`
2. `sudo crictl info`
3. `sudo systemctl show -p ExecStart containerd`
4. `runc.options.SystemdCgroup` in `/etc/containerd/config.toml`
5. flannel/CNI pod status

## 6. Easy Misreads To Avoid

- Seeing `top-level systemdCgroup=false` does not automatically mean the setup is wrong.
- In this environment, `runc.options.SystemdCgroup = true` and a healthy CRI/plugin path mattered more.
- The point of this sprint was not production hardening. It was to confirm that the artifact handoff flow actually works on the lab cluster.
