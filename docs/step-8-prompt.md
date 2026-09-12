# Step 8 prompt — paste this whole file into a fresh session

Open `~/dev/coach` in VS Code (**File → New Window → Open Folder**; bottom-left must read
`WSL: Ubuntu`), start a **new** Claude Code session, and paste everything between the rules below.
Nothing needs filling in — Step 7 settled the blanks.

---

CONTEXT FOR THIS SESSION
I am hardening `~/dev/coach`, the first real project built on FACTORY-lite, my minimal Claude Code
harness. The harness is at `~/dev/factory-lite`, v3.2.0, and is a separate repo from this project.

Hard constraints:
- I use ONLY the Claude Code VS Code extension, on VS Code Remote-WSL (WSL2 Ubuntu). I never use
  the Claude Code terminal UI, and I don't want to be handed blocks of shell to paste either: run
  them yourself with your Bash tool (that is not the terminal UI) and hand me only what genuinely
  needs me — a sudo password, a browser login, or a VS Code UI action. Slash commands are typed in
  the extension's chat box; plugin, hook and permission management is under the "/" command menu →
  Customize. Never `claude` alone; `claude --version`, `claude plugin validate .`,
  `claude plugin list` and friends are fine because they print and exit.
- **Client commands must be typed by me, not relayed to you.** `/context`, `/plugin`, `/hooks` and
  `/memory` are rendered by the client; no tool dispatches them. A session asked to "run" them
  reads config files off disk and infers, and gets it wrong — Step 5 concluded the Stop gate "is
  not loaded" while that gate's own message was printing at the end of its turn. Ask me to type
  them and paste back what I see.
- Environment is verified, do not re-check: git 2.53.0, bash 5.3.9, jq 1.8.1, node v22.22.1,
  gh 2.46.0, claude 2.1.269, uv 0.12.9, ruff 0.16.6, python3 3.13.15, stdlib sqlite3 3.53.1.
  **`pytest` is NOT installed** and `uv run pytest` currently fails — adding it as a dev dependency
  is a task in this step, not a surprise. Machine-wide auto-accept was removed in Step 7 (the owner
  was one VS Code extension writing four config paths on every startup); permissions are live, and
  three `notify.js` notifier hooks sit at user scope, so `/hooks` lists more than this project's own.
- Don't re-price anything with `/context`. Step 5 settled the numbers and established that the
  `/context` **Total** cannot be differenced, because `system tools` swings ±2.8k on its own.

What is already true, do not redo or re-interview me about any of it:
- **Steps 1–7 are done.** The harness is published at github.com/drewwoodruff741/factory-lite,
  v3.2.0, tagged and pushed. `~/dev/coach` is at `cabb2f2`, clean, **no git remote** (local only —
  it holds personal data), and its walking skeleton is **running and proven**.
- **The skeleton.** A local single-user Flask app over SQLite: define a food in a personal library,
  log an entry against it for an explicit date, see that day's kcal and macro totals against
  editable targets. `uv run coach` serves 127.0.0.1:8765. Modules: `src/coach/{app,db,nutrition}.py`
  plus templates. `app.py` is a thin shell doing no arithmetic; `nutrition.py` imports neither Flask
  nor sqlite3. `/day/<date>` is the primitive route and `/today` is a redirect over it, so nothing
  below `app.py` reads the clock.
- **`./prove.sh` passes and is load-bearing**, not decorative. The `reviewer` agent mutated
  `nutrition.py` (`targets[m] - totals[m]` → `+`) and the check failed by name:
  `AssertionError: missing '1745'`. Note *which* assertion caught it — the **remainder**, not the
  total. With one entry the row and the totals row render the same string, so a check asserting
  totals alone would have passed a visibly broken page.
- **The Stop gate is armed and verified live.** `/hooks` shows `Stop` carrying two hooks: the
  `notify.js` notifier and `Running ./prove.sh` attributed to `Plugin`.
- **Pre-alpha means the walking skeleton, full stop** — settled in harness v3.2.0 after Step 7
  exposed two conflicting definitions. `SPEC.md`'s six numbered requirements are all met. What were
  requirements 5, 6, 7 and 9 are now the **ranked hardening backlog** at the top of `## Deferred`,
  requirement 9 first. That re-filing is recorded in `SPEC.md` with its reasoning — it is not a
  goalpost move and does not need re-litigating.

STEP 8: Harden coach — deliberate engineering starts here

Goal: turn `## Deferred` into an evidence-ranked backlog and build from it, one item at a time,
with the gate holding a real definition of done.

