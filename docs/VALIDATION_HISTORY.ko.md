# VALIDATION_HISTORY

이 문서는 Sprint 1 검증이 실제로 어떤 순서로 진행됐는지, 그리고 왜 중간에 결과가 부분 성공과 최종 성공으로 나뉘었는지를 Git 히스토리와 실제 트러블슈팅 흐름 기준으로 정리한 기록입니다.

## 요약

`artifact-handoff-poc`의 Sprint 1은 처음부터 곧바로 완주된 것이 아닙니다.

실제 진행은 다음과 같았습니다.

1. PoC baseline 구현 완료
2. 랩 클러스터가 3-node 로 준비되지 않아 full validation blocked
3. 남아 있던 single-node 환경으로 same-node 만 부분 검증
4. `multipass-k8s-lab` 쪽 image / join / runtime 문제 해결
5. 3-node 회복 후 cross-node peer fetch 성립 확인
6. `2026-04-06` 최신 코드 기준으로 same-node / cross-node / second-hit 재검증
7. `2026-04-08` failure scenario 2종 검증
8. `2026-04-08` local digest mismatch 검증
9. `2026-04-08` peer digest mismatch branch 검증
10. `2026-04-08` peer fetch HTTP attribution 보정

즉, 이 저장소의 결과를 읽을 때는 "애플리케이션 로직 검증"과 "인프라 준비 상태"를 분리해서 봐야 합니다.

## 관련 커밋

- `084d54c` `Add sprint1 artifact handoff baseline`
- `8aacf7f` `Add troubleshooting notes for sprint1 validation`

인프라 측 관련 커밋:

- `multipass-k8s-lab`의 `4843572` `Switch lab baseline guest to Ubuntu 24.04`
- `multipass-k8s-lab`의 `9a704d6` `Fix worker join script permissions`
- `multipass-k8s-lab`의 `0e660a5` `Document Rocky8 runtime troubleshooting note`

## 1. baseline 구현 단계

`084d54c` 시점에서 다음 항목이 한 번에 들어왔습니다.

- `artifact-agent`
- `catalog`
- base manifests
- `deploy.sh`
- `run-same-node.sh`
- `run-cross-node.sh`
- 초기 결과 문서와 scope 문서

즉, Sprint 1의 실험 구조 자체는 초기에 이미 구현돼 있었습니다. 이후 막힌 지점은 주로 "구현 부재"가 아니라 "실제 3-node 랩에서 끝까지 검증 가능한가"였습니다.

## 2. 첫 번째 실제 막힘: 3-node 랩 미준비

초기 결과 문서에는 다음 내용이 남아 있습니다.

- `multipass-k8s-lab/scripts/k8s-tool.sh up` 가 `rocky-8` 이미지 별칭 문제로 실패
- 단일 노드만 남아 있어 `MIN_NODES=3` 기본 검증을 통과하지 못함
- `run-cross-node.sh` 는 최소 두 개의 schedulable node 가 필요하므로 중단됨

이 상태에서 중요한 판단은, PoC 코드 전체를 의심하지 않고 인프라 병목과 기능 검증을 분리한 것입니다.

## 3. 부분 검증: same-node 는 single-node 에서 확인

인프라가 완전히 준비되지 않았더라도, same-node 시나리오는 남아 있던 단일 노드에서 검증할 수 있었습니다.

확인된 내용:

- parent job 이 artifact 등록
- child job 이 같은 노드에서 artifact 재사용
- child 출력의 `source=local`
- digest 일치
- catalog 상태 `ready`

이 부분은 중요합니다. cross-node 가 막혀 있던 시점에도, 최소한 "artifact write / catalog registration / local reuse" 경로는 이미 성립했다는 뜻이기 때문입니다.

## 4. 인프라 회복 뒤 cross-node 검증 성립

이후 `multipass-k8s-lab` 쪽에서 다음 문제가 정리됐습니다.

- guest baseline 을 Ubuntu 24.04 로 전환
- worker join 권한 문제 수정
- control plane / containerd / CNI 회복

그리고 실제 검증에서 다음이 확인됐습니다.

