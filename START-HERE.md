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
  core.eol=lf, .gitattributes pins LF. Empty-folder /context baseline is 32.3k of a 1M window.
  Two extension quirks: /context prints no path line, and a folder needs at least one file in it
  before the extension will open a session there.
- The scaffold lives at ~/dev/factory-lite (the repo root is both the plugin and its marketplace).
  Layout: .claude-plugin/{plugin,marketplace}.json · hooks/{hooks.json,stop-gate.sh} ·
  skills/{pre-alpha,verify,spec,harden}/SKILL.md · agents/{explorer,reviewer}.md ·
  template/{CLAUDE.md,SPEC.md,prove.sh,.claude/settings.json} · scripts/{init.sh,harness-smoke.sh} ·
  README.md (design) · START-HERE.md (this plan) · LESSONS.md · BACKLOG.md
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

## [ ] Step 2: Capture LESSONS.md and freeze v2 (≈ 30 min)

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

## [ ] Step 3: New repo with the scaffold in it (≈ 1 hour)

**Goal:** `factory-lite` exists on GitHub, passes its own tests, and is tagged `v3.0.0`.

**Bring to the session:** the Context block and the unzipped scaffold.

**The session produces:** the sequence to publish the existing local repo with
`gh repo create --source=. --push` (public or private, your call), fill the two `<your name>` blanks in
`.claude-plugin/`, point `template/.claude/settings.json` at the new repo, make scripts
executable, run `bash scripts/harness-smoke.sh` (expect `harness smoke: PASS`) and
`claude plugin validate .` (expect no errors), commit, push, tag `v3.0.0`, push tags. It should
explain in one line each what `plugin.json`, `marketplace.json`, and `source: "./"` do.

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

## [ ] Step 4: Prove the harness live, inside the extension (≈ 1 hour)

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
and `/context` for the scratch project is a fraction of v2's.

**Guardrails:** anything that misbehaves is fixed in `~/dev/factory-lite`, re-smoke-tested,
re-tagged. Never patched in the scratch project. Delete the scratch project after.

**Interface note (verified in Step 1).** This step is already extension-only: `/hooks`, `/context`,
`/factory-lite:spec`, `/clear`, `/factory-lite:harden` are all typed in the chat box, and the
symlink + `init.sh` parts are one-off terminal commands. **Do not use `claude --plugin-dir`** —
README lists it as an alternative but it launches the terminal UI. The symlink into
`<scratch>/.claude/skills/factory-lite/` is the method. One extension-specific gotcha: a plugin
loads at **session start**, so after creating the symlink, start a *new* session rather than
continuing the open one, or `/hooks` will show nothing.

---

## [ ] Step 5: Superpowers installed and scoped (≈ 30 min)

**Goal:** Superpowers is installed where it belongs and nothing in FACTORY duplicates it.

**Bring to the session:** the Context block and the `/context` number from step 4.

**The session produces:** how to add the `anthropics/claude-plugins-official` marketplace and
install `superpowers` at **project scope** from Customize → Plugins in the extension; how to
read `/plugin` for what it costs and `/context` for the new startup total; the decision rule
(**revised in Step 1:** the original "15% of the window" is meaningless on a 1M-token window —
150k. Measure against the empty-folder baseline in LESSONS.md, 32.3k, and stay project-scoped if
the two plugins together add more than roughly 30k on top of it); one trial of `/brainstorm`
feeding into `/factory-lite:spec`; and a check that
FACTORY has no skill whose name resembles a Superpowers skill and the test project has no
`.claude/agents/reviewer.md` of its own.

**Done when:** `/plugin` shows both plugins enabled and you've done one brainstorm → spec hand-off.

**Guardrails:** install nothing else from the marketplace, however tempting the list looks.

---

## [ ] Step 6: Pin from GitHub and write the release rule (≈ 30 min)

**Goal:** a brand-new folder gets the harness from GitHub with no manual copying except `init.sh`.

**Bring to the session:** the Context block.

**The session produces:** the test (empty folder → `init.sh` → open in VS Code → `/plugin` shows
`factory-lite@factory` enabled because `settings.json` asked for it), the fallback if the pin
doesn't resolve (Customize → Plugins → add marketplace `<your-user>/factory-lite` → install
`factory-lite`, project scope), and a five-line release rule to paste at the top of BACKLOG.md:
smoke test → bump `version` in `plugin.json` → tag → push → projects update via Customize →
Plugins (or `claude plugin update factory-lite@factory` in the integrated terminal).

**Done when:** the pin works from GitHub and the release rule is written down.

**Guardrails:** don't set up stable/latest channels yet; one tag is enough until a second project
exists.

---

## [ ] Step 7: First real project, pre-alpha only (the part that used to fail)

**Goal:** something runs end to end, proven by `./prove.sh`, before any architecture exists.

**Bring to the session:** the Context block, your one-line idea, and the language (Python → uv,
ruff, pytest; TypeScript → pnpm, tsc, vitest, biome).

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

- `/context` on a new project is a fraction of the v2 number in LESSONS.md.
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
