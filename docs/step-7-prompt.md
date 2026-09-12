# Step 7 prompt — paste this whole file into a fresh session

Open `~/dev/factory-lite` in VS Code, start a **new** Claude Code session (not a continued one),
and paste everything between the rules below. **Fill in the two blanks at the end of the STEP 7
section first** — the idea and the language. The session cannot start without them.

---

CONTEXT FOR THIS SESSION
I am building FACTORY-lite, a minimal Claude Code harness, from a scaffold I already have.
You are writing me a step-by-step sub-guide for ONE step of the plan, then helping me execute it.

Hard constraints:
- I use ONLY the Claude Code VS Code extension, on VS Code Remote-WSL (WSL2 Ubuntu). I never use
  the Claude Code terminal UI, and I don't want to be handed blocks of shell to paste either:
  run them yourself with your Bash tool (that is not the terminal UI) and hand me only what
  genuinely needs me — a sudo password, a browser login, or a VS Code UI action. Slash commands
  are typed in the extension's chat box; plugin, hook, memory, and permission management is under
  the "/" command menu → Customize, whose contents vary by release (there is no model entry on
  2.1.269 — type /model instead). Never `claude` alone; `claude --version`,
  `claude plugin validate .`, `claude plugin install …` and friends are fine because they print
  and exit.
- **Client commands must be typed by me, not relayed to a session.** `/context`, `/plugin`,
  `/hooks` and `/memory` are rendered by the client; no tool dispatches them. Step 5 asked a
  session to "run" them and got an agent reading config files off disk and inferring — it
  concluded the Stop gate "is not loaded" while that very gate's message was printing at the end
  of its own turn. Ask me to type them and to paste back what I see.
- Environment already verified in Step 1, do not re-check: git 2.53.0, bash 5.3.9, jq 1.8.1,
  node v22.22.1, gh 2.46.0 (logged in as drewwoodruff741), claude 2.1.269, core.autocrlf=input,
  core.eol=lf, .gitattributes pins LF. Empty-folder /context baseline is 32.3k of a 1M window —
  but the /context **Total** cannot be differenced, because `system tools` swings ±2.8k on its
  own. Price a harness by summing the buckets you control. Two extension quirks: /context prints
  no path line, and a folder needs at least one file in it before the extension will open a
  session there.
- **Machine-wide auto-accept is a blocker for this step, not a footnote.** Permissions are
  disarmed by three separate mechanisms: `~/.claude/settings.json` `permissions.defaultMode:
  "auto"`, a user-scope `PreToolUse` hook `~/.claude/hooks/auto-accept-hook.sh` that allows every
  call, and `~/.claude/settings.local.json` carrying `defaultMode: bypassPermissions` plus its own
  copy of that hook. Step 1 removed `bypassPermissions` from the VS Code machine settings and it
  came back elsewhere; an extension owns that hook and rewrites the file, so the fix is to disable
  that extension in VS Code, not to hand-edit. BACKLOG chore 1 set the deadline at **before Step
  7** — this step — on the reasoning that harness work is cheap to get wrong and a real project is
  not. Deal with it first or tell me explicitly that we are proceeding with it on and what that
  costs. Three `notify.js` notifier hooks also sit at user scope, so `/hooks` in any project lists
  more than the harness's own.
- Steps 1–5 are done, do not redo or re-interview me about any of them: v2 is archived read-only
  and tagged v2-final, its six lessons are in LESSONS.md; the scaffold is published at
  github.com/drewwoodruff741/factory-lite (public, default branch `main`); the Stop gate was
  watched live and refused three times to weaken its own check; Superpowers 6.3.0 is priced at
  ~2.1k against factory-lite's ~560 tok and v2's ~10.5k. Do not re-measure, do not re-price, do
  not re-run the duplication check. The number that matters: v2's damage was **behavioural**, not
  contextual, so a small /context number is necessary but never sufficient.
