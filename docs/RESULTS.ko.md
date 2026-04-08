# RESULTS

## 요약

이 문서는 Sprint 1에 대한 실제 검증 결과를 기록합니다.

중요:

- 아래 결과는 `2026-04-03`과 `2026-04-04`에 수집된 실행 기록을 기준으로 정리한 것입니다.
- `2026-04-06`에는 `multipass-k8s-lab` 랩에서 same-node, cross-node, second-hit를 최신 코드 기준으로 다시 실행했습니다.
- 따라서 이 문서는 초기 실행 기록과 `2026-04-06` 재검증 결과를 함께 담습니다.

## 환경

- 랩 저장소: `../multipass-k8s-lab`
- 기대 클러스터 형태: `1 control-plane + 2 workers`
- PoC 네임스페이스: `artifact-handoff`

## 관찰된 상태

- `2026-04-03`: `multipass-k8s-lab/scripts/k8s-tool.sh status` 초기 확인 시 `k8s-master-0`만 실행 중이었습니다.
- `2026-04-03`: `multipass-k8s-lab/scripts/k8s-tool.sh up`는 설정된 이미지 별칭 `rocky-8`을 Multipass가 해석하지 못해 3노드 bring-up 전에 실패했습니다.
- `2026-04-03`: 남아 있던 단일 노드 클러스터에서 부분 검증을 진행하기 위해 기존 `k8s-master-0` VM에서 kubeconfig를 직접 내보냈습니다.
- `2026-04-03`: 그 단일 노드 클러스터에 `artifact-handoff` 네임스페이스로 PoC 베이스라인을 성공적으로 배포했습니다.
- `2026-04-04`: 랩 베이스라인을 Ubuntu 24.04로 전환하고 worker join/runtime 문제를 정리한 뒤, 의도한 `1 control-plane + 2 workers` 클러스터가 다시 준비되었습니다.
- `2026-04-04`: 회복된 3노드 랩에서 cross-node 검증이 성공했습니다.

## Same-Node Reuse

- 상태: `2026-04-03` 기록 기준 통과
- Parent job `parent-same-node`가 `demo-artifact`를 등록
- Child job `child-same-node`가 성공적으로 완료
- 관찰된 child 출력:
  - payload: `artifact-handoff sprint1 sample payload`
  - source: `local`
  - digest: `d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1`
- 실행 후 catalog 내용:
  - `artifactId`: `demo-artifact`
  - `producerNode`: `k8s-master-0`
  - `producerAddress`: `http://10.87.127.29:8080`
  - `state`: 당시 기록은 `ready`
  - `replicaNodes`: `[]`

현재 코드 기준 해석:

- 최신 코드에서는 parent 등록 시 catalog top-level state를 `produced`로 다룹니다.
- same-node child placement는 parent 완료 후 catalog에서 `producerNode`를 읽는 스크립트가 보조합니다.
- 즉 same-node 흐름은 여전히 shell script가 시나리오를 조직하지만, placement 입력은 이전보다 metadata-driven 에 가깝습니다.

`2026-04-06` 재검증:

- fresh artifact id: `demo-artifact-20260406-same`
- parent on `lab-worker-0`
- child 결과 `source=local`
- digest 일치
- parent job 응답 local metadata:
  - `producerNode`: `lab-worker-0`
  - `producerAddress`: `http://10.87.127.94:8080`
  - `localNode`: `lab-worker-0`
  - `localAddress`: `http://10.87.127.94:8080`
  - `state`: `available-local`
- catalog record:
  - `artifactId`: `demo-artifact-20260406-same`
  - `producerNode`: `lab-worker-0`
  - `producerAddress`: `http://10.87.127.94:8080`
  - `state`: `produced`
  - `replicaNodes`: `[]`

로그 스냅샷:

```text
== parent log ==
{
  "artifactId": "demo-artifact-20260406-same",
  "digest": "d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1",
  "localAddress": "http://10.87.127.94:8080",
  "localNode": "lab-worker-0",
  "localPath": "/var/lib/artifact-handoff/demo-artifact-20260406-same/payload.bin",
  "producerAddress": "http://10.87.127.94:8080",
  "producerNode": "lab-worker-0",
  "size": 40,
  "source": "local-put",
  "state": "available-local"
}

== child log ==
artifact-handoff sprint1 sample payload
source=local
digest=d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1
```

## Cross-Node Peer Fetch

