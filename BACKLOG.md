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
