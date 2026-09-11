#!/usr/bin/env bash
# Definition of done for this project. The FACTORY-lite Stop gate runs this before Claude stops.
# Keep it honest: never weaken a check to make it pass. Change what "done" means on purpose only.
set -euo pipefail
PROFILE="${HARNESS_PROFILE:-lite}"   # lite | strict   (/factory-lite:harden flips this to strict)

echo "== prove ($PROFILE) =="

# ---- pre-alpha: exactly ONE check that proves the walking skeleton runs end to end ----
# Replace the two lines below with the real check from SPEC.md "Proven by". Examples:
#   python -m app --demo | grep -q "OK"
#   npm run build >/dev/null && node dist/cli.js --selftest
echo "TODO: write the walking-skeleton check in prove.sh (see SPEC.md 'Proven by')" >&2
exit 1

if [ "$PROFILE" = "strict" ]; then
  # ---- hardening: the full definition of done ----
  # pytest -q                      # or: npm test
  # ruff check . && mypy .         # or: npm run lint && npx tsc --noEmit
  # ! git diff --cached | grep -nEi '(api|secret|access)[_-]?key\s*[:=]\s*["'"'"'][A-Za-z0-9]{16,}'
  :
fi

echo "== prove: PASS =="
