# BACKLOG (harness wishes)

Every "FACTORY should do X" thought from inside a project lands here, never in that
project's harness. Items are reviewed after a project ships its pre-alpha. An item is built
only when it has evidence; until then it waits, and that is fine.

Format per item:
- **Wish:** what the harness should do
- **Assumption it encodes:** what the model can't do on its own that makes this necessary
- **Evidence:** the bug it would have prevented, or the second and third project that needed it
- **Delete when:** the condition under which this component should be removed again
- **Status:** waiting | built in vX.Y.Z | rejected (why)

## Environment chores (not harness components — nothing here enters the plugin)

Noted in Step 4, deliberately deferred. None of these is a FACTORY component; they are machine
settings that change what the harness can be trusted to prove.

1. **Turn off machine-wide auto-accept.** `~/.claude/settings.json` has
   `permissions.defaultMode: "auto"` plus an `_autoAcceptManaged` `PreToolUse` hook that allows
   every tool call unconditionally. **Step 5 found a third path:**
   `~/.claude/settings.local.json` carries `defaultMode: bypassPermissions` *and* its own copy of
   that same hook — so the `bypassPermissions` Step 1 removed from the VS Code machine settings is
   back, in a different file. Fixing one path does not fix the others. An extension owns that hook and will rewrite the file, so
   disable the extension in VS Code rather than hand-editing. **Deadline: before Step 7**, the
   first real project — harness work is cheap to get wrong, a real project is not. Until then,
   the template's permissions block is inert and no permission rule on this machine is testable.
2. **Delete `~/dev/.claude/settings.local.json`.** Stale leftover from Step 0, when `~/dev` was
   briefly its own project: it references a Desktop zip and a `~/dev/.git` that no longer exists.
   Whether a parent directory's local settings reach a child project is unverified (see chore 1 —
   it cannot be tested while auto-accept is on), and the file can only ever *grant*, so deleting
   is strictly safer either way.
3. **Prune `~/dev/factory-lite/.claude/settings.local.json`.** Two entries this build wrote and
   nothing needs: `Bash(rm -rf /home/drew/dev/scratch-hello *)`, pointing at a project that no
   longer exists, and `Bash(claude config *)`, granted for a call that turned out not to be a
   subcommand at all.

## Items

### 1. `/factory-lite:spec` should fill CLAUDE.md's title and one-liner, not just Run/prove
- **Wish:** the `spec` skill already rewrites the "Run / prove" lines; it should also replace
  `# <project name>` and the `<One sentence: what this is and for whom.>` placeholder.
- **Assumption it encodes:** none about the model — it is a gap in the skill's instruction, which
  names only the Run/prove lines.
- **Evidence:** Step 4, scratch-hello. After a full `/factory-lite:spec` run that produced a
  detailed SPEC.md, `CLAUDE.md` still opened with the literal `# <project name>` and the
  placeholder sentence. Every project would start with an unfilled header that the always-loaded
  file carries into every session.
- **Delete when:** n/a — if built, it is one clause in `skills/spec/SKILL.md`, not a component.
- **Status:** waiting (one project's evidence; a second confirms it is the skill and not a fluke).
  **In tension with item 2** — if `spec` is deleted, this item dies with it. Step 5 produced no
  second sighting: CLAUDE.md's title *was* filled, but by `brainstorming`, not by `spec`.

### 2. Delete `/factory-lite:spec` — Superpowers' brainstorming does the job better
- **Wish:** remove `skills/spec/SKILL.md` from the plugin and let `superpowers:brainstorming` write
  `SPEC.md`, which it already does unprompted when the template file is present.
- **Assumption it encodes:** the current `spec` skill assumes phase changes need FACTORY's own
  ritual. Step 5 suggests the ritual is the *artifact* (`SPEC.md` + `Phase:`), not the interview,
  and the artifact survives deletion because it lives in `template/`.
- **Evidence:** Step 5, scratch-super. `/superpowers:brainstorming` ran three rounds of
  `AskUserQuestion` with real scope pushback and wrote a SPEC.md with 9 checkable requirements, a
  9-item out-of-scope list, and a byte-for-byte fixture diff as "Proven by" — better than anything
  `spec` has produced. `/factory-lite:spec` then ran, found nothing to do, and said so. It also
  never wrote its own competing `docs/superpowers/specs/` design doc. **Caveat that Step 7 must
  close:** it was stopped by the human right after the CLAUDE.md edit, with its own steps 7-9
  (including `invoke writing-plans`) still ahead of it — so we do **not** yet know whether it
  would have handed off to a competing plan document. Let it run to its own end before acting.
- **Delete when:** n/a — this *is* a deletion. **Trigger to act:** if brainstorming again writes a
  correct `SPEC.md` unprompted in Step 7's first real project, delete `spec` in that release. One
  observation is not enough; deletions get the same evidence bar as additions.
- **Status:** waiting (one project's evidence). Counter-argument to weigh at Step 7: `spec` costs
  ~50 tok always-on, is command-only, and is the only guarantee the artifact gets written in a
  project where Superpowers is not installed.

### 3. Trim `verify` item 2 — Superpowers says it better
- **Wish:** cut or shorten item 2 of `skills/verify/SKILL.md` ("show evidence, don't assert").
- **Assumption it encodes:** that Claude will assert success without running the command. Still
  true — but no longer FACTORY's job to say.
- **Evidence:** Step 5. `superpowers:verification-before-completion` covers exactly this across an
  Iron Law, a gate function, and two rationalization tables. FACTORY's one sentence is strictly
  dominated. Items 1, 3 and 4 have no Superpowers equivalent and stay.
- **Delete when:** n/a — a trim, not a component.
- **Status:** waiting (do it in the same release as item 2, if item 2's trigger fires — one edit to
  the skill, one bump, not two)
