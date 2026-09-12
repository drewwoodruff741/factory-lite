#!/usr/bin/env bash
# FACTORY-lite Stop gate.
#
# Assumption this encodes: Claude will sometimes say "done" before ./prove.sh passes.
# Evidence: every pre-alpha push where "looks done" wasn't done.
# Delete when: a project runs to completion with this HOOK removed, the `verify` skill and
#   CLAUDE.md's verify rule left in place, and ./prove.sh still runs before every stop. A removal
#   experiment, not a tally, and it is staged on purpose: template/CLAUDE.md ships "before stopping
#   after a code change, run ./prove.sh" to every project, so *something* always asks besides this
#   hook. That is not a confounder to design around, it is the question -- if the prose alone keeps
#   the check running, the hook is the redundant component and the prose is the cheaper one that
#   survives. What the experiment must never conclude is that neither is needed; it compares two
#   FACTORY components, it does not test the model bare.
#   RUN ONCE, 2026-09-12, on a real project's hardening item, and this gate survived it:
#   ./prove.sh ran before every stop with this hook removed and the prose left in place, so the
#   prose alone kept the check running. That is one data point and not a demonstration -- two stops
#   is not a sample, and the session knew it was being measured -- so the hook stays, now on one
#   run's worth of evidence instead of none. Full record in BACKLOG.md item 7.
#   HOW to run it, because no other document says so and two of the three obvious ways are invalid
#   against the "keep the prose" clause above: uninstalling the plugin takes the `verify` skill with
#   it; a project-scope enabledPlugins entry refuses uninstall outright; and the client's hook UI
#   cannot disable a plugin-supplied hook. Empty the Stop array in this plugin's hooks/hooks.json at
#   the project's pinned install path, and confirm with /reload-plugins reporting one hook fewer.
#   An experiment is an instruction, and an instruction that omits its mechanism is a wish.
#   The old condition -- "prove.sh passes first time on >95% of the stops where the gate ran" --
#   was retired at Step 9 after two projects showed it cannot be read even when counted live:
#   a pass and an unchanged-tree skip were both a silent exit 0 (fixed below, in the PASS arm);
#   the denominator is stops, and it collapses as sessions run in longer turns; and a gate that
#   never fires because the session pre-empts it produces exactly the tally of one that is not
#   wired at all. Deterrence and absence are indistinguishable from the outside, so the only
#   honest test of this component is taking it away.
#
# Behaviour:
#   - No executable ./prove.sh in the working dir  -> exit 0 (no gate; lite by design)
#   - ./prove.sh is still the template placeholder -> exit 0 with a notice (dormant, see below)
#   - Nothing changed since the last PASS          -> exit 0, silently (don't re-run on chat-only turns)
#   - prove.sh passes                              -> exit 0, says so, and remembers the tree state
#   - prove.sh fails                               -> exit 2 with the tail of its output (Claude keeps working)
#   - 3 consecutive failures in one session        -> exit 0 and hand control back to the human
# Claude Code itself also stops after 8 consecutive Stop-hook blocks, so this cannot loop forever.
set -u

input="$(cat)"
field() {  # $1 = jq path; prints the value, or nothing if absent. Degrades without jq.
  if command -v jq >/dev/null 2>&1; then jq -r "$1 // empty" <<<"$input" 2>/dev/null; return; fi
  case "$1" in
    .stop_hook_active) grep -qE '"stop_hook_active"[[:space:]]*:[[:space:]]*true' <<<"$input" && echo true ;;
    .session_id) sed -nE 's/.*"session_id"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' <<<"$input" | head -n 1 ;;
    *) : ;;  # .cwd may contain escaped characters; fall back to CLAUDE_PROJECT_DIR instead
  esac
}
hash_cmd() { if command -v sha1sum >/dev/null 2>&1; then sha1sum; else shasum; fi; }

cwd="$(field '.cwd')"; [ -z "$cwd" ] && cwd="${CLAUDE_PROJECT_DIR:-$PWD}"
active="$(field '.stop_hook_active')"
sid="$(field '.session_id')"; [ -z "$sid" ] && sid="nosession"

cd "$cwd" 2>/dev/null || exit 0
[ -x ./prove.sh ] || exit 0

# Dormant while ./prove.sh is still the untouched template placeholder, which exits 1 on purpose.
# Evidence (Step 4): gating on it blocks the very first turn of a fresh project — including
# /factory-lite:spec, whose own rule is "write no code" — so the session cannot end cleanly by
# construction. The gate arms itself the moment a real check replaces the TODO.
if grep -q 'TODO: write the walking-skeleton check' ./prove.sh 2>/dev/null; then
  printf '%s\n' '{"systemMessage":"FACTORY gate: dormant. ./prove.sh is still the template placeholder, so nothing is being enforced. It arms as soon as you replace the TODO with the real check from SPEC.md (Proven by)."}'
  exit 0
fi

# Tree state = HEAD + staged/unstaged diff + content of untracked (non-ignored) files.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  state="$( {
    git rev-parse HEAD 2>/dev/null
    git status --porcelain 2>/dev/null
    git diff HEAD 2>/dev/null
    git ls-files --others --exclude-standard 2>/dev/null | git hash-object --stdin-paths 2>/dev/null
  } | hash_cmd | cut -c1-40)"
else
  state="nogit-$(date +%s)"   # not a repo: never skip
fi
marker="${TMPDIR:-/tmp}/factory-gate-${sid}"
count_file="${marker}.count"

if [ -f "$marker" ] && [ "$(cat "$marker")" = "$state" ]; then
  exit 0
fi

count=0; [ -f "$count_file" ] && count="$(cat "$count_file")"
if [ "$active" = "true" ] && [ "$count" -ge 3 ]; then
  rm -f "$count_file"
  printf '{"systemMessage":"FACTORY gate: ./prove.sh still failing after 3 attempts. Stopping so you can look. Run ./prove.sh yourself."}\n'
  exit 0
fi

out="$(./prove.sh 2>&1)"; rc=$?
if [ "$rc" -eq 0 ]; then
  printf '%s' "$state" > "$marker"
  rm -f "$count_file"
  # A pass says so, and the unchanged-tree skip above stays silent. Evidence (Steps 7, 8, v3.2.0):
  # while both were silent, "the gate ran and passed" and "the gate is not wired at all" produced
  # identical transcripts, and settling which one it was cost a human typing /hooks three separate
  # times. One line, only after real work, is the cheapest thing that tells them apart.
  printf '%s\n' '{"systemMessage":"FACTORY gate: ./prove.sh passed."}'
  exit 0
fi

echo $((count + 1)) > "$count_file"
{
  echo "./prove.sh failed (exit $rc). Fix the root cause, re-run ./prove.sh, show the result, then stop."
  echo "Do not weaken or skip a check to make it pass. If the check itself is wrong, say so explicitly."
  echo "--- last 40 lines of ./prove.sh ---"
  printf '%s\n' "$out" | tail -n 40
} >&2
exit 2