- parent on `lab-worker-0`
- child on `lab-worker-1`
- child 결과 `source=peer-fetch`
- digest 일치
- catalog 에 producer / replica node 정보 반영

즉, Sprint 1의 핵심 질문인 "same-node reuse 와 cross-node peer fetch 가 실제 랩에서 성립하는가"에 대해 둘 다 긍정적으로 답할 수 있게 됐습니다.

## 5. 결과 문서를 읽을 때 주의할 점

초기 `docs/RESULTS.md` 는 2026-04-03 시점의 중간 기록 성격이 강합니다. 그래서 다음 내용이 남아 있습니다.

- cross-node blocked
- second-hit cache not run
- full acceptance incomplete

이 문서 자체가 틀린 것은 아니지만, "그 시점의 상태"를 기록한 것입니다. 이후 실제 진행은 `docs/TROUBLESHOOTING_NOTES.md` 와 현재 클러스터 상태에서 더 나아갔습니다.

따라서 Sprint 1 회고를 할 때는 다음처럼 읽는 것이 맞습니다.

- `docs/RESULTS.md`: 초기 검증 시점의 중간 상태
- `docs/TROUBLESHOOTING_NOTES.md`: 인프라 회복과 최종 cross-node 성립까지 포함한 후속 메모
- 이 문서: 전체 진행 경과를 시간순으로 정리한 학습용 히스토리

## 6. 최신 코드 기준 재검증

`2026-04-06`에는 `multipass-k8s-lab` 환경이 이미 정상 동작 중인 상태에서, 최신 코드 기준으로 다시 검증을 수행했습니다.

확인한 항목:

- same-node fresh artifact id 검증 통과
- cross-node fresh artifact id 검증 통과
- second-hit local cache 검증 통과

이번 재검증에서 확인된 추가 포인트:

- child placement 입력은 이제 parent 완료 후 catalog의 `producerNode`를 읽는 스크립트가 보조한다.
- catalog top-level state는 `produced`, replica state는 `replicated`로 반영된다.
- local metadata는 `producerNode` / `producerAddress`와 `localNode` / `localAddress`를 함께 기록한다.

또한 재검증 과정에서 두 가지 운영 이슈가 드러났다.

1. host의 `python3`가 3.6 계열이라 script helper가 `text=True`를 사용할 수 없었고, 호환성 수정이 필요했다.
2. 첫 cross-node 재실행은 이전 artifact cache와 old pod process 영향으로 `source=local`이 나와 실패했고, fresh `ARTIFACT_ID`와 pod restart 후 기대한 `peer-fetch`가 확인됐다.
3. 이후 agent는 peer fetch 실패나 local verify 실패 시 local metadata에 `state=fetch-failed`와 `lastError`를 남기도록 보강됐다.

## 7. failure scenario validation

`2026-04-08`에는 B6에서 넣은 failure metadata recording이 실제로 찍히는지 두 개의 작은 시나리오로 확인했습니다.

용어 기준:

- 이 문서의 failure 용어는 [peer-fetch-failure-paths.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/peer-fetch-failure-paths.ko.md)를 기준으로 읽는다.
- 대표 failure scenario를 한 장으로 다시 보려면 [FAILURE_MATRIX.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/FAILURE_MATRIX.ko.md)를 같이 본다.

검증한 시나리오:

1. `producer points to self`
2. `peer fetch exception` (`Connection refused`)

확인한 점:

- 두 시나리오 모두 consumer node local metadata에 `state=fetch-failed`가 남았다.
- `lastError` 값도 기대한 원인과 직접 연결됐다.
  - self-producer 시나리오: `artifact missing locally and producer points to self`
  - peer fetch exception 시나리오: `<urlopen error [Errno 111] Connection refused>`
- 즉 B6에서 추가한 failure recording은 실환경에서도 최소 목적을 충족했다.

아직 남는 점:

- failure 정보는 local metadata에는 남지만 catalog top-level state에는 반영되지 않는다.
- 따라서 현재 단계에서는 "consumer node local forensic trail"은 생겼지만, cluster-wide failure observability는 아직 제한적이다.

## 8. 남은 기록 과제

이번에 실제로 남겨 둘 만한 후속 작업은 다음입니다.

