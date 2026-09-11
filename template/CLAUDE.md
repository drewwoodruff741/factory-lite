# <project name>

<One sentence: what this is and for whom.> Phase, scope, and the walking skeleton live in
SPEC.md; read it first.

## Run / prove
- Run: `<the one command that runs the skeleton>`
- Prove (definition of done): `./prove.sh`
- Tests: `<command, once they exist>`

## Gotchas
<!-- Only things Claude can't infer by reading the code: required env vars, ports, the
     directory that is generated, the thing that bit you last time. Delete this comment. -->
-

## How we work here
- Pre-alpha until SPEC.md says otherwise: walking skeleton first, simplest thing that works,
  surgical changes. The `pre-alpha` skill has the details.
- Before stopping after a code change, follow the `verify` skill: run `./prove.sh`, show evidence.
- Never weaken `./prove.sh` to make it pass. Add to SPEC.md `## Deferred` instead of generalizing early.
- Commit small and often with descriptive messages; one concern per commit.
