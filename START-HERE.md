# FACTORY-lite: fresh-start plan

Step 0 plus nine meta-steps. Each meta-step is written as a **brief for a fresh Claude
session**. The loop, repeated per step (one evening each; 3+4 and 5+6 can share an evening):

1. Open this file in one VS Code pane and the Claude Code extension in the other. Start a
   fresh session, not a continued one.
2. Paste the Context block plus the one step block, and add: "Write the sub-guide for this
   step to `docs/subguides/step-N.md`, then wait for my go before executing anything."
3. Read the sub-guide before saying go. Reject anything outside the stack list; fresh sessions
   will occasionally offer a helpful extra hook or plugin, and that drift is what the Context
   block exists to block.
4. Execute with the session's help. You run the one-off shell commands in the integrated
   terminal; Claude edits files.
5. Check the step's "Done when". Not met: stay in the session. Met: tick the box here, commit
   (`step N done`), close the session. Surprises become one line in LESSONS.md or BACKLOG.md.
6. Next step, next fresh session. Never carry a session across steps.

Total: about a week of evenings. The first real project starts at step 7.

---

## [ ] Step 0: Files out of the chat and into WSL (≈ 15 min, no Claude session needed)

Download `factory-lite.zip`; it lands in Windows Downloads. Open a WSL window in VS Code
(Remote-WSL) and, in its integrated terminal:

```
mkdir -p ~/dev && cd ~/dev
cp /mnt/c/Users/<your-windows-user>/Downloads/factory-lite.zip .
sudo apt install -y unzip        # only if unzip is missing
unzip factory-lite.zip && rm factory-lite.zip
cd factory-lite
chmod +x hooks/*.sh scripts/*.sh template/prove.sh
bash scripts/harness-smoke.sh    # expect: harness smoke: PASS
git init && git add -A && git commit -m "factory-lite scaffold"
mkdir -p docs/subguides
code .
```

Keep it on the Linux side (`~/dev`), never under `/mnt/c`: execute bits and line endings
misbehave there. `git init` now so every sub-guide is committed from the first evening;
step 3 attaches the GitHub remote with `gh repo create --source=. --push`.

**Done when:** the smoke test passed, the first commit exists, and the folder is open in VS Code.

---

## Context block (paste into every session, above the step)

```
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
  core.eol=lf, .gitattributes pins LF. Empty-folder /context baseline is 32.3k of a 1M window —
  but see Step 5: the /context **Total** cannot be differenced, because `system tools` swings
  ±2.8k on its own. Price the harness by summing the buckets you control.
  Two extension quirks: /context prints no path line, and a folder needs at least one file in it
  before the extension will open a session there.
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
  go away — the behavioural result Step 2 said to look for. Numbers: v3 startup measured 34.7k.
  **Step 5 corrected this: the "+2.4k above the floor" was mostly system-tools noise, not v3.**
  v3's real cost is the ~560 tok Step 4 already identified (agents 156 + memory 300 + skills
  ~100). The harness is now v3.0.1, tagged and pushed: the Stop gate is dormant while
  `prove.sh` still holds the template TODO, because gating on it blocked the very first turn of a
  fresh project, `/factory-lite:spec` included. Three interface facts worth keeping: the CLI and
  the extension keep separate trust records, so a CLI "workspace not trusted" warning says nothing
  about what a session loaded; `claude plugin details <name>` does work on a skills-dir plugin once
  the folder is CLI-trusted (it reports ~377 tok always-on for factory-lite), which supersedes
  Step 3's note that no pre-install token read exists; and a slash command typed in the window open
  on the harness repo returns "Unknown command" because no plugin is loaded there.
- Step 5 is done, do not redo any of it. Superpowers 6.3.0 is installed at **project** scope from
  `claude-plugins-official` (14 skills, 0 agents, 1 SessionStart hook, no `commands/` dir — each
  skill is also reachable as `/superpowers:<skill>`). Costs, by the corrected method: **factory-lite
  ~560 tok, Superpowers ~2.1k, combined ~2.7k against v2's ~10.5k — a pass at about a quarter.**
  Superpowers' 2.1k is ~0.8k of skill descriptions plus a **~1.3k SessionStart bootstrap that
  re-injects on every `/clear`** and that `claude plugin details` wrongly calls "no model context
  cost". **Nothing in FACTORY was deleted** — the duplication verdicts are in LESSONS.md — but
  `superpowers:brainstorming` wrote a better `SPEC.md` than `/factory-lite:spec` does, unprompted,
  and never produced its own competing design doc, so `spec` is now BACKLOG item 2, the deletion
  candidate, with Step 7 as the trigger. Do not re-run the duplication check or re-price the
  plugins. Two interface facts: client commands (`/context`, `/plugin`, `/hooks`) **must be typed
  by the human** — an agent asked to run them reads config off disk and infers wrongly; and
  `~/.claude/settings.local.json` holds a *third* permissions-disarm path (`bypassPermissions` plus
  the auto-accept hook), so Step 1's fix did not hold.
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
```

