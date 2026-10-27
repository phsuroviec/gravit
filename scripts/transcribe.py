#!/usr/bin/env python3
"""Transcribe a voice memo with muse-voice-transcribe-1.0 for demo captions.

Usage:
    scripts/transcribe.py VOICE.m4a [--out docs/demo/vo_transcript.txt]

Writes the transcript plus a ledger receipt (docs/meta-usage.jsonl), same as
scripts/meta_generate.py. Without a key it validates the audio file and prints
what it would send (dry run). Key from MODEL_API_KEY, never in the repo.

Endpoint shape (PARTIALLY mapped 2026-10-26; confirm against real audio):
  POST {BASE}/asr/transcribe, multipart `request` + `audio` parts (enforced).
  An `audioEncoding` field is demanded but its home is unclear. Failures
  print the API message; run once against real audio, lock the 200 shape.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import mimetypes
import os
import sys
import time
import urllib.error
import urllib.request
import uuid
from pathlib import Path

BASE = os.environ.get("META_API_BASE", "https://api.meta.ai/v1")
ROOT = Path(__file__).resolve().parent.parent
LEDGER = ROOT / "docs" / "meta-usage.jsonl"


def load_key() -> str:
    key = os.environ.get("MODEL_API_KEY", "").strip()
    if key:
        return key
    env = Path(os.environ.get("CCGRAM_ENV_FILE", "~/.ccgram/.env")).expanduser()
    try:
        for line in env.read_text(encoding="utf-8").splitlines():
            if line.strip().startswith("MODEL_API_KEY="):
                return line.split("=", 1)[1].strip().strip('"').strip("'")
    except OSError:
        pass
    return ""


def multipart(path: Path, model: str) -> tuple[bytes, str]:
    boundary = uuid.uuid4().hex
    buf = bytearray()
    ctype = mimetypes.guess_type(path.name)[0] or "application/octet-stream"
    request_json = json.dumps({"model": model}).encode()
    buf += (f"--{boundary}\r\nContent-Disposition: form-data; name=\"request\"\r\n"
            f"Content-Type: application/json\r\n\r\n").encode()
    buf += request_json + b"\r\n"
    buf += (f'--{boundary}\r\nContent-Disposition: form-data; name="audio"; filename="{path.name}"\r\n'
            f"Content-Type: {ctype}\r\n\r\n").encode()
    buf += path.read_bytes()
    buf += f"\r\n--{boundary}--\r\n".encode()
    return bytes(buf), f"multipart/form-data; boundary={boundary}"


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("audio", help="voice memo file (m4a/mp3/wav)")
    ap.add_argument("--out", default="docs/demo/vo_transcript.txt")
    ap.add_argument("--model", default="muse-voice-transcribe-1.0")
    args = ap.parse_args(argv[1:])

    src = Path(args.audio)
    if not src.is_file():
        sys.exit(f"no audio file: {src}")
    data = src.read_bytes()
    if not data:
        sys.exit(f"audio file empty: {src}")

    key = load_key()
    if not key:
        print(f"DRY RUN (no MODEL_API_KEY). Would POST {BASE}/asr/transcribe")
        print(f"audio bytes: {len(data)} ({src.name}) -> out: {args.out}")
        return 0

    body, ctype = multipart(src, args.model)
    req = urllib.request.Request(f"{BASE.rstrip('/')}/asr/transcribe", data=body,
                                 headers={"Authorization": f"Bearer {key}", "Content-Type": ctype},
                                 method="POST")
    started = time.time()
    try:
        with urllib.request.urlopen(req, timeout=300) as resp:
            payload = json.load(resp)
    except urllib.error.HTTPError as exc:
        sys.exit(f"Meta API error {exc.code}: {exc.read()[:400].decode('utf-8', 'replace')}")
    elapsed = round(time.time() - started, 2)

    text = payload.get("text", "") if isinstance(payload, dict) else ""
    if not isinstance(text, str) or not text.strip():
        sys.exit("transcription returned no text; inspect the response before writing a file")
    out_path = ROOT / args.out
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(text.strip() + "\n", encoding="utf-8")
    with LEDGER.open("a", encoding="utf-8") as fh:
        fh.write(json.dumps({
            "ts": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "model": args.model,
            "purpose": "demo voice-over transcription",
            "prompt_sha256": hashlib.sha256(data).hexdigest()[:16],
            "out": args.out,
            "out_sha256": hashlib.sha256(out_path.read_bytes()).hexdigest()[:16],
            "seconds": elapsed,
        }, sort_keys=True) + "\n")
    print(f"wrote {args.out} ({len(text)} chars) in {elapsed}s")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
