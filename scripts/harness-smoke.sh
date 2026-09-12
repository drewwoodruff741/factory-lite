#!/usr/bin/env bash
# Smoke-test FACTORY-lite itself. Run before tagging a release. Exit 0 = safe to ship.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
gate="$here/hooks/stop-gate.sh"
tmp="$(mktemp -d)"; export TMPDIR="$tmp"; trap 'rm -rf "$tmp"' EXIT
fail() { echo "FAIL: $*"; exit 1; }
command -v jq >/dev/null 2>&1 || echo "warn: jq not found; the gate falls back to CLAUDE_PROJECT_DIR/PWD for cwd"

# --- a throwaway project from the template ---
proj="$tmp/proj"; mkdir -p "$proj"; ( cd "$proj" && git init -q )
export CLAUDE_PROJECT_DIR="$proj"   # what Claude Code exports for hooks; the gate's fallback when jq is absent
"$here/scripts/init.sh" "$proj" >/dev/null

# 1. The untouched template placeholder -> gate is dormant (exit 0) and says so.
#    Gating here would block the first turn of a fresh project before any code exists (Step 4).
out="$(printf '{"cwd":"%s","session_id":"smoke1","stop_hook_active":false}' "$proj" | bash "$gate" 2>/dev/null)" \
  || fail "gate blocked on the untouched template placeholder"
printf '%s' "$out" | grep -q dormant || fail "a dormant gate must announce itself"

# 1b. A real check that fails -> gate blocks (exit 2). This is the contract that matters.
printf '#!/usr/bin/env bash\necho "real check failed" >&2\nexit 1\n' > "$proj/prove.sh"; chmod +x "$proj/prove.sh"
rc=0
printf '{"cwd":"%s","session_id":"smoke1b","stop_hook_active":false}' "$proj" | bash "$gate" 2>/dev/null || rc=$?
[ "$rc" -eq 2 ] || fail "expected exit 2 for a failing prove.sh, got $rc"

# 2. Passing prove.sh -> gate exits 0
printf '#!/usr/bin/env bash\nexit 0\n' > "$proj/prove.sh"; chmod +x "$proj/prove.sh"
printf '{"cwd":"%s","session_id":"smoke2","stop_hook_active":false}' "$proj" | bash "$gate" || fail "gate blocked a passing prove.sh"

# 3. Unchanged tree after a pass -> gate does not re-run prove.sh (chat-only turns stay cheap)
runs="$tmp/runs"; : > "$runs"
printf '#!/usr/bin/env bash\necho run >> %s\nexit 0\n' "$runs" > "$proj/prove.sh"
printf '{"cwd":"%s","session_id":"smoke3","stop_hook_active":false}' "$proj" | bash "$gate" || fail "pass run failed"
printf '{"cwd":"%s","session_id":"smoke3","stop_hook_active":false}' "$proj" | bash "$gate" || fail "second run failed"
[ "$(wc -l < "$runs")" -eq 1 ] || fail "gate re-ran prove.sh on an unchanged tree ($(wc -l < "$runs") runs)"

# 4. No prove.sh -> no gate (exit 0)
rm "$proj/prove.sh"
printf '{"cwd":"%s","session_id":"smoke4"}' "$proj" | bash "$gate" || fail "gate blocked with no prove.sh"

# 5. Loop guard: 3 consecutive blocks -> hands back to the human with exit 0
printf '#!/usr/bin/env bash\nexit 1\n' > "$proj/prove.sh"; chmod +x "$proj/prove.sh"
for i in 1 2 3; do
  rc=0; printf '{"cwd":"%s","session_id":"smoke5","stop_hook_active":%s}' "$proj" "$([ $i -eq 1 ] && echo false || echo true)" | bash "$gate" 2>/dev/null || rc=$?
  [ "$rc" -eq 2 ] || fail "block $i: expected exit 2, got $rc"
done
out="$(printf '{"cwd":"%s","session_id":"smoke5","stop_hook_active":true}' "$proj" | bash "$gate" 2>/dev/null)" || fail "4th attempt should exit 0"
printf '%s' "$out" | grep -q systemMessage || fail "4th attempt should return a systemMessage"

# 6. Manifests are valid JSON
for j in "$here"/.claude-plugin/plugin.json "$here"/.claude-plugin/marketplace.json "$here"/hooks/hooks.json "$here"/template/.claude/settings.json; do
  python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$j" || fail "invalid JSON: $j"
done

# 7. Budget: CLAUDE.md template stays short; every skill/agent has name + description frontmatter
[ "$(wc -l < "$here/template/CLAUDE.md")" -le 60 ] || fail "template/CLAUDE.md is over 60 lines"
for f in "$here"/skills/*/SKILL.md "$here"/agents/*.md; do
  grep -q '^name:' "$f" && grep -q '^description:' "$f" || fail "frontmatter missing in $f"
done

echo "harness smoke: PASS"