---

## [ x] Step 1: Environment ready (≈ 30 min)

**Goal:** a WSL2 Ubuntu machine where every tool in the stack exists and the extension talks to it.

**Bring to the session:** nothing but the Context block.

**The session produces:** a checklist that verifies, in the integrated terminal, `git`, `bash`,
`jq`, `gh` (logged in to GitHub), Node LTS, and Claude Code's version; confirms VS Code is
connected via Remote-WSL (not Windows-side); confirms the Claude Code extension opens a session
whose `/context` shows the WSL project path; and turns on line-ending safety for git in WSL so
scripts never get CRLF. It should also show how to set the default model and permission mode from
the extension's Customize menu.

**Done when:** every check passes and a throwaway folder's session confirms a `/home/...` working
directory.

> **Corrected during Step 1 (claude 2.1.269):** `/context` prints only the token table — there is
> no path line to read. Ask the session "what is your working directory?" in the chat box instead.
> Also: a folder needs at least one file before the extension will open a session in it, so create
> a throwaway file first.

**Guardrails:** no global installs beyond the list. No dotfile frameworks.

---

## [x] Step 2: Capture LESSONS.md and freeze v2 (≈ 30 min)

**Goal:** carry the *evidence* out of v2 and nothing else.

**Bring to the session:** the Context block and one number: `/context` from a fresh session in any
project still on v2. Grab that number *before* archiving the repo.

> **Note (after Step 1):** `LESSONS.md` is **no longer the empty template**. It already carries the
> 32.3k empty-folder baseline and two build-time findings under `## From building v3 itself`.
> Step 2 fills the v2 sections around them — nothing existing gets overwritten.

**The session produces:** an interview that fills `LESSONS.md` from memory (what bit you, what
it cost, what it taught; what you kept adding and never used; what was project-specific and
lived in the harness by mistake), then the steps to freeze the old repo: tag `v2-final`, push
tags, archive the repo on GitHub (Settings → Archive), and record its `/context` number in
LESSONS.md for the before/after comparison.

**Done when:** `LESSONS.md` has at least five concrete lines and the v2 repo is archived.

**Guardrails:** no code is copied out of v2. If you can't remember a rule, it wasn't load-bearing.
If something feels project-specific, it goes in that project later, not in FACTORY.

---

## [x] Step 3: New repo with the scaffold in it (≈ 1 hour)

**Goal:** `factory-lite` exists on GitHub, passes its own tests, and is tagged `v3.0.0`.

**Bring to the session:** the Context block and the unzipped scaffold.

**The session produces:** the sequence to publish the existing local repo with
`gh repo create --source=. --push` (public or private, your call), fill the two `<your name>` blanks in
`.claude-plugin/`, point `template/.claude/settings.json` at the new repo, make scripts
executable, run `bash scripts/harness-smoke.sh` (expect `harness smoke: PASS`) and
`claude plugin validate .` (expect no errors), commit, push, tag `v3.0.0`, push tags. It should
explain in one line each what `plugin.json`, `marketplace.json`, and `source: "./"` do.

**Repo state, checked at the end of Step 2 — do not re-derive:** branch is `master`, there is no
remote, and there are no tags. `<your name>` appears twice: `.claude-plugin/plugin.json` (author)
and `.claude-plugin/marketplace.json` (owner). `template/.claude/settings.json` already pins
`drewwoodruff741/factory-lite`, which matches the `gh` login, so that line needs no change unless
a different repo name is chosen. The step must also decide, once and with a reason, whether to
rename `master` → `main` before publishing.

**Done when:** GitHub shows the repo with the `v3.0.0` tag and both tests pass locally.

**Guardrails:** change nothing inside `skills/`, `agents/`, or `hooks/` in this step. Fix bugs
only if a test fails, and log the fix in BACKLOG.md.

