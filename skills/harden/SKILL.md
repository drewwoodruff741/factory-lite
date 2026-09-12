---
name: harden
description: Graduate a project from pre-alpha to hardening. Run with /factory-lite:harden once ./prove.sh passes on the walking skeleton. This is where deliberate engineering starts.
disable-model-invocation: true
---
Work through this checklist in order and stop at the first step that fails.

1. Confirm `./prove.sh` passes and every item under "Definition of pre-alpha done" in the
   `pre-alpha` skill is true. If not, report what's missing and stop.
2. Have the `reviewer` subagent review the skeleton against SPEC.md. Fix P0/P1 findings first.
3. In SPEC.md change `Phase: pre-alpha` to `Phase: hardening`. In `./prove.sh` change the
   `PROFILE=` default from `lite` to `strict`, leaving the `HARNESS_PROFILE` override intact.
4. Turn SPEC.md `## Deferred` into a ranked backlog. For each item add one line of evidence:
   the bug it would have prevented, or the second and third concrete use that now exists.
   Items with no evidence stay deferred. Do not build anything in this step.
5. Extend `./prove.sh` for the new phase so the gate matches what "done" now means: the real
   test suite, lint, typecheck, and a secrets check — each one this stack actually has, and no
   tool the project's constraints forbid. A check with no tool installed is recorded in SPEC.md
   `## Deferred` with that as its reason; never fake one to complete the list. Run it; it must
   still pass, and each new check must be shown to fail on a broken input before you trust it.
6. Only now start structural work: one backlog item at a time, each proven by `./prove.sh`,
   each reviewed by the `reviewer` subagent, each in its own branch or worktree.
7. If a rule keeps being broken during hardening, add it to CLAUDE.md as one line. Fix the
   principle, not the example.