- Step 6 is done, do not redo any of it. The shipping path is proved and the harness is **v3.1.0**,
  tagged and pushed. Five findings that this step depends on:
  1. **The pin enables, it does not install.** `enabledPlugins` is a flag for an already-installed
     plugin, and the CLI does not read `extraKnownMarketplaces` out of the settings file at all.
     `scripts/init.sh` therefore runs `claude plugin marketplace add … --scope project` and
     `claude plugin install … --scope project` for **both** plugins. This was diagnosed from cold
     three times; do not re-diagnose it.
  2. **The template pins both plugins now.** A new project gets `factory-lite@factory` *and*
     `superpowers@claude-plugins-official`, both enabled, from one `init.sh` run. That was Step 6's
     deliberate decision, argued both ways at the top of BACKLOG.md. Do not reopen it.
  3. **Projects track `main`, not the tag.** The marketplace is cloned shallow, depth 1, from the
     default branch and tags are never fetched. Every push to `main` ships immediately to every
     project. **From this step on, `main` is production** — do not push harness work in progress
     while a real project depends on it.
  4. **A missing gate is silent.** Step 6's failure produced no error and no warning, only an
     absence: four hooks in `/hooks` instead of five. The check is that `Stop` carries **two**
     hooks — the `notify.js` notifier, and `Running ./prove.sh` attributed to `Plugin`.
  5. `FACTORY_SKIP_PLUGIN_INSTALL=1` suppresses init.sh's install block; `harness-smoke.sh` sets
     it and asserts it, so the smoke test cannot write install records for a `$TMPDIR` project.
  BACKLOG items **4** (a project can't tell whether the harness loaded) and **5** (`main` is
  production) were noted in Step 6 and **deliberately left undecided**. Leave them undecided here
  too unless this project produces real evidence for one of them.
- The release rule is at the top of BACKLOG.md and applies to every scaffold change: smoke test →
  all four validate calls → bump `version` in **both** manifests → commit, tag, push → projects
  update via Customize → Plugins. It caught a real bug on its first execution. If this step
  changes the scaffold at all, it runs.
- The scaffold lives at ~/dev/factory-lite (the repo root is both the plugin and its marketplace).
  Layout: .claude-plugin/{plugin,marketplace}.json · hooks/{hooks.json,stop-gate.sh} ·
  skills/{pre-alpha,verify,spec,harden}/SKILL.md · agents/{explorer,reviewer}.md ·
  template/{CLAUDE.md,SPEC.md,prove.sh,.claude/settings.json} · scripts/{init.sh,harness-smoke.sh} ·
  README.md (design) · START-HERE.md (this plan) · LESSONS.md · BACKLOG.md · docs/subguides/
- The stack, and nothing else: VS Code + Claude Code extension › WSL2 Ubuntu (git, bash, jq, gh,
  Node LTS; per-project uv/ruff/pytest or pnpm/tsc/vitest/biome) › Claude Code built-ins
  (CLAUDE.md, skills, subagents, one Stop hook, plan mode, /clear, /context, /doctor, /memory,
  worktrees, /goal for long runs) › two pinned plugins: superpowers@claude-plugins-official and
  factory-lite@factory › four per-project files › method: brainstorm → /factory-lite:spec →
  fresh session → walking skeleton with the prove.sh check written first → Stop gate →
  /factory-lite:harden → backlog with evidence, one item at a time in worktrees.