**Interface note (verified in Step 1, claude 2.1.269).** Everything in this step is either a file
edit or a one-off command in the integrated terminal. Nothing here opens the terminal UI:
`gh repo create`, `bash scripts/harness-smoke.sh`, and `claude plugin validate .` all print and
exit. Add `--strict` to the validate call to fail on warnings too. Two further print-and-exit
commands exist if you want them: `claude plugin details <name>` reports a plugin's component
inventory and projected token cost, and `claude plugin tag` creates a `{name}--v{version}` git tag
while checking that `plugin.json` and the marketplace entry agree — note it tags
`factory-lite--v3.0.0`, not `v3.0.0`, so use plain `git tag` if you want the bare version tag this
step's Done-when asks for.

---

## [x] Step 4: Prove the harness live, inside the extension (≈ 1 hour)

**Goal:** see the Stop gate block and release once, with your own eyes, without the TUI.

**Bring to the session:** the Context block. Mention that the local-test method is a symlink of
the repo under a scratch project's `.claude/skills/factory-lite/`, which loads as
`factory-lite@skills-dir` on the next session.

**The session produces:** the steps to make a scratch project, run `init.sh` into it, remove the
`enabledPlugins`/`extraKnownMarketplaces` keys from the scratch project's settings so only the
symlinked copy loads, open it in VS Code, and verify with `/hooks` (one Stop hook, source Plugin)
and `/context` (record the number next to the v2 number in LESSONS.md). Then a walk through the
whole loop on something trivial: `/factory-lite:spec` a CLI that prints hello → `/clear` →
"implement the walking skeleton, prove.sh check first" → watch the gate block until
`./prove.sh` passes → `/factory-lite:harden` and confirm it flips `Phase:` and `PROFILE=`.

**Done when:** you watched the gate block a premature stop and release after the check passed,
and `/context` for the scratch project is recorded next to v2's in LESSONS.md.

> **Outcome (2026-09-12).** Done. The defect this step existed to find: the gate blocked the first
> turn of a fresh project, because the template `prove.sh` exits 1 by design and the Stop hook
> fires on every turn — including `/factory-lite:spec`, whose own rule is "write no code". Fixed in
> v3.0.1 (dormant until a real check replaces the TODO, and it says so each stop); smoke test 1 had
> encoded the old contract and was inverted. Two wording traps in `skills/harden/SKILL.md` closed:
> it named a `PROFILE=lite` literal that isn't in the template, and demanded a typecheck on a
> machine with no type checker. The live method is confirmed as written: symlink under
> `<scratch>/.claude/skills/factory-lite/`, pin keys stripped, `factory-lite@skills-dir`.
>
> **Corrected after Step 2.** The original Done-when — "`/context` is a fraction of v2's" — cannot
> be satisfied. v2's startup was **42.8k**, of which **32.3k is the empty-folder floor**; its whole
> harness cost only **~10.5k**. Nothing can be a fraction of that. Judge v3 on *what it adds above
> 32.3k* (target: under 10.5k, i.e. cheaper than v2 *and* doing less), and remember Step 2's
> headline: v2's damage was behavioural, not contextual. A small number here is necessary, not
> sufficient.

**Guardrails:** anything that misbehaves is fixed in `~/dev/factory-lite`, re-smoke-tested,
re-tagged. Never patched in the scratch project. Delete the scratch project after.
"Re-validated" means all four calls from Step 3, not just `claude plugin validate .` — that one
reads the marketplace manifest only. A re-tag means bumping `version` in `plugin.json` *and*
`marketplace.json` (both say `3.0.0`) before the new tag, or the two disagree.

**Interface note (verified in Step 1).** This step is already extension-only: `/hooks`, `/context`,
`/factory-lite:spec`, `/clear`, `/factory-lite:harden` are all typed in the chat box, and the
symlink + `init.sh` parts are one-off terminal commands. **Do not use `claude --plugin-dir`** —
README lists it as an alternative but it launches the terminal UI. The symlink into
`<scratch>/.claude/skills/factory-lite/` is the method. One extension-specific gotcha: a plugin
loads at **session start**, so after creating the symlink, start a *new* session rather than
continuing the open one, or `/hooks` will show nothing. Once the symlinked plugin *is* loaded,
`claude plugin details factory-lite` becomes available as a print-and-exit cross-check on
`/context`: it lists the component inventory and a projected token cost. Step 3 could not run it
because nothing was installed yet.

