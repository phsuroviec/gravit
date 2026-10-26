#!/bin/sh
# check-secrets.sh: refuse to commit credentials.
#
# Scans staged changes (or the whole tree with --all) for key-shaped strings that
# belong outside this repository. Exit 1 blocks the commit.
#
#   sh scripts/check-secrets.sh          # staged files (used by the pre-commit hook)
#   sh scripts/check-secrets.sh --all    # whole working tree
set -eu

cd "$(dirname "$0")/.."
if [ "${1:-}" = "--all" ]; then
  files=$(git ls-files)
else
  files=$(git diff --cached --name-only --diff-filter=ACM)
fi
[ -n "$files" ] || exit 0

# Key-shaped patterns. Extended regex, one per line, comments allowed.
PATTERNS='LLM\|[0-9]+\|[A-Za-z0-9_-]{16,}
sk-[A-Za-z0-9]{20,}
ghp_[A-Za-z0-9]{20,}
gho_[A-Za-z0-9]{20,}
github_pat_[A-Za-z0-9_]{20,}
xox[baprs]-[A-Za-z0-9-]{10,}
AKIA[0-9A-Z]{16}
-----BEGIN [A-Z ]*PRIVATE KEY-----
[A-Za-z0-9_]*(API_KEY|SECRET|TOKEN|PASSWORD)[A-Za-z0-9_]*[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"']{12,}'

status=0
for f in $files; do
  [ -f "$f" ] || continue
  case "$f" in
    *.png|*.jpg|*.jpeg|*.webp|*.ogg|*.wav|*.mp3|*.ttf|*.otf|*.glb|*.blend) continue ;;
  esac
  echo "$PATTERNS" | while IFS= read -r pat; do
    [ -n "$pat" ] || continue
    if grep -nEI -- "$pat" "$f" >/tmp/g-secret-hit 2>/dev/null; then
      echo "SECRET? $f: $(head -1 /tmp/g-secret-hit | cut -c1-120)" >&2
      exit 1
    fi
  done || status=1
  case "$f" in
    .env.example|*.example) : ;;   # template with empty values is allowed
    .env|.env.*|*.pem|*.key|*id_rsa*|*auth.json)
      echo "REFUSED $f: credential files never belong in this repo" >&2
      status=1 ;;
  esac
done

if [ "$status" -ne 0 ]; then
  echo "" >&2
  echo "Commit blocked. Move the value to the host env file (~/.ccgram/.env) and out of the diff." >&2
  exit 1
fi
echo "secret scan clean"