- `2026-04-03` 상태: 랩 준비 상태에 의해 차단됨
- `2026-04-03` 실제 스크립트 결과: `need at least two schedulable nodes for cross-node validation`
- `2026-04-04` 상태: 랩 회복 후 통과
- 성공한 시나리오:
  - parent on `lab-worker-0`
  - child on `lab-worker-1`
  - child 결과 `source=peer-fetch`
  - digest 일치
  - catalog 에 producer / replica node 정보 반영

현재 코드 기준 해석:

- 최신 스크립트는 parent 완료 후 catalog에서 `producerNode`를 읽고, 그 node와 다른 node를 골라 cross-node child 시나리오를 구성합니다.
- fetch source 선택은 여전히 `producerAddress` 중심이며 replica-aware policy는 아직 없습니다.

`2026-04-06` 재검증:

- fresh artifact id: `demo-artifact-20260406-cross`
- parent on `lab-worker-0`
- child on `lab-worker-1`
- child 결과 `source=peer-fetch`
- digest 일치
- second-hit child 결과 `source=local`
- catalog record:
  - `artifactId`: `demo-artifact-20260406-cross`
  - `producerNode`: `lab-worker-0`
  - `producerAddress`: `http://10.87.127.94:8080`
  - `state`: `produced`
  - `replicaNodes[0].node`: `lab-worker-1`
  - `replicaNodes[0].address`: `http://10.87.127.150:8080`
  - `replicaNodes[0].state`: `replicated`

로그 스냅샷:

```text
== parent log ==
{
  "artifactId": "demo-artifact-20260406-cross",
  "digest": "d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1",
  "localAddress": "http://10.87.127.94:8080",
  "localNode": "lab-worker-0",
  "localPath": "/var/lib/artifact-handoff/demo-artifact-20260406-cross/payload.bin",
  "producerAddress": "http://10.87.127.94:8080",
  "producerNode": "lab-worker-0",
  "size": 40,
  "source": "local-put",
  "state": "available-local"
}

== child log ==
artifact-handoff sprint1 sample payload
source=peer-fetch
digest=d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1

== second hit log ==
artifact-handoff sprint1 sample payload
source=local
digest=d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1
```

## Second-Hit Cache

- 상태: `2026-04-03` 최종 메모에는 실행 여부가 남아 있지 않음
- `2026-04-03` 시점 상태: 두 번째 노드가 없어 cross-node fetch를 검증할 수 없어 실행하지 못함

현재 코드 기준 해석:

- 스크립트는 여전히 `--second-hit` 옵션을 지원하며, 두 번째 child가 `local` source를 기대하도록 구성되어 있습니다.
- `2026-04-06` 재검증에서는 `demo-artifact-20260406-cross` 기준으로 second-hit local cache가 실제로 통과했습니다.

## Failure Scenario Validation

`2026-04-08`에는 B6에서 추가한 failure metadata recording이 실제로 남는지 두 개의 failure scenario로 검증했습니다.

용어 기준:

- 이 섹션의 `fetch-failed`, `lastError`, `peer fetch exception`, `peer digest mismatch`, `peer fetch http 409: digest mismatch`는 [peer-fetch-failure-paths.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/peer-fetch-failure-paths.ko.md)의 taxonomy를 따른다.
- 현재까지 검증한 대표 failure를 한 장 표로 보려면 [FAILURE_MATRIX.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/FAILURE_MATRIX.ko.md)를 같이 본다.

### Scenario A: producer points to self

- scenario 이름: `producer points to self`
- artifact id: `fail-self-20260408b`
- producer node: `lab-worker-1`
- consumer node: `lab-worker-1`
- 주입 방식:
  - catalog record에 `producerNode=lab-worker-1`
  - `producerAddress=http://10.87.127.150:8080`
  - 실제 payload는 worker1 local storage에 존재하지 않음
- 기대:
  - local artifact miss 이후 peer fetch 단계에서 producer가 self를 가리킨다고 판단
  - local metadata에 `state=fetch-failed`, `lastError` 기록
- 판정 결과: pass
- 해석:
  - self-loop 성격의 잘못된 producer metadata는 agent가 명확히 실패로 드러내고, local metadata에 이유를 남겼습니다.

핵심 로그:

```text
status=404
{
  "error": "artifact missing locally and producer points to self"
}
```

local metadata snapshot:

