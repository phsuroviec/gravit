#!/usr/bin/env python3
"""Generate one Gravit artefact with a Meta model, and record the receipt.

The point is evidence: every asset or text file produced by a Meta model is
written by this script, which appends a row to docs/meta-usage.jsonl (model,
purpose, response id, token usage, output hash, git commit). The judge-facing
summary is produced by scripts/meta-proof.sh.

Key handling: MODEL_API_KEY is read from the environment. Never pass it on the
command line, never write it into the repo.

Usage
    scripts/meta_generate.py --model muse-spark-1.3 --purpose "room 2 hints" \
        --out game/data/hints_room2.json --prompt prompts/hints_room2.txt
    scripts/meta_generate.py --model muse-image-1.0 --prompt prompts/fold_shell.txt \
        --out assets/fold_shell.png --purpose "fold shell texture"
    scripts/meta_generate.py --check          # is a key present? no network call

Without MODEL_API_KEY the script prints what it would send and exits 0
(dry run), so the pipeline is testable before the credits land.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

BASE = os.environ.get("META_API_BASE", "https://api.meta.ai/v1")
BASETEN_BASE = os.environ.get("BASETEN_API_BASE", "https://inference.baseten.co/v1")
BASETEN_KEY_ENV = "BASETEN_API_KEY"
ENV_FILE = Path(os.environ.get("CCGRAM_ENV_FILE", "~/.ccgram/.env")).expanduser()


def load_key(env_name: str = "MODEL_API_KEY") -> str:
    """API key from the environment, else from the host env file (~/.ccgram/.env).

    The file is the same one the harness reads, so a key pasted there works for this script,
    for `pi`, and for anything else on the node without exporting it into every process.
    env_name selects the wallet: MODEL_API_KEY (Meta) or e.g. BASETEN_API_KEY (open-weight).
    """
    key = os.environ.get(env_name, "").strip()
    if key:
        return key
    try:
        for line in ENV_FILE.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if line.startswith(env_name + "="):
                return line.split("=", 1)[1].strip().strip('"').strip("'")
    except OSError:
        pass
    return ""
ROOT = Path(__file__).resolve().parent.parent
LEDGER = ROOT / "docs" / "meta-usage.jsonl"

TEXT_MODELS = {"muse-spark-1.3", "muse-spark-1.2", "muse-spark-1.1", "muse-wonder-1.0",
               "muse-spark-1.3-contributor", "muse-spark-open-1026"}
IMAGE_MODELS = {"muse-image-1.0"}


def git_commit() -> str:
    try:
        return subprocess.run(["git", "rev-parse", "--short", "HEAD"], cwd=ROOT,
                              capture_output=True, text=True, timeout=10).stdout.strip()
    except (OSError, subprocess.SubprocessError):
        return ""


def post(path: str, payload: dict, key: str, timeout: int = 120, *, provider: str = "meta") -> dict:
    base = BASETEN_BASE if provider == "baseten" else BASE
    auth = f"Api-Key {key}" if provider == "baseten" else f"Bearer {key}"
    req = urllib.request.Request(
        f"{base.rstrip('/')}/{path.lstrip('/')}",
        data=json.dumps(payload).encode(),
        headers={"Authorization": auth, "Content-Type": "application/json",
                 "User-Agent": "gravit-meta-generate/1.0"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return json.load(resp)
    except urllib.error.HTTPError as exc:  # surface the API's own message, not a traceback
        detail = exc.read()[:400].decode("utf-8", "replace")
        sys.exit(f"Meta API error {exc.code}: {detail}")


def append_ledger(row: dict) -> None:
    LEDGER.parent.mkdir(parents=True, exist_ok=True)
    with LEDGER.open("a", encoding="utf-8") as fh:
        fh.write(json.dumps(row, sort_keys=True) + "\n")


def resolve_repo_path(raw: str) -> Path:
    """CLI paths resolve against the repo root, so the script is cwd-independent."""
    p = Path(raw)
    return p if p.is_absolute() else ROOT / p


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--check", action="store_true", help="report key presence and exit")
    ap.add_argument("--spend", action="store_true", help="token totals from the ledger, per model")
    ap.add_argument("--provider", default="meta", choices=["meta", "baseten"],
                    help="meta = Meta Model API; baseten = open-weight Muse Spark Open (free credits)")
    ap.add_argument("--model", help="model id, e.g. muse-spark-1.3 or meta-models/muse-spark-open-1026")
    ap.add_argument("--purpose", default="", help="one line: what this artefact is for")
    ap.add_argument("--prompt", help="file with the prompt (kept in prompts/)")
    ap.add_argument("--out", help="output path (text/JSON for text models, image bytes for image models)")
    ap.add_argument("--reasoning-effort", default=None, choices=["low", "medium", "high", "max", None])
    ap.add_argument("--max-tokens", type=int, default=4000,
                    help="output budget; reasoning tokens eat it first, so keep >= 800")
    ap.add_argument("--key-env", default="MODEL_API_KEY",
                    help="env var holding the key (MODEL_API_KEY, BASETEN_API_KEY, ...)")
    ap.add_argument("--json-schema", help="optional JSON schema file for structured output")
    args = ap.parse_args(argv[1:])

    key_env = "BASETEN_API_KEY" if args.provider == "baseten" else args.key_env
    key = load_key(key_env)
    if args.spend:
        # Token totals only: pricing lives in the provider's Billing page, not in this repo.
        rows = [json.loads(l) for l in LEDGER.read_text().splitlines() if l.strip()] if LEDGER.exists() else []
        per: dict[str, dict[str, int]] = {}
        for r in rows:
            m = per.setdefault(r.get("model", "?"), {"calls": 0, "prompt": 0, "completion": 0, "reasoning": 0})
            u = r.get("usage") or {}
            m["calls"] += 1
            m["prompt"] += u.get("prompt_tokens") or 0
            m["completion"] += u.get("completion_tokens") or 0
            m["reasoning"] += u.get("reasoning_tokens") or 0
        print(f"{'model':28} {'calls':>6} {'prompt':>9} {'completion':>11} {'reasoning':>10}")
        for model, m in sorted(per.items()):
            print(f"{model:28} {m['calls']:6} {m['prompt']:9} {m['completion']:11} {m['reasoning']:10}")
        if not per:
            print("(ledger empty: no Meta calls generated yet)")
        print("\nCost = these tokens x the price shown in the provider's Billing page.")
        return 0
    if args.check:
        print(f"{args.key_env} present:", bool(key))
        print("base:", BASE)
        print("ledger:", LEDGER.relative_to(ROOT), "| rows:", len(LEDGER.read_text().splitlines())
              if LEDGER.exists() else 0)
        return 0 if key else 1
    if not (args.model and args.prompt and args.out):
        ap.error("--model, --prompt and --out are required (or use --check)")

    prompt_path = resolve_repo_path(args.prompt)
    prompt = prompt_path.read_text(encoding="utf-8")
    out_path = resolve_repo_path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)

    if not key:
        endpoint = "images/generations" if args.model in IMAGE_MODELS else "chat/completions"
        print(f"DRY RUN (no {args.key_env}). Would POST", f"{BASE}/{endpoint}")
        print("prompt bytes:", len(prompt.encode()), "-> out:", args.out)
        return 0

    started = time.time()

    if args.model in IMAGE_MODELS:
        resp = post("images/generations", {"model": args.model, "prompt": prompt}, key)
        elapsed = round(time.time() - started, 2)
        import base64
        blocks = resp.get("data") or []
        data = blocks[0].get("b64_json", "") if blocks and isinstance(blocks[0], dict) else ""
        if not data:
            sys.exit("image model returned no b64_json block; inspect the response before writing a file")
        out_path.write_bytes(base64.b64decode(data))
        usage = resp.get("usage") or {}
        append_ledger({
            "ts": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "model": args.model,
        "provider": args.provider,
            "purpose": args.purpose,
            "prompt_sha256": hashlib.sha256(prompt.encode()).hexdigest()[:16],
            "out": str(out_path.relative_to(ROOT)),
            "out_sha256": hashlib.sha256(out_path.read_bytes()).hexdigest()[:16],
            "seconds": elapsed,
            "commit": git_commit(),
        })
        print(f"wrote {out_path.relative_to(ROOT)} ({out_path.stat().st_size} bytes) in {elapsed}s")
        return 0

    payload: dict = {"model": args.model, "messages": [{"role": "user", "content": prompt}],
                    "max_tokens": args.max_tokens}
    if args.reasoning_effort:
        payload["reasoning_effort"] = args.reasoning_effort
    if args.json_schema:
        payload["response_format"] = {
            "type": "json_schema",
            "json_schema": json.loads(resolve_repo_path(args.json_schema).read_text(encoding="utf-8")),
        }

    started = time.time()
    resp = post("chat/completions", payload, key, provider=args.provider)
    elapsed = round(time.time() - started, 2)

    choice = (resp.get("choices") or [{}])[0]
    content = ((choice.get("message") or {}).get("content")) or ""
    out_path.write_text(content if isinstance(content, str) else json.dumps(content, indent=2),
                        encoding="utf-8")

    usage = resp.get("usage") or {}
    append_ledger({
        "ts": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "model": args.model,
        "provider": args.provider,
        "purpose": args.purpose,
        "prompt_sha256": hashlib.sha256(prompt.encode()).hexdigest()[:16],
        "response_id": resp.get("id", ""),
        "usage": {k: usage.get(k) for k in ("prompt_tokens", "completion_tokens", "total_tokens",
                                            "reasoning_tokens") if usage.get(k) is not None},
        "out": str(out_path.relative_to(ROOT)),
        "out_sha256": hashlib.sha256(out_path.read_bytes()).hexdigest()[:16],
        "seconds": elapsed,
        "commit": git_commit(),
    })
    print(f"wrote {out_path.relative_to(ROOT)} ({out_path.stat().st_size} bytes) in {elapsed}s")
    print("usage:", usage)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