- Rules for the sub-guide you write: every step must be doable inside VS Code; say what I should
  see after each step; keep the harness lite (never propose adding a hook, agent, rule, or plugin
  that isn't in the stack above); if something in the scaffold is wrong, fix it in the scaffold
  and add a line to BACKLOG.md or LESSONS.md, **not** to the project I'm building.
- Read README.md in the scaffold before writing the sub-guide.

STEP 7: First real project, pre-alpha only (the part that used to fail)

Goal: something runs end to end, proven by `./prove.sh`, before any architecture exists.

**This is the step v2 failed at, and it failed behaviourally, not technically.** Every previous
step tested the harness on scratch folders that existed to be deleted. This one has a real thing I
want at the end of it, which is exactly the condition under which the discipline gets negotiated
away. Treat the guardrails below as the deliverable, equal to the code.

The session produces:
1. **A project-specific runbook**, written before anything is built: `init.sh` → `git init` → open
   in VS Code → `/superpowers:brainstorming` if the idea is fuzzy → `/factory-lite:spec` → `/clear`
   → plan mode for the skeleton only → the first implementation prompt → the timebox.
2. **A `SPEC.md` with an honest Out-of-scope list.** It must include the things I will be tempted
   to build — not a list of things I never wanted. If the out-of-scope list contains nothing
   attractive, it is decoration and the interview was too polite. Push back on me.
3. **A walking skeleton, with the `prove.sh` check written FIRST.** The single check replaces the
   template's TODO sentinel, which is what arms the Stop gate — while the sentinel is there the
   gate announces `FACTORY gate: dormant.` and blocks nothing. Writing the check first is what
   makes the rest of the session honest, so do not let it slide to "after it works".
4. **The three-session timebox, enforced.** If it isn't running by session three, the slice is too
   big: halve it and say so out loud. Do not quietly extend.
5. **An answer to BACKLOG item 2, which named THIS step as its trigger.** Watch whether
   `superpowers:brainstorming` again writes a correct `SPEC.md` unprompted, without being asked and
   without producing its own competing design doc. If it does, that is the second observation the
   item asked for, and `/factory-lite:spec` gets deleted in that release — together with item 3's
   trim of `verify` item 2, one edit and one bump, not two. If it doesn't, say so and the item
   stays waiting. Decide this from what actually happens, not from what Step 5 predicted.
6. **Evidence for or against the gate's own delete-when condition.** README says the Stop gate goes
   when `prove.sh` passes first time on >95% of stops. Count the blocks. One real project is not
   95% of anything, but it is the first data.

Two personal rules for the whole build, which I want you to hold me to:
- product wishes → `SPEC.md` `## Deferred`
- harness wishes → FACTORY's `BACKLOG.md`
- neither gets built mid-project. Not one.

MY IDEA (one line): a nutrition and fitness tool — log intake (calories, macros, micros), track
body measurements over time, later recommend workouts from equipment + goal + recovery, and
eventually coach rather than just record. Bare bones first, not everything at once.
LANGUAGE: Python — uv, ruff, pytest. Decided 2026-09-12: uv 0.12.9, ruff 0.16.6, python3 3.13.15 and
stdlib sqlite3 3.53.1 are already on this machine, so the skeleton needs no install step and no
dependencies. pnpm is absent, so TypeScript would put a corepack bootstrap in front of line one.

Done when: `./prove.sh` passes on the walking skeleton, the Stop gate is armed (not dormant) and
has been seen to block at least once, and a human can run the thing with the one command written in
`CLAUDE.md`.

Guardrails: **no new hooks, agents, rules, plugins, or MCP servers during this step. Not one.**
That is the rule v2 broke. No harness edits at all unless the harness is actually broken, and then
by the release rule, from `~/dev/factory-lite`, never from the project. Don't decide BACKLOG items
4 or 5. Don't re-price anything with `/context`. Don't push work in progress to the harness's
`main` — it ships to this project immediately. If I ask you to weaken `./prove.sh` to make a
problem go away, refuse and tell me what the check is actually reporting; the gate did exactly that
three times in Step 4 and that was the result worth having.

**The sub-guide is already written, reviewed and committed: `docs/subguides/step-7.md`.** Read it
and execute it — do not rewrite it, and do not re-derive what §0 of it already checked. Three things
were settled before it was written and are not open:
- **Chore 1 is diagnosed.** One extension, `tjcg.auto-accept-claude-code` 0.5.0, writes all four
  permission-disarm paths on every activation — which is why Step 1's hand fix came back. §1 executes
  the teardown; pre-teardown backups of all six affected files are at
  `~/backups/factory-lite-chore1-2026-09-12`. **§1b costs a VS Code extension-host restart, so it will
  kill your session.** That is expected. Reopen and resume at §1c.
- **Two observations are pre-registered** so they cannot be scored to taste after the fact: §5c is an
  eight-row scorecard for BACKLOG item 2, and §8 is the gate-block tally. Read both *before* running
  the thing they measure.
- **BACKLOG items 4 and 5 stay undecided, and item 6 stays unbuilt.** Item 6 is recorded on zero
  observations, as a prediction, precisely so it is not built on one.

Start at §1. Tell me what you are about to do before the restart, then wait for my go.

---