```json
{
  "artifactId": "fail-self-20260408b",
  "lastError": "artifact missing locally and producer points to self",
  "localAddress": "http://10.87.127.150:8080",
  "localNode": "lab-worker-1",
  "localPath": "/var/lib/artifact-handoff/fail-self-20260408b/payload.bin",
  "producerAddress": "http://10.87.127.150:8080",
  "producerNode": "lab-worker-1",
  "source": "peer-fetch",
  "state": "fetch-failed"
}
```

### Scenario B: peer fetch exception

- scenario 이름: `peer fetch exception`
- artifact id: `fail-peer-exc-20260408`
- producer node: `lab-master-0`로 기록
- consumer node: `lab-worker-1`
- 주입 방식:
  - catalog record에 `producerAddress=http://10.87.127.18:18080`
  - 해당 주소에는 agent가 실제로 listening 하지 않음
- 기대:
  - peer fetch 연결 예외 발생
  - local metadata에 `state=fetch-failed`, `lastError` 기록
- 판정 결과: pass
- 해석:
  - 네트워크/endpoint 문제로 peer fetch가 실패해도, agent가 단순 404 반환에 그치지 않고 로컬 failure metadata를 남깁니다.

핵심 로그:

```text
status=404
{
  "error": "<urlopen error [Errno 111] Connection refused>"
}
```

local metadata snapshot:

```json
{
  "artifactId": "fail-peer-exc-20260408",
  "lastError": "<urlopen error [Errno 111] Connection refused>",
  "localAddress": "http://10.87.127.150:8080",
  "localNode": "lab-worker-1",
  "localPath": "/var/lib/artifact-handoff/fail-peer-exc-20260408/payload.bin",
  "producerAddress": "http://10.87.127.18:18080",
  "producerNode": "lab-master-0",
  "source": "peer-fetch",
  "state": "fetch-failed"
}
```

## Digest Mismatch Failure Validation

`2026-04-08`에는 B7에 이어 digest mismatch 계열 failure가 실제로 `fetch-failed` local metadata를 남기는지 추가 검증했습니다.

용어 기준:

- `local digest mismatch`는 `source=local-verify`인 local verification failure로 본다.
- `peer digest mismatch`와 `peer fetch http 409: digest mismatch`의 차이는 [peer-fetch-failure-paths.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/peer-fetch-failure-paths.ko.md)에 정리했다.

### Scenario C: local digest mismatch

- scenario 이름: `local digest mismatch`
- artifact id: `fail-internal-local-digest-20260408`
- producer node: `lab-worker-0`
- consumer node: `lab-worker-0`
- 재현 방식:
  - worker0 agent에 정상 payload를 먼저 `PUT`
  - 저장된 `payload.bin`을 같은 node에서 고의로 덮어씀
  - 먼저 `/internal/artifacts/{artifactId}`로 local verify path만 직접 호출
  - 이어서 공개 `/artifacts/{artifactId}` 경로도 다시 호출
- 기대:
  - local verify에서 `local digest mismatch`가 발생
  - local metadata에 `state=fetch-failed`, `source=local-verify`, `lastError=local digest mismatch` 기록
  - 공개 경로도 같은 `lastError`를 그대로 돌려줌
- 판정 결과: pass
- 해석:
  - local corruption은 이제 peer fetch fallback에 묻히지 않고, local verify failure로 보존됩니다.

핵심 로그:

`/internal/artifacts/...` 호출:

```text
status=404
{
  "error": "local digest mismatch"
}
```

`/artifacts/...` 재호출:

```text
status=404
{
  "error": "local digest mismatch"
}
```

local metadata snapshot:

```json
{
  "artifactId": "fail-internal-local-digest-20260408",
  "lastError": "local digest mismatch",
  "localAddress": "http://10.87.127.94:8080",
  "localNode": "lab-worker-0",
  "localPath": "/var/lib/artifact-handoff/fail-internal-local-digest-20260408/payload.bin",
  "producerAddress": "http://10.87.127.94:8080",
  "producerNode": "lab-worker-0",
  "source": "local-verify",
  "state": "fetch-failed"
}
```

추가 확인:

- 이 검증 중 공개 `/artifacts/...` 경로가 기존에는 local digest mismatch 직후 peer fetch self-loop 에러로 덮이는 작은 문제가 있음을 확인했습니다.
- agent GET 경로를 아주 좁게 보정해, 이미 `fetch-failed` local metadata가 생긴 경우 그 `lastError`를 그대로 반환하도록 수정했습니다.
- 이후 worker0 agent pod를 재시작한 뒤 같은 artifact id로 공개 경로를 다시 확인했을 때 `local digest mismatch`가 그대로 노출됐습니다.

