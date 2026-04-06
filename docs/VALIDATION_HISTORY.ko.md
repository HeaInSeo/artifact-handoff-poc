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

## 6. 남은 기록 과제

이번에 실제로 남겨 둘 만한 후속 작업은 다음입니다.

- `docs/RESULTS.md` 를 초기 상태 기록과 최종 상태 기록으로 더 명확히 구분하기
- same-node / cross-node / second-hit 을 각각 언제 실행했고 어떤 출력이 나왔는지 로그 스냅샷 정리
- `multipass-k8s-lab` 의 infra 장애와 이 저장소의 validation 결과를 교차 참조하는 링크 추가

## 참고

인프라 쪽 상세 장애 흐름은 `../../multipass-k8s-lab/docs/TROUBLESHOOTING_HISTORY.ko.md` 에 별도로 정리합니다.