---

## [x] Step 5: Superpowers installed and scoped (≈ 30 min)

**Goal:** Superpowers is installed where it belongs and nothing in FACTORY duplicates it.

**Bring to the session:** the Context block. The step-4 number is already in it: **34.7k startup,
+2.4k above the floor**, of which the plugin's own share is ~560 tok. That is the baseline
Superpowers is measured against — not the raw 34.7k.

**The session produces:** how to add the `anthropics/claude-plugins-official` marketplace and
install `superpowers` at **project scope** from Customize → Plugins in the extension; how to
read `/plugin` for what it costs and `/context` for the new startup total; the decision rule
(**revised in Step 1:** the original "15% of the window" is meaningless on a 1M-token window —
150k. Measure against the empty-folder baseline in LESSONS.md, 32.3k. **Revised again in Step 2:**
the 30k budget originally written here is three times what *all of v2* cost (10.5k). Treat 10.5k as
the number to beat and anything approaching 30k as a failure worth reporting, not a pass); one trial of `/brainstorm`
feeding into `/factory-lite:spec`; and a check that
FACTORY has no skill whose name resembles a Superpowers skill and the test project has no
`.claude/agents/reviewer.md` of its own.

**Done when:** `/plugin` shows both plugins enabled and you've done one brainstorm → spec hand-off.

**Guardrails:** install nothing else from the marketplace, however tempting the list looks.

---

## [x] Step 6: Pin from GitHub and write the release rule (≈ 30 min)

**Goal:** a brand-new folder gets the harness from GitHub with no manual copying except `init.sh`.

**Bring to the session:** the Context block. Note that every test in this step is of the
`factory-lite@factory` **marketplace** path — Steps 4 and 5 only ever proved `@skills-dir`, which
is the testing mechanism, not the shipping one. This is the first time the pin itself is exercised.

**The session produces:** the test (empty folder → `init.sh` → open in VS Code → **you type**
`/plugin` and see `factory-lite@factory` enabled because `settings.json` asked for it), the
fallback if the pin doesn't resolve (Customize → Plugins → add marketplace
`drewwoodruff741/factory-lite` → install `factory-lite`, project scope), and a release rule to
paste at the top of BACKLOG.md.

**The release rule must say all of this, not a shortened version of it** (Steps 3–5 each found a
piece the short version omits):
1. `bash scripts/harness-smoke.sh` → `harness smoke: PASS`
2. all four validate calls — `claude plugin validate .` covers only the *marketplace* manifest;
   the plugin manifest and components need `... validate .claude-plugin/plugin.json --strict`,
   `... validate skills --strict`, `... validate agents --strict`
3. bump `version` in **BOTH** `.claude-plugin/plugin.json` **and** `.claude-plugin/marketplace.json`
   — bumping one leaves the two disagreeing about what the release is
4. commit, `git tag vX.Y.Z`, `git push && git push --tags`
5. projects update via Customize → Plugins (or `claude plugin update factory-lite@factory`)

**Also decide in this step, deliberately deferred from Step 5:** whether
`template/.claude/settings.json` should pin `superpowers@claude-plugins-official` alongside
`factory-lite@factory`, so every new project gets both. Step 5 proved the cost is affordable
(~2.1k, mostly a SessionStart bootstrap re-paid on each `/clear`) and that the two do not collide.
The open question is only whether every project should pay it by default or opt in per project.
Cheap either way: the plugin is already cached machine-wide at
`~/.claude/plugins/cache/claude-plugins-official/superpowers/6.3.0` (pinned to sha `b36e082`), so
a template pin only flips the per-project enable — no re-download. Note the Step 5 scratch project
was deleted, so `installed_plugins.json` still carries a `projectPath` to a folder that is gone.

**Done when:** the pin works from GitHub, the release rule is written down, and the Superpowers-in-
the-template question has an answer either way.

**Guardrails:** don't set up stable/latest channels yet; one tag is enough until a second project
exists. Don't bump the version in this step unless something actually breaks.

---

## [ ] Step 7: First real project, pre-alpha only (the part that used to fail)

**Goal:** something runs end to end, proven by `./prove.sh`, before any architecture exists.