### Scenario D: peer digest mismatch

- scenario 이름: `peer digest mismatch`
- artifact id:
  - end-to-end HTTP probe: `fail-peer-digest-http-20260408`
  - direct peer-fetch branch probe: `fail-peer-digest-direct-20260408`
- producer node: `lab-worker-0`
- consumer node: `lab-worker-1`
- 검증 방식:
  - 먼저 실제 HTTP 흐름에서 catalog digest를 고의로 잘못 바꿔 cross-node fetch를 시도
  - 이어서 live consumer pod 안에서 `peer_fetch()` branch를 직접 호출해 mismatched payload를 주입
- 기대:
  - 가능하면 실HTTP 흐름에서 `peer digest mismatch`까지 도달하는지 확인
  - 최소한 live code branch 기준으로 `fetch-failed` / `lastError=peer digest mismatch`가 실제 기록되는지 확인

1. end-to-end HTTP probe

- catalog record의 `digest`를 `0000...`로 덮은 뒤 worker1에서 공개 `/artifacts/...`를 호출했습니다.
- 결과:

```text
status=409
{
  "error": "catalog lookup failed"
}
```

- consumer local metadata:

```json
{
  "artifactId": "fail-peer-digest-http-20260408",
  "lastError": "catalog lookup failed",
  "localAddress": "http://10.87.127.150:8080",
  "localNode": "lab-worker-1",
  "localPath": "/var/lib/artifact-handoff/fail-peer-digest-http-20260408/payload.bin",
  "producerAddress": "",
  "producerNode": "",
  "source": "catalog-lookup",
  "state": "fetch-failed"
}
```

- 해석:
  - 현재 설계에서는 producer의 `/internal/artifacts/...`가 expected digest를 먼저 확인하므로, end-to-end HTTP만으로는 consumer 쪽 `peer digest mismatch` branch까지 내려가기 어렵습니다.
  - 게다가 현재 공개 `/artifacts/...` 경로는 이 `409`를 `catalog lookup failed`로 뭉개고 있어, 이 경우의 observability가 거칠다는 점도 드러났습니다.

2. direct peer-fetch branch probe

- worker1 live pod 안에서 `peer_fetch()`를 직접 호출하되, `fetch_catalog()`와 peer 응답을 아주 좁게 monkeypatch해서 mismatched payload를 반환하게 했습니다.
- 결과:

```text
ValueError
peer digest mismatch
```

- consumer local metadata:

```json
{
  "artifactId": "fail-peer-digest-direct-20260408",
  "lastError": "peer digest mismatch",
  "localAddress": "http://10.87.127.150:8080",
  "localNode": "lab-worker-1",
  "localPath": "/var/lib/artifact-handoff/fail-peer-digest-direct-20260408/payload.bin",
  "producerAddress": "http://10.87.127.94:8080",
  "producerNode": "lab-worker-0",
  "source": "peer-fetch",
  "state": "fetch-failed"
}
```

- 판정 결과: partial pass
- 해석:
  - live code branch 기준으로는 consumer-side verification failure인 `peer digest mismatch` recording이 정상 동작합니다.
  - 다만 현재 producer-side internal digest gate 때문에, 같은 integrity failure가 end-to-end HTTP에서는 producer-side rejection으로 먼저 관찰됩니다.

## Peer Fetch HTTP Error Attribution Tightening

`2026-04-08`에는 B9에서 드러난 attribution gap을 좁히기 위해, 공개 `/artifacts/...` 경로가 producer-side HTTP 에러와 catalog lookup failure를 구분하도록 보정한 뒤 같은 시나리오를 다시 검증했습니다.

용어 기준:

- 이 섹션의 핵심은 `peer digest mismatch` 자체를 바꾼 것이 아니라, producer-side rejection을 `peer fetch http 409: digest mismatch`로 더 정확히 라벨링한 것이다.
- 자세한 구분은 [peer-fetch-failure-paths.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/peer-fetch-failure-paths.ko.md)를 따른다.

### Scenario E: peer digest mismatch after attribution tightening

- scenario 이름: `peer digest mismatch after attribution tightening`
- artifact id: `fail-peer-digest-http-b10-20260408`
- producer node: `lab-worker-0`
- consumer node: `lab-worker-1`
- 재현 방식:
  - worker0에 정상 artifact 생성
  - catalog digest를 `0000...`로 덮어씀
  - worker1 공개 `/artifacts/{artifactId}` 호출
