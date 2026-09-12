# Step 5 prompt — paste this whole file into a fresh session

Open `~/dev/factory-lite` in VS Code, start a **new** Claude Code session (not a continued one),
and paste everything between the rules below.

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
  `claude plugin validate .` and friends are fine because they print and exit.
- Environment already verified in Step 1, do not re-check: git 2.53.0, bash 5.3.9, jq 1.8.1,
  node v22.22.1, gh 2.46.0 (logged in as drewwoodruff741), claude 2.1.269, core.autocrlf=input,
  core.eol=lf, .gitattributes pins LF. Empty-folder /context baseline is 32.3k of a 1M window.
  Two extension quirks: /context prints no path line, and a folder needs at least one file in it
  before the extension will open a session there. Also on this machine: a user-scope PreToolUse
  hook `~/.claude/hooks/auto-accept-hook.sh` auto-approves every tool call, and three `notify.js`
  notifier hooks sit at user scope — so `/hooks` in any project lists more than the harness's own.
- Step 2 is done, do not redo any of it: v2 (drewwoodruff741/factory) is tagged v2-final and
  archived read-only on GitHub; LESSONS.md is filled with six v2 lessons plus the startup
  measurement. Do not interview me about v2 again and do not re-measure it. The one number that
  matters downstream: v2's whole harness cost ~10.5k above the 32.3k floor, so v3 is judged
  against 10.5k — and Step 2's finding was that v2's damage was behavioural, not contextual, so a
  small /context number is necessary but never sufficient.
- Step 3 is done, do not redo any of it: the scaffold is published at
  github.com/drewwoodruff741/factory-lite (public), default branch `main`, both `<your name>`
  blanks filled with "Drew", and `template/.claude/settings.json` already pins that repo.
  `bash scripts/harness-smoke.sh` prints `harness smoke: PASS`. One interface correction from that
  step: `claude plugin validate .` here checks only the *marketplace* manifest (root holds both,
  marketplace wins) — the plugin manifest and components need their own calls,
  `claude plugin validate .claude-plugin/plugin.json --strict`, `... validate skills --strict` and
  `... validate agents --strict`. All four pass.
- Step 4 is done, do not redo any of it. The gate was watched live in the extension: three
  consecutive blocks on a premature stop, the 3-strike loop-guard release, and clean stops on a
  green tree. It also refused, three times, to weaken its own check when told to make the problem
  go away — the behavioural result Step 2 said to look for. Numbers: v3 startup is 34.7k, i.e.
  +2.4k above the 32.3k floor, against v2's ~10.5k; the plugin's own share is ~560 tok, and ~1.9k
  of that 2.4k is an unexplained system-tools delta that is probably not ours (LESSONS.md has the
  breakdown). The harness is now v3.0.1, tagged and pushed: the Stop gate is dormant while
  `prove.sh` still holds the template TODO, because gating on it blocked the very first turn of a
  fresh project, `/factory-lite:spec` included. Three interface facts worth keeping: the CLI and
  the extension keep separate trust records, so a CLI "workspace not trusted" warning says nothing
  about what a session loaded; `claude plugin details <name>` does work on a skills-dir plugin once
  the folder is CLI-trusted (it reports ~377 tok always-on for factory-lite), which supersedes
  Step 3's note that no pre-install token read exists; and a slash command typed in the window open
  on the harness repo returns "Unknown command" because no plugin is loaded there.
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
  and add a line to BACKLOG.md or LESSONS.md, not to the project I'm testing in.
- Read README.md in the scaffold before writing the sub-guide.

STEP 5: Superpowers installed and scoped (≈ 30 min)

Goal: Superpowers is installed where it belongs, it costs what I'm willing to pay, and nothing in
FACTORY duplicates it.

The session produces: how to add the `anthropics/claude-plugins-official` marketplace and install
`superpowers` at **project scope** from Customize → Plugins in the extension; how to read
`/plugin` and `/context` for what it costs; one trial of `/brainstorm` feeding into
`/factory-lite:spec`; and a duplication check — FACTORY must have no skill whose name or job
resembles a Superpowers skill, and the test project must have no `.claude/agents/reviewer.md` of
its own, because a project agent silently overrides the plugin one of the same name.

You will need a scratch project again; Step 4's was deleted. The method is known and verified, so
do not redesign it: `bash ~/dev/factory-lite/scripts/init.sh ~/dev/<name>`, `git init`, remove the
`enabledPlugins` and `extraKnownMarketplaces` keys from that project's `.claude/settings.json`
with jq, `.gitignore` the `.claude/skills/` path, then symlink `~/dev/factory-lite` to
`<project>/.claude/skills/factory-lite` so it loads as `factory-lite@skills-dir`. A plugin resolves
at session start, so I must open a NEW session after the symlink exists. Superpowers, by contrast,
is a real marketplace install, so decide and say which of the two mechanisms each plugin uses and
why — I should not end up with factory-lite loaded twice.

How to judge the number — this is the part to get right:
- The measuring stick is not the raw `/context` total. The empty-folder floor is 32.3k. v3 alone
  measured 34.7k, i.e. +2.4k. Superpowers' cost is `new total − 34.7k`, and the number that
  matters for the whole harness is `new total − 32.3k` against v2's ~10.5k.
- Treat 10.5k as the number to beat for factory-lite and Superpowers *combined*, and anything
  approaching 30k as a failure worth reporting rather than a pass. (The "15% of the window" rule
  written in the original plan is dead: 15% of 1M is 150k, which no sane harness reaches.)
- Superpowers ships a SessionStart bootstrap. If that is what pushes the total up, say so
  explicitly and give me the per-component numbers, not just a total.
- `claude plugin details superpowers` works as a print-and-exit cross-check once the folder is
  trusted on the CLI side, and reports a projected always-on token cost per component. Use it
  alongside `/context`, not instead of it.
- And the standing caveat: v2's damage was behavioural, not contextual. A good number here is
  necessary, not sufficient.

Done when: `/plugin` shows both plugins enabled, I have done one `/brainstorm` → `/factory-lite:spec`
hand-off, and the cost is recorded in LESSONS.md next to the 32.3k floor, v2's 10.5k, and v3's
+2.4k.

Guardrails: install nothing else from the marketplace, however tempting the list looks — the
temptation is the point of the guardrail. Add no hook, agent, rule or plugin to FACTORY in this
step. If Superpowers turns out to duplicate a FACTORY skill, the fix is to delete FACTORY's, in
the scaffold, with a LESSONS.md line — not to keep both. Anything that misbehaves in factory-lite
is fixed in `~/dev/factory-lite`, re-tested (smoke test plus all four validate calls), and
re-released by bumping `version` in BOTH `.claude-plugin/plugin.json` and
`.claude-plugin/marketplace.json` before the new tag — both currently say 3.0.1. Delete the scratch
project at the end.

Write the sub-guide for this step to `docs/subguides/step-5.md`, then wait for my go before
executing anything.

---
