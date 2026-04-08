# REPLICA_AWARE_FIRST_VALIDATION

## 목적

이 문서는 `Sprint F4 - Replica-Aware Fetch First Validation`에서 확보한 첫 evidence를 고정하기 위한 메모다.

질문:

- 현재 구현에서 `replicaNodes`와 replica local metadata는 실제로 준비되는가
- 그리고 그 상태가 이미 replica-aware fetch를 뜻하는가

## 실검증 시나리오

- artifact id: `replica-aware-20260408`
- producer node: `lab-worker-0`
- first replica node: `lab-worker-1`
- 실행 helper:
  - [run-replica-aware-prep.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-replica-aware-prep.sh)

실행 흐름:

1. 기존 cross-node flow로 producer와 first replica를 만든다
2. catalog snapshot에서 `replicaNodes` populated 여부를 확인한다
3. replica node local metadata를 확인한다
4. current code path가 무엇을 fetch source로 보는지 같이 읽는다

## 실제로 관찰된 것

parent log:

```text
{
  "artifactId": "replica-aware-20260408",
  "digest": "d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1",
  "localAddress": "http://10.87.127.94:8080",
  "localNode": "lab-worker-0",
  "localPath": "/var/lib/artifact-handoff/replica-aware-20260408/payload.bin",
  "producerAddress": "http://10.87.127.94:8080",
  "producerNode": "lab-worker-0",
  "size": 40,
  "source": "local-put",
  "state": "available-local"
}
```

child log:

```text
artifact-handoff sprint1 sample payload
source=peer-fetch
digest=d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1
```

catalog snapshot:

```json
{
  "artifactId": "replica-aware-20260408",
  "producerAddress": "http://10.87.127.94:8080",
  "producerNode": "lab-worker-0",
  "replicaNodes": [
    {
      "address": "http://10.87.127.150:8080",
      "localPath": "/var/lib/artifact-handoff/replica-aware-20260408/payload.bin",
      "node": "lab-worker-1",
      "state": "replicated"
    }
  ]
}
```

replica local metadata snapshot:

```json
{
  "localNode": "lab-worker-1",
  "producerNode": "lab-worker-0",
  "replicaNode": "lab-worker-1",
  "source": "peer-fetch",
  "state": "replicated"
}
```

## 코드 기준으로 같이 확인한 점

현재 agent는 여전히 `record.get("producerAddress")`를 직접 fetch source로 사용한다.

근거:

- [agent.py](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/app/agent/agent.py) 의 `peer_fetch()`
- `producer = record.get("producerAddress")`

반면 catalog는 `replicaNodes`를 기록/유지하지만, 현재 fetch path는 이를 실제 source selection에 사용하지 않는다.

## 이번 validation의 결론

이번 스프린트에서 확인된 것은 두 가지다.

1. `replicaNodes`와 replica local metadata는 실제로 준비된다
2. 하지만 현재 구현은 아직 replica-aware fetch를 수행하지 않고, producer-only bias를 유지한다

즉 현재 상태는:

- `replica-ready state`: yes
- `replica-aware source selection`: not yet

## 결론 한 줄

`Sprint F4`의 결론은 **현재 구현은 replica-ready 상태까지는 실제로 만들지만, 아직 fetch source selection은 `producerAddress` 중심이라 replica-aware fetch라고 부를 수는 없다**는 것이다.