- 기대:
  - 더 이상 `catalog lookup failed`로 뭉개지지 않고, peer-side HTTP 에러가 드러나야 함
  - consumer local metadata도 `source=peer-fetch`와 producer 정보를 유지해야 함
- 판정 결과: pass
- 해석:
  - 현재는 end-to-end HTTP 경로에서도 producer internal `409 digest mismatch`가 consumer 쪽에서 `peer fetch http 409: digest mismatch`로 관찰됩니다.

핵심 로그:

```text
status=409
{
  "error": "peer fetch http 409: digest mismatch"
}
```

local metadata snapshot:

```json
{
  "artifactId": "fail-peer-digest-http-b10-20260408",
  "lastError": "peer fetch http 409: digest mismatch",
  "localAddress": "http://10.87.127.150:8080",
  "localNode": "lab-worker-1",
  "localPath": "/var/lib/artifact-handoff/fail-peer-digest-http-b10-20260408/payload.bin",
  "producerAddress": "http://10.87.127.94:8080",
  "producerNode": "lab-worker-0",
  "source": "peer-fetch",
  "state": "fetch-failed"
}
```

추가 해석:

- 이 변경은 producer-side digest gate 자체를 없앤 것은 아닙니다.
- 즉 consumer가 own-branch `peer digest mismatch`를 판단하기 전에 producer가 `409 digest mismatch`로 막는 구조는 그대로입니다.
- 다만 이제 공개 경로에서 그 사실을 `catalog lookup failed`로 잘못 라벨링하지 않고, peer-side HTTP failure로 더 정확히 드러냅니다.

## Edge Case Truth Tightening

`2026-04-08`에는 post-freeze 이후 첫 edge case truth를 좁게 확인했습니다.

용어 기준:

- 이번 시나리오는 failure taxonomy를 더 확장하는 작업이 아니라, `catalog`와 `local metadata` authority 경계를 실제 동작으로 확인하는 validation입니다.
- 관련 해석 메모는 [EDGE_CASE_TRUTH_TIGHTENING.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/EDGE_CASE_TRUTH_TIGHTENING.ko.md)를 같이 봅니다.

### Scenario F: catalog record exists + local artifact missing (same-node)

- scenario 이름: `catalog record exists + local artifact missing`
- artifact id: `edge-local-miss-20260408-same`
- producer node: `lab-worker-0`
- consumer node: `lab-worker-0`
- 재현 방식:
  - worker0에 fresh artifact 생성
  - catalog record는 유지
  - worker0 hostPath의 `/var/lib/artifact-handoff/edge-local-miss-20260408-same` 디렉터리만 제거
  - 같은 node에서 `/artifacts/{id}` 재호출
- 판정 결과: pass
- 해석:
  - catalog truth는 그대로 남아 있지만, actual local availability가 없으면 same-node 경로는 self-loop failure로 드러납니다.

핵심 로그:

```text
mode=same-node
producer_node=lab-worker-0
consumer_node=lab-worker-0

== consumer log ==
status=404
{
  "error": "artifact missing locally and producer points to self"
}
```

catalog snapshot:

```json
{
  "artifactId": "edge-local-miss-20260408-same",
  "digest": "d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1",
  "localPath": "/var/lib/artifact-handoff/edge-local-miss-20260408-same/payload.bin",
  "producerAddress": "http://10.87.127.94:8080",
  "producerNode": "lab-worker-0",
  "replicaNodes": [],
  "state": "produced"
}
```

local metadata snapshot:

```json
{
  "artifactId": "edge-local-miss-20260408-same",
  "lastError": "artifact missing locally and producer points to self",
  "localAddress": "http://10.87.127.94:8080",
  "localNode": "lab-worker-0",
  "localPath": "/var/lib/artifact-handoff/edge-local-miss-20260408-same/payload.bin",
  "producerAddress": "http://10.87.127.94:8080",
  "producerNode": "lab-worker-0",
  "source": "peer-fetch",
  "state": "fetch-failed"
}
```

### Scenario G: catalog record exists + local artifact missing (cross-node)

- scenario 이름: `catalog record exists + local artifact missing`
- artifact id: `edge-local-miss-20260408-cross`
- producer node: `lab-worker-0`
- consumer node: `lab-worker-1`
- 재현 방식:
  - worker0에 fresh artifact 생성
  - catalog record는 유지
  - consumer node인 worker1의 `/var/lib/artifact-handoff/edge-local-miss-20260408-cross` 디렉터리만 제거
  - worker1에서 `/artifacts/{id}` 호출
