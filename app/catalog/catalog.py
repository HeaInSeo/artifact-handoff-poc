#!/usr/bin/env python3
import json
import os
import threading
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


PORT = int(os.environ.get("PORT", "8090"))
STATE_FILE = os.environ.get("STATE_FILE", "/data/catalog.json")


class CatalogStore:
    def __init__(self, state_file: str):
        self.state_file = state_file
        self.lock = threading.Lock()
        self.records = {}
        self._load()

    def _load(self) -> None:
        if not os.path.exists(self.state_file):
            return
        with open(self.state_file, "r", encoding="utf-8") as fh:
            self.records = json.load(fh)

    def _persist(self) -> None:
        os.makedirs(os.path.dirname(self.state_file), exist_ok=True)
        tmp = f"{self.state_file}.tmp"
        with open(tmp, "w", encoding="utf-8") as fh:
            json.dump(self.records, fh, indent=2, sort_keys=True)
        os.replace(tmp, self.state_file)

    def put(self, artifact_id: str, payload: dict) -> dict:
        with self.lock:
            current = self.records.get(artifact_id, {})
            replica_nodes = current.get("replicaNodes", [])
            payload.setdefault("replicaNodes", replica_nodes)
            self.records[artifact_id] = payload
            self._persist()
            return payload

    def get(self, artifact_id: str):
        with self.lock:
            return self.records.get(artifact_id)

    def list_all(self):
        with self.lock:
            return self.records

    def add_replica(self, artifact_id: str, replica: dict):
        with self.lock:
            record = self.records.get(artifact_id)
            if not record:
                return None
            replicas = record.setdefault("replicaNodes", [])
            for existing in replicas:
                if existing.get("node") == replica.get("node"):
                    existing.update(replica)
                    self._persist()
                    return record
            replicas.append(replica)
            self._persist()
            return record


STORE = CatalogStore(STATE_FILE)


class Handler(BaseHTTPRequestHandler):
    server_version = "artifact-catalog/0.1"

    def log_message(self, fmt, *args):
        print(fmt % args, flush=True)

    def _write_json(self, status: int, payload: dict) -> None:
        body = json.dumps(payload, indent=2, sort_keys=True).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _read_json(self):
        length = int(self.headers.get("Content-Length", "0"))
        raw = self.rfile.read(length) if length else b"{}"
        return json.loads(raw.decode("utf-8"))

    def do_GET(self):
        if self.path == "/healthz":
            self._write_json(HTTPStatus.OK, {"status": "ok"})
            return
        if self.path == "/artifacts":
            self._write_json(HTTPStatus.OK, STORE.list_all())
            return
        if self.path.startswith("/artifacts/"):
            artifact_id = self.path.split("/")[2]
            record = STORE.get(artifact_id)
            if not record:
                self._write_json(HTTPStatus.NOT_FOUND, {"error": "not found"})
                return
            self._write_json(HTTPStatus.OK, record)
            return
        self._write_json(HTTPStatus.NOT_FOUND, {"error": "unknown path"})

    def do_PUT(self):
        if not self.path.startswith("/artifacts/"):
            self._write_json(HTTPStatus.NOT_FOUND, {"error": "unknown path"})
            return
        artifact_id = self.path.split("/")[2]
        payload = self._read_json()
        payload["artifactId"] = artifact_id
        STORE.put(artifact_id, payload)
        self._write_json(HTTPStatus.OK, payload)

    def do_POST(self):
        if not self.path.startswith("/artifacts/") or not self.path.endswith("/replicas"):
            self._write_json(HTTPStatus.NOT_FOUND, {"error": "unknown path"})
            return
        parts = self.path.split("/")
        artifact_id = parts[2]
        payload = self._read_json()
        record = STORE.add_replica(artifact_id, payload)
        if not record:
            self._write_json(HTTPStatus.NOT_FOUND, {"error": "artifact not found"})
            return
        self._write_json(HTTPStatus.OK, record)


def main():
    server = ThreadingHTTPServer(("0.0.0.0", PORT), Handler)
    print(f"catalog listening on :{PORT}", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
