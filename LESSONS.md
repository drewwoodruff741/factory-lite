# LESSONS (from FACTORY v2)

The only thing carried over from v2. Evidence, not code. Each line here is the reason a
component in v3 exists or the reason one will never be added. Fill it from memory in one
sitting; if you can't remember a rule, it wasn't load-bearing.

## Startup cost of v2 (for comparison)
Measured 2026-09-11 in `devFinanceBot`, the most active v2 project, fresh session, claude 2.1.269.
- `/context` total: **46.8k / 1.0M (5%)** — of which 4.0k was the conversation itself, so
  **startup ≈ 42.8k**, i.e. **~10.5k above the 32.3k empty-folder floor**.
- Where the 10.5k went: `CLAUDE.md` 5.1k · three always-on `.claude/rules/` files 4.3k
  (`finance-invariants` 2.7k, `git-safety` 943, `proof-integrity` 682) · five custom agents 1.3k
  (`doubter`, `lead`, `implementer`, `planner`, `tester`).
- **The headline finding: v2 did not bite by eating the context window.** 10.5k is cheap. It bit
  through *behaviour* — five job-title agents, three always-on rules, and a proof suite that never
  fired correctly. **Cheapness is why they survived**: nothing ever made them expensive enough to
  question. So v3 cannot declare victory on the `/context` number alone; the comparison in Steps 4
  and 5 is necessary but not sufficient.

## Empty-folder baseline (v3 measuring stick, 2026-09-11)
Fresh session in an empty git folder, no plugins, no CLAUDE.md, claude 2.1.269, opus-5 1M window.
This is the floor: anything above it is something we chose to load.
- **Total 32.3k / 1.0M (3%)** — system prompt 4.2k · system tools 25.4k · skills 2.8k
- Read it as: the harness budget is what a project adds *on top of 32.3k*, not the raw number.
- **The 15%-of-window rule in START-HERE Step 5 does not survive a 1M window** (15% = 150k, which
  no sane harness reaches). Judge startup cost in absolute tokens against this baseline instead.

## What bit us
Format: what happened → what it cost → what it taught.
- **Over-engineering by accretion.** v2 was built for one specific task, branched into a factory,
  and then had efficiencies and hardening layered on top — a sandbox, an excessive number of
  proofs, a model that hallucinated problems to solve. Each addition sounded great on paper; the
  sum was a cumbersome mess. → It cost time and tokens on **every single prompt**, and eventually
  the output could no longer be trusted. → Harness overhead is charged per prompt, not once, and
  the first thing it buys is distrust. A component that is merely defensible is not worth its
  per-prompt rent.
- **The model editorialized instead of finishing.** Every output read "I did this, and also fixed
  this because I noticed that, and I suggest this instead, and I noticed three things over here,
  so now let me pivot to those" — instead of "I did it." → Time, tokens, trust. → The same three
  every time. A turn that ends in a pivot proposal is a turn you have to audit before you can use
  it.

## What we kept trying to add and never used
- **Rules and hooks.** Added steadily across v2's life. **I could not name one of them if asked**
  — which is the whole test: a rule you cannot recall was never load-bearing, it was just resident.
- **Tests that wouldn't fire correctly.** A body of proofs existed, didn't run right, and was never
  fixed — so the harness carried the cost of having tests and none of the confidence.
- **Nothing from v2 is recitable from memory.** Asked directly at the freeze, not one rule, hook,
  or skill could be recalled unprompted. v2 was archived without excavating them on purpose: the
  only rules worth carrying to v3 are the ones that were still in my head.

## Things that were actually project-specific and lived in the harness by mistake
- **The harness itself.** v2 was project-specific *by origin* — built for one task, then branched
  into a general factory without ever re-examining what should have stayed behind with the
  original job. No individual piece can be named as the culprit, because the boundary was never
  drawn. → In v3, a component enters FACTORY only with evidence from a shipped project, and
  anything that smells like one project's need lives in that project.

## From building v3 itself
Findings from the build steps, not from v2. Kept here because they are evidence the later steps
depend on.
- **Step 1:** the WSL machine settings (`~/.vscode-server/data/Machine/settings.json`) had
  `claudeCode.initialPermissionMode: bypassPermissions` — every session started with permissions
  bypassed. Removed. It taught: check the *machine* settings, not just project settings, before
  trusting what Step 4 shows you about the Stop gate.
- **Step 1:** the step-1 sub-guide initially asked for `npm`, which is not in the stack. Ubuntu
  26.04 ships `nodejs` without it, and `pnpm` is per-project via corepack. It taught: the drift the
  Context block blocks also arrives inside the sub-guides, not only from the sessions that use them.
