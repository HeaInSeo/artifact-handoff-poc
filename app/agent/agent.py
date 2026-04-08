#!/usr/bin/env python3
import hashlib
import json
import os
import shutil
import urllib.error
import urllib.parse
import urllib.request
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


PORT = int(os.environ.get("PORT", "8080"))
STORAGE_DIR = os.environ.get("STORAGE_DIR", "/var/lib/artifact-handoff")
CATALOG_URL = os.environ.get("CATALOG_URL", "http://artifact-catalog:8090")
NODE_NAME = os.environ.get("NODE_NAME", "unknown")
NODE_IP = os.environ.get("NODE_IP", "127.0.0.1")


class PeerFetchHTTPError(Exception):
    def __init__(self, status: int, message: str):
        super().__init__(message)
        self.status = status
        self.message = message


def artifact_path(artifact_id: str) -> str:
    return os.path.join(STORAGE_DIR, artifact_id, "payload.bin")


def metadata_path(artifact_id: str) -> str:
    return os.path.join(STORAGE_DIR, artifact_id, "metadata.json")


def ensure_dir(artifact_id: str) -> str:
    path = os.path.dirname(artifact_path(artifact_id))
    os.makedirs(path, exist_ok=True)
    return path


def sha256_hex(payload: bytes) -> str:
    return hashlib.sha256(payload).hexdigest()


def describe_http_error(exc: urllib.error.HTTPError) -> str:
    detail = ""
    try:
        body = exc.read().decode("utf-8").strip()
    except Exception:
        body = ""
    if body:
        try:
            payload = json.loads(body)
            detail = payload.get("error", body)
        except Exception:
            detail = body
    if detail:
        return f"peer fetch http {exc.code}: {detail}"
    return f"peer fetch http {exc.code}: {exc.reason}"


def load_local_metadata(artifact_id: str):
    path = metadata_path(artifact_id)
    if not os.path.exists(path):
        return None
    with open(path, "r", encoding="utf-8") as fh:
        return json.load(fh)


def save_local(
    artifact_id: str,
    payload: bytes,
    digest: str,
    source: str,
    producer_node: str,
    producer_address: str,
):
    ensure_dir(artifact_id)
    with open(artifact_path(artifact_id), "wb") as fh:
        fh.write(payload)
    state = "available-local"
    if source == "peer-fetch":
        state = "replicated"
    metadata = {
        "artifactId": artifact_id,
        "digest": digest,
        "producerNode": producer_node,
        "producerAddress": producer_address,
        "localNode": NODE_NAME,
        "localAddress": f"http://{NODE_IP}:{PORT}",
        "localPath": artifact_path(artifact_id),
        "source": source,
        "state": state,
        "size": len(payload),
    }
    with open(metadata_path(artifact_id), "w", encoding="utf-8") as fh:
        json.dump(metadata, fh, indent=2, sort_keys=True)
    return metadata


def save_failure_metadata(
    artifact_id: str,
    source: str,
    error: str,
    producer_node: str = "",
    producer_address: str = "",
):
    ensure_dir(artifact_id)
    payload_file = artifact_path(artifact_id)
    if os.path.exists(payload_file):
        os.remove(payload_file)
    metadata = {
        "artifactId": artifact_id,
        "producerNode": producer_node,
        "producerAddress": producer_address,
        "localNode": NODE_NAME,
        "localAddress": f"http://{NODE_IP}:{PORT}",
        "localPath": payload_file,
        "source": source,
        "state": "fetch-failed",
        "lastError": error,
    }
    with open(metadata_path(artifact_id), "w", encoding="utf-8") as fh:
        json.dump(metadata, fh, indent=2, sort_keys=True)
    return metadata


def register_catalog(artifact_id: str, digest: str):
    payload = {
        "digest": digest,
        "producerNode": NODE_NAME,
        "producerAddress": f"http://{NODE_IP}:{PORT}",
        "localPath": artifact_path(artifact_id),
        "state": "produced",
        "replicaNodes": [],
    }
    req = urllib.request.Request(
        f"{CATALOG_URL}/artifacts/{artifact_id}",
        data=json.dumps(payload).encode("utf-8"),
        method="PUT",
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=5) as resp:
        return json.loads(resp.read().decode("utf-8"))


def fetch_catalog(artifact_id: str):
    with urllib.request.urlopen(f"{CATALOG_URL}/artifacts/{artifact_id}", timeout=5) as resp:
        return json.loads(resp.read().decode("utf-8"))