- 판정 결과: pass
- 해석:
  - producer truth는 그대로 유지되고, non-producer node에서는 peer fetch recovery가 실제로 성립합니다.

핵심 로그:

```text
mode=cross-node
producer_node=lab-worker-0
consumer_node=lab-worker-1

== consumer log ==
status=200
source=peer-fetch
artifact-handoff sprint1 sample payload
```

catalog snapshot:

```json
{
  "artifactId": "edge-local-miss-20260408-cross",
  "digest": "d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1",
  "localPath": "/var/lib/artifact-handoff/edge-local-miss-20260408-cross/payload.bin",
  "producerAddress": "http://10.87.127.94:8080",
  "producerNode": "lab-worker-0",
  "replicaNodes": [
    {
      "address": "http://10.87.127.150:8080",
      "localPath": "/var/lib/artifact-handoff/edge-local-miss-20260408-cross/payload.bin",
      "node": "lab-worker-1",
      "state": "replicated"
    }
  ],
  "state": "produced"
}
```

local metadata snapshot:

```json
{
  "artifactId": "edge-local-miss-20260408-cross",
  "digest": "d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1",
  "localAddress": "http://10.87.127.150:8080",
  "localNode": "lab-worker-1",
  "localPath": "/var/lib/artifact-handoff/edge-local-miss-20260408-cross/payload.bin",
  "producerAddress": "http://10.87.127.94:8080",
  "producerNode": "lab-worker-0",
  "size": 40,
  "source": "peer-fetch",
  "state": "replicated"
}
```

## 참고

- 이 저장소의 베이스라인과 스크립트는 `multipass-k8s-lab`이 준비한 랩 클러스터를 대상으로 동작하도록 설계되었습니다.
- `scripts/check-lab.sh`는 기본적으로 `MIN_NODES=3`을 사용하며, 의도한 랩 형태가 없으면 즉시 실패합니다.
- 남아 있던 단일 노드 클러스터에서 부분 디버깅을 진행할 때는 same-node 검증만 수행하기 위해 `MIN_NODES=1`을 사용했습니다.
- 이 파일의 초기 blocked 상태는 `2026-04-03` 시점 기록이며, 최종 회복 상태 자체를 의미하지는 않습니다.
- 이후 회복과 cross-node 성공 내용은 [TROUBLESHOOTING_NOTES.md](TROUBLESHOOTING_NOTES.md) 와 [VALIDATION_HISTORY.ko.md](VALIDATION_HISTORY.ko.md)에 추가로 정리했습니다.
- `2026-04-06` 재검증 과정에서 두 가지 운영 이슈도 확인됐습니다.
- 최신 agent 코드에서는 peer fetch 또는 local verify 실패 시 local metadata에 `state=fetch-failed`와 `lastError`를 남기도록 보강했습니다.
  - host의 `python3`가 3.6 계열이라 metadata 조회 helper에서 `subprocess.check_output(..., text=True)`를 쓸 수 없어 스크립트 호환성 수정이 필요했습니다.
  - 기존 artifact cache와 오래된 pod 프로세스 때문에 첫 cross-node 재실행은 `source=local`로 실패했고, fresh `ARTIFACT_ID` 사용 및 pod restart 후 정상 검증했습니다.
- `2026-04-08` failure scenario validation에서는 `producer points to self`와 `peer fetch exception` 두 시나리오 모두에서 `fetch-failed` metadata 기록이 실제로 확인됐습니다.
- `2026-04-08` digest mismatch validation에서는 `local digest mismatch`가 `source=local-verify`, `state=fetch-failed`, `lastError=local digest mismatch` 형태로 실제 기록되는 것을 확인했습니다.
- `2026-04-08` peer digest mismatch validation에서는 live consumer pod의 `peer_fetch()` branch에서 `lastError=peer digest mismatch` 기록을 확인했지만, end-to-end HTTP 흐름에서는 producer-side digest gate 때문에 같은 메시지까지 직접 도달하지 못했습니다.
- `2026-04-08` B10 attribution tightening 이후에는 같은 end-to-end HTTP 흐름이 `peer fetch http 409: digest mismatch`로 관찰됐고, local metadata도 `source=peer-fetch`와 producer 정보를 유지했습니다.
