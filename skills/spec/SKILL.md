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
the file (keep every heading; leave `## Deferred` empty). Set `Phase: pre-alpha`.
Then update the "Run / prove" lines in CLAUDE.md to match. Do not write any code and do not
create any other documents.
