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
   every tool call unconditionally. An extension owns that hook and will rewrite the file, so
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
- **Status:** waiting (one project's evidence; a second confirms it is the skill and not a fluke)
