# Troubleshooting Notes

이 문서는 이번 Sprint 1 작업 중 실제로 막혔던 문제를 빠르게 파악하기 위한 메모입니다.

진행 경과 전체는 [VALIDATION_HISTORY.ko.md](VALIDATION_HISTORY.ko.md)에서, 인프라 쪽 상세 장애 흐름은 `multipass-k8s-lab/docs/TROUBLESHOOTING_HISTORY.ko.md`에서 함께 보는 편이 좋습니다.

## 1. `multipass-k8s-lab` 3-node bring-up 이 처음 실패한 이유

증상:
- `scripts/k8s-tool.sh up` 가 초기에 정상적으로 끝나지 않음
- VM/cluster 준비가 중간에 멈춘 것처럼 보였음

실제 원인:
- 초기에 쓰던 guest/image baseline 이 현재 Multipass 환경과 맞지 않았음
- `rocky-8` alias 기반 접근이 그대로는 안정적으로 동작하지 않았음

정리:
- lab baseline 을 Ubuntu 24.04 쪽으로 맞춘 뒤 VM bring-up 자체는 진행 가능해졌음

## 2. control plane 이 흔들린 핵심 원인

증상:
- `kube-apiserver` 가 계속 죽고 `6443` 이 자주 refused
- `etcd` / `apiserver` static pod 가 계속 다시 만들어짐
- node 는 보이지만 `NotReady` 였음

처음 의심했던 것:
- `kubelet=systemd`, live CRI=`systemdCgroup=false` 불일치

실제로 확인된 것:
- 이 환경의 `containerd` 는 `1.7.28`
- runtime 은 `io.containerd.runc.v2`
- 이 조합에서는 top-level `systemd_cgroup=true` 로 강제 변경하면 오히려 CRI plugin 이 깨질 수 있음
- 실제로 중요한 값은 `runc.options.SystemdCgroup = true`

핵심 포인트:
- `crictl info` 의 top-level `systemdCgroup=false` 만 보고 바로 수정하면 안 됨
- live runtime option 과 CRI plugin 정상 동작 여부를 같이 봐야 함

## 3. 왜 cluster 가 회복됐는가

실제 회복 경로:
- invalid top-level containerd 변경을 되돌림
- `containerd` 재시작
- `kubelet` 재시작
- 이후 control plane static pod 가 안정화됨
- flannel/CNI 도 다시 올라오면서 3-node 모두 `Ready`

확인 기준:
- `kubectl get nodes`
- `crictl info`
- `ss -lntp | egrep '6443|2379|2380|10257|10259'`

## 4. cross-node 검증에서 확인된 결과

성공한 시나리오:
- parent on `lab-worker-0`
- child on `lab-worker-1`
- child 결과 `source=peer-fetch`
- digest 일치
- catalog 에 producer/replica node 정보 저장 확인

즉:
- same-node reuse 뿐 아니라 cross-node peer fetch 까지 실제 lab 에서 성립함

## 5. 다시 막히면 가장 먼저 볼 것

1. `kubectl get nodes -o wide`
2. `sudo crictl info`
3. `sudo systemctl show -p ExecStart containerd`
4. `/etc/containerd/config.toml` 의 `runc.options.SystemdCgroup`
5. flannel/CNI pod 상태

## 6. 오해하면 안 되는 포인트

- `top-level systemdCgroup=false` 가 보인다고 해서 바로 잘못된 것은 아님
- 이 환경에서는 `runc.options.SystemdCgroup = true` 와 CRI/plugin 정상 상태가 더 중요했음
- 이번 Sprint 목표는 production-grade 완성도가 아니라, lab 위에서 artifact handoff 구조가 실제로 성립하는지 확인하는 것임
