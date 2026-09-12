---
name: spec
description: Interview the user and write SPEC.md for a new project or feature. Run with /factory-lite:spec <one-line idea>. Writes no code.
disable-model-invocation: true
---
Interview me about this idea: $ARGUMENTS

Use the AskUserQuestion tool. Don't ask obvious questions; dig into the hard parts:
- What is the single walking-skeleton slice: one input, one output, one command that runs it?
- What is the one check that proves it ran (this becomes the first line of `./prove.sh`)?
- What is explicitly out of scope for pre-alpha? Push for a real list, including things I will be tempted to build.
- What can't change (constraints, non-negotiables) versus what is just a preference?
- What are the two or three hardest parts I haven't mentioned?

Keep interviewing until those are answered, then write SPEC.md using the sections already in
the file, keeping every heading. Set `Phase: pre-alpha`.

Scope the requirements to the walking skeleton and nothing else — pre-alpha ends when the skeleton
walks. Everything the skeleton doesn't need goes in `## Deferred` now, at spec time, rather than
swelling the requirement list; `## Out of scope` is for what you are refusing to build at all.
Nothing belongs on both lists.
Then update CLAUDE.md to match: replace `# <project name>` with the real name, replace the
`<One sentence: what this is and for whom.>` placeholder, and fill the "Run / prove" lines. All
three, not just the commands — CLAUDE.md is loaded into every session, so a placeholder left
there is carried for the life of the project. Do not write any code and do not create any other
documents.