- `multipass-k8s-lab` 의 infra 장애와 이 저장소의 validation 결과를 교차 참조하는 링크 추가

## 9. local digest mismatch validation

`2026-04-08`에는 failure scenario 검증을 한 단계 더 좁혀서, digest mismatch 계열 중 재현성이 높은 `local digest mismatch`를 실제로 확인했습니다.

용어 기준:

- `local digest mismatch`는 peer failure가 아니라 local verification failure이며 `source=local-verify`가 맞다.

검증 방식:

1. `lab-worker-0` agent에 정상 payload를 등록
2. worker0 local storage의 `payload.bin`을 수동으로 손상
3. `/internal/artifacts/{artifactId}` 경로로 local verify만 직접 호출
4. local metadata snapshot 확인
5. 이어서 공개 `/artifacts/{artifactId}` 경로가 같은 `lastError`를 유지하는지도 확인

확인한 점:

- `/internal/artifacts/...` 호출은 `404`와 함께 `local digest mismatch`를 반환했다.
- worker0 local metadata에는 아래가 기록됐다.
  - `state=fetch-failed`
  - `source=local-verify`
  - `lastError=local digest mismatch`
- 즉 B6에서 넣은 failure recording은 digest mismatch 계열에서도 실제로 동작했다.

이번 검증에서 같이 드러난 작은 구현 이슈:

- 공개 `/artifacts/...` 경로는 처음에는 local digest mismatch 직후 peer fetch fallback으로 다시 들어가면서, self-loop 성격의 에러로 `lastError`가 덮일 수 있었다.
- 이를 막기 위해 agent GET 경로를 아주 좁게 보정했고, worker0 agent pod 재시작 후에는 공개 경로도 `local digest mismatch`를 그대로 반환했다.

아직 남는 점:

- 이번 스프린트에서는 `peer digest mismatch`까지는 evidence를 남기지 못했다.
- 따라서 digest mismatch coverage는 절반만 채워졌고, producer/consumer 간 payload 불일치를 더 직접적으로 만드는 후속 검증이 남아 있다.

## 10. peer digest mismatch validation

`2026-04-08`에는 digest mismatch coverage를 한 단계 더 넓혀서 `peer digest mismatch`도 확인했습니다. 다만 이번에는 "end-to-end HTTP 흐름"과 "live branch probe"의 결과를 분리해서 봐야 했습니다.

용어 기준:

- 여기서의 `peer digest mismatch`는 consumer-side verification failure를 뜻한다.
- producer-side rejection과의 차이는 [peer-fetch-failure-paths.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/peer-fetch-failure-paths.ko.md)에 정리했다.

1. end-to-end HTTP probe

- producer artifact는 정상 생성한 뒤, catalog record의 `digest`만 고의로 `0000...`로 바꿨습니다.
- 그 상태에서 worker1이 공개 `/artifacts/{artifactId}`를 호출하도록 했습니다.
- 결과는 `409`와 함께 `catalog lookup failed`였고, consumer local metadata도 `source=catalog-lookup`, `lastError=catalog lookup failed`로 남았습니다.

이 결과가 뜻하는 바:

- 현재 producer의 `/internal/artifacts/...` 경로는 expected digest를 먼저 검사합니다.
- 그래서 consumer 쪽 `peer_fetch()`가 payload를 읽고 직접 `peer digest mismatch`를 판단하기 전에, producer 쪽에서 요청이 먼저 막힙니다.
- 즉 현재 구현에서는 end-to-end HTTP만으로 `peer digest mismatch` 메시지까지 도달하기가 어렵습니다.

2. live peer-fetch branch probe

- 같은 날 worker1 live pod 안에서 `peer_fetch()`를 직접 호출했습니다.
- 이때 `fetch_catalog()`와 peer 응답만 아주 좁게 monkeypatch해서, consumer가 읽는 payload digest가 expected digest와 다르게 만들었습니다.
- 그 결과 `ValueError: peer digest mismatch`가 발생했고, local metadata에는 아래가 남았습니다.
  - `state=fetch-failed`
  - `source=peer-fetch`
  - `lastError=peer digest mismatch`

정리:

- branch 자체의 recording은 실제로 동작한다.
- 하지만 현재 end-to-end HTTP 설계에서는 producer-side digest gate가 더 앞에 있어서, 같은 failure를 외부 경로로 바로 관찰하기는 어렵다.
- 따라서 이번 스프린트는 `peer digest mismatch`를 "완전한 end-to-end pass"로 보기보다, "live branch evidence 확보 + current HTTP limitation 확인"으로 기록하는 것이 맞다.

## 11. peer fetch HTTP attribution tightening

`2026-04-08`에는 바로 이어서 B9에서 드러난 attribution 문제를 좁게 보정했습니다.

용어 기준:

- 이 섹션은 `peer digest mismatch`를 재정의하는 것이 아니라, producer-side rejection을 `peer fetch http 409: digest mismatch`로 더 정확히 드러내는 보정이다.

핵심 수정:

- 공개 `/artifacts/...` 경로에서 `fetch_catalog()`와 `peer_fetch()` 예외 처리를 분리했습니다.
- producer-side `HTTPError`는 더 이상 `catalog lookup failed`로 뭉개지지 않게 했습니다.
- peer 쪽 `HTTPError` body에 `{"error":"digest mismatch"}`가 있으면, consumer 응답과 local metadata 모두 `peer fetch http 409: digest mismatch`처럼 더 구체적인 메시지를 남기도록 했습니다.

실검증:

- fresh artifact `fail-peer-digest-http-b10-20260408`를 worker0에 생성
- catalog digest를 `0000...`로 바꾼 뒤 worker1 공개 `/artifacts/{artifactId}` 호출
- 결과:
  - HTTP 응답: `409`
  - 응답 본문: `peer fetch http 409: digest mismatch`
  - local metadata:
    - `state=fetch-failed`
    - `source=peer-fetch`
    - `producerNode=lab-worker-0`
    - `lastError=peer fetch http 409: digest mismatch`

정리:

- producer-side digest gate는 여전히 앞단에 있다.
- 하지만 이제 외부 관찰 기준으로는 이 failure가 `catalog lookup`이 아니라 `peer fetch HTTP failure`라는 점이 분명해졌다.
- 즉 B9에서 확인한 "current HTTP limitation" 자체는 남아 있지만, B10에서는 적어도 attribution은 정확해졌다.

## 12. post-freeze edge case truth tightening

`2026-04-08`에는 failure-doc 정리 이후 첫 post-freeze validation으로, `D3`에서 선택한 edge case를 실제로 좁게 확인했습니다.

선택한 질문:

- `catalog record exists + local artifact missing`

이번에는 same-node 경로를 먼저 확인했습니다.

실행 방식:

1. worker0에 fresh artifact `edge-local-miss-20260408-same` 생성
2. catalog record는 유지
3. worker0 hostPath artifact 디렉터리만 제거
4. 같은 node에서 `/artifacts/{artifactId}` 재호출

확인한 점:

- catalog record는 그대로 `state=produced`로 남아 있었다.
- same-node local availability는 사라졌기 때문에 local path는 miss가 났다.
- agent는 peer fetch fallback으로 들어갔지만, producer가 self를 가리키므로 self-loop failure가 됐다.
- worker0 local metadata에는 아래가 남았다.
  - `state=fetch-failed`
  - `source=peer-fetch`
  - `lastError=artifact missing locally and producer points to self`

이 기록이 중요한 이유:

- catalog truth와 local availability가 같은 뜻이 아니라는 점을 실제 evidence로 확인했기 때문이다.
- 즉 catalog에 producer record가 남아 있어도, 현재 node local copy가 사라지면 same-node 경로는 자동 성공이 아니라 failure로 드러난다.

아직 남는 점:

- 이번에는 same-node path만 먼저 확인했다.
- cross-node에서 같은 edge case가 peer fetch recovery로 이어지는지는 후속 검증 후보다.
- `catalog record missing + local artifact exists` edge case도 여전히 남아 있다.

## 참고

인프라 쪽 상세 장애 흐름은 `../../multipass-k8s-lab/docs/TROUBLESHOOTING_HISTORY.ko.md` 에 별도로 정리합니다.