Read `skills/harden/SKILL.md` (the `/factory-lite:harden` skill) and work its checklist in order,
stopping at the first step that fails. It is the guide; do not rewrite it. The parts below are what
it does not cover.

The session produces:

1. **`/factory-lite:harden` run to completion.** Its step 2 dispatches the `reviewer` agent against
   `SPEC.md`; fix P0 and P1 findings before going further. Its step 3 flips `Phase: pre-alpha` to
   `Phase: hardening` and `PROFILE=lite` to `strict`, leaving the `HARNESS_PROFILE` override intact.

2. **A real strict profile in `./prove.sh`.** This is the substantive decision of the step. The
   commented template lines are placeholders for a generic stack, not instructions. For this one:
   - `pytest` must be added as a dev dependency first (`uv add --dev pytest`); it is not installed.
     `SPEC.md`'s constraints say dev dependencies are unconstrained, so this is allowed.
   - `ruff` 0.16.6 is present. A type checker is not — and harden step 5 is explicit about that
     case: **a check with no tool installed is recorded in `SPEC.md` `## Deferred` with that as its
     reason; never fake one to complete the list.**
   - **Every new check must be shown to FAIL on a broken input before you trust it.** That is not
     optional politeness — it is the only thing separating a check from a decoration, and it is how
     the lite check earned its place. Break something deliberately, watch the check catch it, revert.
   - The lite check stays. Strict is additive.

3. **Three backlog items shipped through the rhythm.** One item at a time, each in its own branch or
   worktree, each proven by `./prove.sh`, each reviewed by the `reviewer` agent before it lands.
   Item #1 is already ranked: **invalid input on any form produces a visible message, never a
   traceback or a 500** — a bad `food_id` or non-numeric servings currently 500s, and it is the one
   thing that makes the tool unusable for real data.

4. **A gate tally, which this step can finally produce.** Step 7 built its whole skeleton in one
   continuous run, so the gate fired at almost no stops and the tally read **0 blocks out of ~1
   stop** — a flawless score from a gate that was never consulted. Hardening ships items one at a
   time against a stricter check, so for the first time there is a real denominator. Keep a running
   count as you go, because **a pass is silent and cannot be reconstructed afterwards**:

   ```
   stops where the gate RAN and passed:   ____
   stops where the gate RAN and blocked:  ____
   3-strike releases:                     ____
   ```

   Also record, one line each: what the gate blocked *on*, and whether it was ever right to be
   annoyed by it. For a delete-when decision the qualitative half matters more than the ratio.
   If you count from a transcript rather than live, two rules apply: a **block** records as
   `type == "system"`, written once; a `dormant`/3-strike announcement records as
   `type == "attachment"`, written **twice** (`.stdout` and `.content`, same timestamp). Mentions in
   `user`/`assistant` records are the gate being discussed, not firing.

Done when: three backlog items have shipped through the rhythm without `./prove.sh` being weakened,
`Phase: hardening` and `PROFILE=strict` are in effect, and the strict profile contains only checks
that have been seen to fail on a broken input.

Guardrails:
- **No new hooks, agents, skills, rules, plugins or MCP servers.** Not one. That is the rule FACTORY
  v2 broke, and "hardening" is not permission to build everything at once — it is permission to
  build *one thing at a time, properly*.
- **Product wishes → `SPEC.md` `## Deferred`. Harness wishes → `~/dev/factory-lite/BACKLOG.md`.
  Neither gets built mid-item.**
- **Never weaken `./prove.sh` to make a problem go away.** If I ask you to, refuse and tell me what
  the check is actually reporting. If you believe a check is genuinely wrong, say so explicitly and
  let me decide. The gate refused exactly this three times in Step 4 and that was the result worth
  having. Expect the strict profile to be slower and to block more often; that is it working.
- **An item with no evidence stays deferred.** Fix the principle, not the example.
- **Do not decide BACKLOG items 4, 5, 6 or 7.** They are deliberately open. Item 7 (the gate cannot
  report its own success, so its >95% delete-when is unmeasurable) is to be weighed at **Step 9**,
  not here — this step's job is to *collect* the data, not to act on it. If this project produces
  real evidence for any of them, add an evidence line and leave the status `waiting`.
- **Harness changes, if the harness is genuinely broken:** from `~/dev/factory-lite`, never from
  this project, under the release rule at the top of its `BACKLOG.md`. That repo now has its own
  `prove.sh` and its own armed Stop gate, so the rule enforces itself — run it and believe it.
  Remember that projects clone `main` shallow at depth 1 and never fetch tags, so **every push to
  `main` reaches this project immediately**. Don't push work in progress.

---
