#!/usr/bin/env bash
# Definition of done for FACTORY-lite itself. The Stop gate this repo ships runs this before
# Claude stops here, exactly as it does in a project built from the template.
#
# Assumption it encodes: the release rule at the top of BACKLOG.md is prose, and prose that
#   depends on remembering gets skipped under exactly the pressure it exists for.
# Evidence: Step 7, 2026-09-12. The rule says run the smoke test and the four validate calls
#   *before* committing. It was broken twice in one session — the same session that was auditing
#   the harness for this class of defect — and nothing noticed, because factory-lite was the one
#   repo where the gate had nothing to run and the plugin was never even enabled.
# Delete when: never, while the harness ships a Stop gate to other projects. A harness that will
#   not run its own gate has no standing to claim the gate is cheap.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

echo "== prove (harness) =="

# 1. The harness smoke test: builds a throwaway project from the template and asserts the gate,
#    the skills and the plugin manifests all load. Release rule step 1.
bash scripts/harness-smoke.sh

# 2. All four validate calls. `validate .` covers only the *marketplace* manifest — the repo root
#    holds both and the marketplace wins — so the plugin manifest and the components need their
#    own. Release rule step 2. Each exits non-zero on failure, not merely printing.
claude plugin validate .
claude plugin validate .claude-plugin/plugin.json --strict
claude plugin validate skills --strict
claude plugin validate agents --strict

# 3. The two manifests must agree on the version. This is release rule step 3's named failure
#    mode -- "bumping one leaves the two disagreeing about what the release is" -- and it is the
#    one part of the rule that leaves no trace when you get it wrong: every diagnostic keeps
#    reporting a version, just not the same one.
plugin_version="$(jq -r '.version' .claude-plugin/plugin.json)"
market_version="$(jq -r '.metadata.version' .claude-plugin/marketplace.json)"
if [ "$plugin_version" != "$market_version" ]; then
  echo "version mismatch: plugin.json=$plugin_version marketplace.json=$market_version" >&2
  echo "Bump BOTH, or the release number stops meaning anything." >&2
  exit 1
fi
echo "version: $plugin_version (both manifests agree)"

echo "== prove: PASS =="
