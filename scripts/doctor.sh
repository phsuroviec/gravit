#!/bin/sh
# doctor.sh: is this machine ready to build Gravit?
#
# Checks the toolchain, the Meta key plumbing and the repo state. Run it before a
# build session; it never prints a secret. Exit 0 = ready.
set -u
cd "$(dirname "$0")/.."
fail=0
say() { printf '%-34s %s\n' "$1" "$2"; }
bad() { say "$1" "$2"; fail=1; }

# --- toolchain -------------------------------------------------------------
if command -v godot >/dev/null 2>&1; then
  v=$(godot --version 2>/dev/null | head -1)
  say "godot (CLI/headless)" "$v"
else
  bad "godot (CLI/headless)" "missing - install to ~/.local/bin/godot"
fi
if command -v godot >/dev/null 2>&1; then
  if godot --headless --path game --quit >/tmp/gravit-godot.log 2>&1; then
    say "game/ opens headless" "ok"
  else
    # "no main scene" is expected before day 1; anything else is a real error
    if grep -q 'no main scene defined' /tmp/gravit-godot.log; then
      say "game/ opens headless" "ok (no main scene yet)"
    else
      bad "game/ opens headless" "$(tail -1 /tmp/gravit-godot.log)"
    fi
  fi
fi
python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3,10) else 1)' \
  && say "python3 >= 3.10" "$(python3 -V 2>&1 | cut -d' ' -f2)" \
  || bad "python3 >= 3.10" "too old"

# --- Meta key plumbing (never echo the value) ------------------------------
if python3 scripts/meta_generate.py --check >/tmp/gravit-key.log 2>&1; then
  say "MODEL_API_KEY" "$(grep -o 'present: .*' /tmp/gravit-key.log)"
else
  bad "MODEL_API_KEY" "absent - add it to ~/.ccgram/.env (never to this repo)"
fi
if command -v pi >/dev/null 2>&1; then
  if pi --list-models 2>/dev/null | grep -q '^meta .*muse-spark-1.3'; then
    say "pi knows the meta provider" "ok (muse-spark-1.3)"
  else
    bad "pi knows the meta provider" "missing - check ~/.pi/agent/models.json"
  fi
fi

# --- repo state ------------------------------------------------------------
say "ledger rows" "$(grep -c . docs/meta-usage.jsonl 2>/dev/null || echo 0)"
if sh scripts/check-secrets.sh --all >/tmp/gravit-secrets.log 2>&1; then
  say "secret scan" "clean"
else
  bad "secret scan" "$(tail -1 /tmp/gravit-secrets.log)"
fi
if [ -f docs/meta-proof.md ]; then say "proof page" "present"; else bad "proof page" "run scripts/meta-proof.sh"; fi

echo
[ "$fail" -eq 0 ] && echo "ready." || echo "not ready (see lines above)."
exit "$fail"