def fetch_candidates(record: dict):
    current_address = f"http://{NODE_IP}:{PORT}"
    seen = set()
    candidates = []

    producer_address = record.get("producerAddress", "")
    producer_node = record.get("producerNode", "")
    if producer_address and producer_address != current_address:
        candidates.append(
            {
                "kind": "producer",
                "node": producer_node,
                "address": producer_address,
            }
        )
        seen.add(producer_address)

    for replica in record.get("replicaNodes", []):
        address = replica.get("address", "")
        if not address or address == current_address or address in seen:
            continue
        candidates.append(
            {
                "kind": "replica",
                "node": replica.get("node", ""),
                "address": address,
            }
        )
        seen.add(address)

    return candidates


def fetch_from_candidate(candidate: dict, artifact_id: str, expected_digest: str):
    url = (
        f"{candidate['address']}/internal/artifacts/"
        f"{urllib.parse.quote(artifact_id)}?digest={expected_digest}"
    )
    with urllib.request.urlopen(url, timeout=10) as resp:
        return resp.read()


def register_replica(artifact_id: str):
    payload = {
        "node": NODE_NAME,
        "address": f"http://{NODE_IP}:{PORT}",
        "localPath": artifact_path(artifact_id),
        "state": "replicated",
    }
    req = urllib.request.Request(
        f"{CATALOG_URL}/artifacts/{artifact_id}/replicas",
        data=json.dumps(payload).encode("utf-8"),
        method="POST",
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=5):
        return


def local_hit(artifact_id: str):
    meta = load_local_metadata(artifact_id)
    if not meta:
        return None
    if meta.get("state") == "fetch-failed":
        raise ValueError(meta.get("lastError", "previous fetch failed"))
    with open(artifact_path(artifact_id), "rb") as fh:
        payload = fh.read()
    digest = sha256_hex(payload)
    if digest != meta["digest"]:
        producer_node = meta.get("producerNode", "")
        producer_address = meta.get("producerAddress", "")
        shutil.rmtree(os.path.dirname(artifact_path(artifact_id)), ignore_errors=True)
        save_failure_metadata(
            artifact_id,
            "local-verify",
            "local digest mismatch",
            producer_node,
            producer_address,
        )
        raise ValueError("local digest mismatch")
    return payload, meta


def peer_fetch(artifact_id: str, expected_digest: str):
    record = fetch_catalog(artifact_id)
    candidates = fetch_candidates(record)
    current_address = f"http://{NODE_IP}:{PORT}"
    producer_address = record.get("producerAddress", "")
    if not candidates:
        if not producer_address:
            save_failure_metadata(artifact_id, "peer-fetch", "missing producerAddress")
            raise ValueError("missing producerAddress")
        if producer_address == current_address:
            save_failure_metadata(
                artifact_id,
                "peer-fetch",
                "artifact missing locally and producer points to self",
                record.get("producerNode", ""),
                producer_address,
            )
            raise ValueError("artifact missing locally and producer points to self")
        save_failure_metadata(
            artifact_id,
            "peer-fetch",
            "artifact missing locally and no remote fetch candidate available",
            record.get("producerNode", ""),
            producer_address,
        )
        raise ValueError("artifact missing locally and no remote fetch candidate available")

    last_error = None
    last_status = None
    payload = None
    for candidate in candidates:
        try:
            candidate_payload = fetch_from_candidate(candidate, artifact_id, expected_digest)
        except urllib.error.HTTPError as exc:
            last_error = describe_http_error(exc)
            last_status = exc.code
            continue
        except Exception as exc:
            last_error = str(exc)
            last_status = None
            continue

        actual_digest = sha256_hex(candidate_payload)
        if actual_digest != expected_digest:
            last_error = "peer digest mismatch"
            last_status = None
            continue
        payload = candidate_payload
        break

    if payload is None:
        error = last_error or "peer fetch failed"
        save_failure_metadata(
            artifact_id,
            "peer-fetch",
            error,
            record.get("producerNode", ""),
            record.get("producerAddress", ""),
        )
        if last_status is not None:
            raise PeerFetchHTTPError(last_status, error)
        raise ValueError(error)

    save_local(
        artifact_id,
        payload,
        expected_digest,
        "peer-fetch",
        record["producerNode"],
        record["producerAddress"],
    )
    register_replica(artifact_id)
    return payload, {
        "artifactId": artifact_id,
        "digest": actual_digest,
        "source": "peer-fetch",
    }


