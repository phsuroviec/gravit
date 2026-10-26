# --- attribution audit -------------------------------------------------------
# Counts the meta-model markers in the tree and flags assets that carry a
# generation sidecar. Run before submission to prove what Meta models produced.
#
#   sh scripts/check-attribution.sh
# -----------------------------------------------------------------------------
set -eu
cd "$(dirname "$0")/.."

echo "== markers by model =="
grep -rhoE "meta-model: *[A-Za-z0-9.\-]+" --include='*.gd' --include='*.py' --include='*.md' \
  --include='*.tscn' --include='*.json' --include='*.ts' . 2>/dev/null \
  | sed 's/meta-model: *//' | sort | uniq -c | sort -rn || true

echo
echo "== unclosed blocks (header without footer) =="
headers=$(grep -rlE "meta-model: *[A-Za-z0-9.\-]+" --include='*.gd' --include='*.py' --include='*.ts' . 2>/dev/null || true)
for f in $headers; do
  h=$(grep -cE "meta-model: *[A-Za-z0-9.\-]+" "$f" || true)
  t=$(grep -c "end meta-model" "$f" || true)
  [ "$h" -gt "$t" ] && echo "  $f: $h header(s), $t footer(s)"
done
echo "  (markdown blocks use HTML comments; they are not counted here)"

echo
echo "== assets with generation sidecars =="
find . -name '*.meta.md' -not -path './.git/*' | sort || true