**Bring to the session:** the Context block, your one-line idea, and the language (Python → uv,
ruff, pytest; TypeScript → pnpm, tsc, vitest, biome). Plus one fact Step 6 established: **projects
track `main`, not the tag** — the marketplace is cloned shallow from the default branch and tags are
never fetched, so every push to the harness reaches this project immediately. Don't push work in
progress to `main` while a real project depends on it. `init.sh` now also installs both plugins;
if `/hooks` in the new project doesn't show a second `Stop` hook running `./prove.sh`, the gate is
absent and nothing will say so.

**The session produces:** a project-specific runbook: `init.sh` → `git init` → open in VS Code →
`/brainstorm` if fuzzy → `/factory-lite:spec` with an honest Out-of-scope list (include what
you'll be tempted to build) → `/clear` → plan mode for the skeleton only → the first prompt
("implement the walking skeleton; write the prove.sh check first, then make it pass") → the
three-session timebox (not running by session three means the slice is too big; halve it) → the
two personal rules during the build: product wishes go to SPEC.md `## Deferred`, harness wishes
go to FACTORY's `BACKLOG.md`, neither gets built mid-project.

**Done when:** `./prove.sh` passes on the skeleton and a human can run it with the one command in
CLAUDE.md.

**Guardrails:** no new hooks, agents, rules, plugins, or MCP servers during this step. Not one.
Before starting, clear BACKLOG.md's "Environment chores" — chore 1 especially: machine-wide
auto-accept makes every permission rule on this machine inert, including the one the template
ships. A real project is where that stops being theoretical.

---

## [ ] Step 8: Harden the first project (deliberate engineering starts here)

**Goal:** turn the Deferred list into an evidence-ranked backlog and start building from it, one
item at a time.

**Bring to the session:** the Context block, the project's SPEC.md and prove.sh.

**The session produces:** `/factory-lite:harden` run to completion (reviewer pass, `Phase:` and
`PROFILE=` flipped, Deferred items each given evidence or left deferred), the strict section of
`prove.sh` filled in for your language (test suite, lint, typecheck, secrets check), and the
hardening rhythm: one backlog item per branch or worktree, proven by `./prove.sh`, reviewed by
the `reviewer` agent; when a rule keeps being broken, one line in CLAUDE.md. Optional here, not
before: `/goal` for long runs, path-scoped `.claude/rules/`, Code Review on PRs.

**Done when:** three backlog items shipped through the rhythm without weakening `prove.sh`.

**Guardrails:** an item with no evidence stays deferred. Fix the principle, not the example.

---

## [ ] Step 9: The maintenance loop (30 min after each project, and per model release)

**Goal:** FACTORY improves without growing back into v2.

**Bring to the session:** the Context block, `BACKLOG.md`, `LESSONS.md`.

**The session produces:** the review procedure for BACKLOG.md (each item: assumption, evidence,
delete-when; no evidence → waits; evidence → built in `~/dev/factory-lite` with the header
convention, smoke test, version bump, tag), and the reverse pass to run after every model
release: open FACTORY in the extension, run `/doctor`, read each component's delete-when line,
delete what has expired.

**Done when:** BACKLOG.md has statuses on every item and FACTORY has the same number of
components as it did after step 3, or fewer.

**Guardrails:** the only way a component enters FACTORY is with evidence from a shipped project.

---

## Finished means

- `/context` on a new project adds less above the 32.3k floor than v2's ~10.5k did — while doing
  less than v2 did, not more (see LESSONS.md; the number alone never proved anything).
- One real project reached a proven, runnable skeleton inside the timebox.
- Every FACTORY component has an assumption / evidence / delete-when header.
- You have not opened the Claude Code terminal UI once.

## If something goes wrong

| Symptom | First thing to check |
|---|---|
| The gate never fires | `/hooks` shows the Stop hook? `prove.sh` executable and no CRLF? |
| The gate blocks forever | It stops itself after 3 strikes (Claude Code caps at 8). Run `./prove.sh` in the terminal and read it. |
| Plugin not found / won't install | Marketplace added as `<user>/factory-lite` (git), not a raw URL? `source` is `"./"`? |
| Two copies of factory-lite loaded | Remove the pin keys from the scratch project's settings, or remove the skills-dir symlink. |
| `/factory-lite:spec` not in autocomplete | Type it anyway; restart the session; known bug, workaround is a `commands/` copy. |
| Rules file not loading | Globs in `paths:` quoted? `/memory` lists it? Project-level, not `~/.claude/rules`. |
| Startup context still high | `/context` names the culprit; `/doctor` proposes cuts; move detail from CLAUDE.md to a skill. |