class Handler(BaseHTTPRequestHandler):
    server_version = "artifact-agent/0.1"

    def log_message(self, fmt, *args):
        print(fmt % args, flush=True)

    def _write_json(self, status: int, payload: dict) -> None:
        body = json.dumps(payload, indent=2, sort_keys=True).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _write_bytes(self, status: int, payload: bytes, headers=None) -> None:
        self.send_response(status)
        self.send_header("Content-Type", "application/octet-stream")
        self.send_header("Content-Length", str(len(payload)))
        if headers:
            for key, value in headers.items():
                self.send_header(key, value)
        self.end_headers()
        self.wfile.write(payload)

    def do_GET(self):
        if self.path == "/healthz":
            self._write_json(HTTPStatus.OK, {"status": "ok", "node": NODE_NAME})
            return
        if self.path.startswith("/has/"):
            artifact_id = self.path.split("/")[2]
            self._write_json(
                HTTPStatus.OK,
                {"artifactId": artifact_id, "present": load_local_metadata(artifact_id) is not None},
            )
            return
        if self.path.startswith("/internal/artifacts/"):
            artifact_id = urllib.parse.unquote(self.path.split("/")[3].split("?")[0])
            query = urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)
            expected_digest = query.get("digest", [""])[0]
            try:
                payload, meta = local_hit(artifact_id)
            except Exception as exc:
                self._write_json(HTTPStatus.NOT_FOUND, {"error": str(exc)})
                return
            if expected_digest and meta["digest"] != expected_digest:
                self._write_json(HTTPStatus.CONFLICT, {"error": "digest mismatch"})
                return
            self._write_bytes(HTTPStatus.OK, payload, {"X-Artifact-Source": "peer-serve"})
            return
        if self.path.startswith("/artifacts/"):
            artifact_id = urllib.parse.unquote(self.path.split("/")[2].split("?")[0])
            try:
                payload, meta = local_hit(artifact_id)
                self._write_bytes(
                    HTTPStatus.OK,
                    payload,
                    {
                        "X-Artifact-Digest": meta["digest"],
                        "X-Artifact-Source": "local",
                    },
                )
                return
            except Exception as exc:
                failure_meta = load_local_metadata(artifact_id)
                if failure_meta and failure_meta.get("state") == "fetch-failed":
                    self._write_json(HTTPStatus.NOT_FOUND, {"error": str(exc)})
                    return
            try:
                record = fetch_catalog(artifact_id)
            except urllib.error.HTTPError as exc:
                save_failure_metadata(artifact_id, "catalog-lookup", "catalog lookup failed")
                self._write_json(exc.code, {"error": "catalog lookup failed"})
                return
            try:
                payload, meta = peer_fetch(artifact_id, record["digest"])
                self._write_bytes(
                    HTTPStatus.OK,
                    payload,
                    {
                        "X-Artifact-Digest": meta["digest"],
                        "X-Artifact-Source": "peer-fetch",
                    },
                )
                return
            except PeerFetchHTTPError as exc:
                self._write_json(exc.status, {"error": exc.message})
                return
            except Exception as exc:
                self._write_json(HTTPStatus.NOT_FOUND, {"error": str(exc)})
                return
        self._write_json(HTTPStatus.NOT_FOUND, {"error": "unknown path"})

    def do_PUT(self):
        if not self.path.startswith("/artifacts/"):
            self._write_json(HTTPStatus.NOT_FOUND, {"error": "unknown path"})
            return
        artifact_id = urllib.parse.unquote(self.path.split("/")[2].split("?")[0])
        length = int(self.headers.get("Content-Length", "0"))
        payload = self.rfile.read(length)
        expected_digest = self.headers.get("X-Artifact-Digest", "")
        actual_digest = sha256_hex(payload)
        if not expected_digest:
            self._write_json(HTTPStatus.BAD_REQUEST, {"error": "missing X-Artifact-Digest"})
            return
        if expected_digest != actual_digest:
            self._write_json(
                HTTPStatus.CONFLICT,
                {"error": "digest mismatch", "expected": expected_digest, "actual": actual_digest},
            )
            return
        meta = save_local(
            artifact_id,
            payload,
            actual_digest,
            "local-put",
            NODE_NAME,
            f"http://{NODE_IP}:{PORT}",
        )
        register_catalog(artifact_id, actual_digest)
        self._write_json(HTTPStatus.OK, meta)


def main():
    os.makedirs(STORAGE_DIR, exist_ok=True)
    server = ThreadingHTTPServer(("0.0.0.0", PORT), Handler)
    print(f"agent listening on :{PORT} node={NODE_NAME} ip={NODE_IP}", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
