---
name: pre-alpha
description: How to build the first runnable version of a project. Use whenever SPEC.md says "Phase: pre-alpha" and you are creating files, adding a feature, or proposing structure.
---
# Pre-alpha mode

The goal of this phase is a **walking skeleton**: the thinnest end-to-end slice that
runs and that `./prove.sh` can check. Everything else waits.

## Do
- Build the slice named in SPEC.md under "Walking skeleton" first. Nothing else until `./prove.sh` passes on it.
- Write the `./prove.sh` check before the code it checks. The check is the spec.
- Prefer the most boring solution: one file or module until it hurts, plain functions over classes, hardcode before configuring, inline before abstracting.
- Write code that reads like the surrounding code: match its comment density, naming, and idiom.
- State assumptions and ask when SPEC.md is ambiguous rather than picking an interpretation silently.
- Touch only what the task requires. No drive-by refactors, renames, or "while I'm here" cleanups.
- When you notice something that "should" be generalized, add one line to SPEC.md `## Deferred` instead of building it. That list is the hardening backlog.

## Don't (until SPEC.md says Phase: hardening)
- Introduce an abstraction, base class, plugin system, config layer, or "engine" before there are three concrete uses of it in this codebase.
- Add options, flags, settings, or environment variables nobody asked for.
- Build for a second backend, provider, model, or platform before the first one works end to end.
- Write tests beyond the skeleton check for behavior that doesn't exist yet.
- Create planning, decision, or analysis documents. SPEC.md is the only planning artifact.
- Change the harness (hooks, agents, skills, CLAUDE.md rules) mid-build. Note the wish in `## Deferred`; harness changes happen in FACTORY between projects.

## Definition of pre-alpha done
- `./prove.sh` passes and exercises the skeleton end to end.
- A human can run the skeleton with the one command listed in CLAUDE.md.
- "Out of scope for pre-alpha" in SPEC.md was respected.

When all three are true, tell the user and suggest `/factory-lite:harden`.
