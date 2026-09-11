---
name: verify
description: How to prove a change is done here. Use before stopping after any code change, and whenever asked whether something works.
---
# Verify

1. Run `./prove.sh`. It is the definition of done for the current phase.
   If it fails, fix the root cause. Never weaken, skip, or comment out a check to make it pass;
   if you believe a check is wrong, say so explicitly and let the user decide.
2. Show evidence, don't assert: paste the command you ran and its result (exit code, the
   relevant passing or failing lines, or a screenshot for UI work).
3. For a change that touches more than one file, or any numbered requirement in SPEC.md,
   dispatch the `reviewer` subagent with the diff and SPEC.md, then fix P0 and P1 findings
   before stopping. Skip this for one-line fixes.
4. If `./prove.sh` takes longer than a few minutes, tell the user instead of looping on it.
