# Step 6 prompt — paste this whole file into a fresh session

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
- **Client commands must be typed by me, not relayed to a session.** `/context`, `/plugin`,
  `/hooks` and `/memory` are rendered by the client; no tool dispatches them. Step 5 asked a
  session to "run" them and got an agent reading config files off disk and inferring — it
  concluded the Stop gate "is not loaded" while that very gate's message was printing at the end
  of its own turn. Ask me to type them and to paste back what I see.
- Environment already verified in Step 1, do not re-check: git 2.53.0, bash 5.3.9, jq 1.8.1,
  node v22.22.1, gh 2.46.0 (logged in as drewwoodruff741), claude 2.1.269, core.autocrlf=input,
  core.eol=lf, .gitattributes pins LF. Empty-folder /context baseline is 32.3k of a 1M window —
  but see Step 5: the /context **Total** cannot be differenced, because `system tools` swings
  ±2.8k on its own. Price a harness by summing the buckets you control.
  Two extension quirks: /context prints no path line, and a folder needs at least one file in it
  before the extension will open a session there. Also on this machine: permissions are disarmed
  by **three** separate mechanisms — `~/.claude/settings.json` `permissions.defaultMode: "auto"`,
  a user-scope `PreToolUse` hook `~/.claude/hooks/auto-accept-hook.sh` that allows every call, and
  `~/.claude/settings.local.json` carrying `defaultMode: bypassPermissions` plus its own copy of
  that hook. Step 1 removed `bypassPermissions` from the VS Code machine settings and it came back
  elsewhere. Consequence: no permission rule on this machine is testable, so the permissions block
  in `template/.claude/settings.json` is decorative here. Three `notify.js` notifier hooks also sit
  at user scope, so `/hooks` in any project lists more than the harness's own.
- Step 2 is done, do not redo any of it: v2 (drewwoodruff741/factory) is tagged v2-final and
  archived read-only on GitHub; LESSONS.md is filled with six v2 lessons plus the startup
  measurement. Do not interview me about v2 again and do not re-measure it. The one number that
  matters downstream: v2's whole harness cost ~10.5k above the 32.3k floor — and Step 2's finding
  was that v2's damage was behavioural, not contextual, so a small /context number is necessary
  but never sufficient.
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
  go away — the behavioural result Step 2 said to look for. The harness is v3.0.1, tagged and
  pushed: the Stop gate is **dormant** while `prove.sh` still holds the template TODO sentinel,
  because gating on it blocked the very first turn of a fresh project, `/factory-lite:spec`
  included. It announces `FACTORY gate: dormant.` on each stop and arms the moment a real check
  replaces the TODO. Two interface facts still worth keeping: the CLI and the extension keep
  separate trust records, so a CLI "workspace not trusted" warning says nothing about what a
  session loaded; and a slash command typed in the window open on the harness repo returns
  "Unknown command" because no plugin is loaded there.
- Step 5 is done, do not redo any of it. Superpowers 6.3.0 was installed at project scope from
  `claude-plugins-official` (14 skills, 0 agents, 1 SessionStart hook, no `commands/` dir — each
  skill is also reachable as `/superpowers:<skill>`). Costs, by the corrected method:
  **factory-lite ~560 tok, Superpowers ~2.1k, combined ~2.7k against v2's ~10.5k — a pass at about
  a quarter.** Superpowers' 2.1k is ~0.8k of skill descriptions plus a ~1.3k SessionStart bootstrap
  that re-injects on every `/clear` and that `claude plugin details` wrongly calls "no model
  context cost". **Nothing in FACTORY was deleted** — the duplication verdicts are in LESSONS.md.
  But `superpowers:brainstorming` wrote a better `SPEC.md` than `/factory-lite:spec` does,
  unprompted, and never produced its own competing design doc, so `spec` is BACKLOG item 2, the
  deletion candidate, with **Step 7** as the trigger — not this step. Do not re-run the duplication
  check, do not re-price the plugins, and do not delete `spec` here. The Step 5 scratch project was
  deleted; `installed_plugins.json` still carries a `projectPath` to that gone folder, which is
  harmless.
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

STEP 6: Pin from GitHub and write the release rule (≈ 30 min)

Goal: a brand-new folder gets the harness from GitHub with no manual copying except `init.sh`.

**This step tests the shipping mechanism for the first time.** Steps 4 and 5 both loaded
factory-lite as `factory-lite@skills-dir` — a symlink into my working tree. That is the *testing*
mechanism. Real projects get `factory-lite@factory`, a marketplace install from GitHub, pinned by
`extraKnownMarketplaces` + `enabledPlugins` in `template/.claude/settings.json`. Nothing has ever
proved that path works. So: **do not symlink and do not strip the plugin keys this time.** Leave
the settings file exactly as `init.sh` copies it — that is the thing under test.

The session produces:
1. **The pin test.** A fresh scratch project (Step 5's was deleted): `bash
   ~/dev/factory-lite/scripts/init.sh ~/dev/<name>`, `git init`, first commit, open it in a new
   VS Code window, start a new session, and **I type `/plugin`**. Expected: `factory-lite@factory`
   enabled, version 3.0.1, sourced from the `factory` marketplace — with no manual marketplace add
   and no install step. Tell me what to watch for on the very first session: whether the extension
   prompts to trust the marketplace, whether it fetches silently, and how long it takes.
2. **An answer to the question the pin raises: which ref does a project actually get?** The
   marketplace source is `{"source":"github","repo":"drewwoodruff741/factory-lite"}` with no ref,
   and the plugin source is `"./"`. So does an installing project receive `main`, or the newest
   tag? The release rule is meaningless until this is answered from observation — check the
   installed copy's `plugin.json` version and, if the cache is a git checkout, its commit against
   `main` and `v3.0.1`. If it turns out projects track `main`, say so plainly: it means every push
   ships, and the tag is decoration.
3. **The fallback**, if the pin doesn't resolve: Customize → Plugins → add marketplace
   `drewwoodruff741/factory-lite` → install `factory-lite`, project scope. If the fallback is
   needed, that is a defect in the pin, not a workaround to accept — fix the scaffold.
4. **The release rule**, pasted at the top of BACKLOG.md, saying all five of these and not a
   shortened version (Steps 3–5 each found a piece a short version omits):
   1. `bash scripts/harness-smoke.sh` → `harness smoke: PASS`
   2. all four validate calls — `claude plugin validate .` covers only the *marketplace* manifest;
      the plugin manifest and components need `... validate .claude-plugin/plugin.json --strict`,
      `... validate skills --strict`, `... validate agents --strict`
   3. bump `version` in **BOTH** `.claude-plugin/plugin.json` **and**
      `.claude-plugin/marketplace.json` — bumping one leaves the two disagreeing about what the
      release is
   4. commit, `git tag vX.Y.Z`, `git push && git push --tags`
   5. projects update via Customize → Plugins (or `claude plugin update factory-lite@factory`)
5. **A decision, deliberately deferred from Step 5:** should `template/.claude/settings.json` also
   pin `superpowers@claude-plugins-official`, so every new project gets both plugins? Step 5 proved
   the cost is affordable and that the two do not collide. The only open question is whether every
   project pays ~2.1k by default or opts in. It is cheap either way — the plugin is already cached
   machine-wide at `~/.claude/plugins/cache/claude-plugins-official/superpowers/6.3.0`, pinned to
   sha `b36e082`, so a template pin only flips a per-project enable with no re-download. Give me a
   recommendation with the argument on both sides, then do what I say. If the answer is yes, that
   edit to `template/.claude/settings.json` is a scaffold change and needs the full release rule
   applied to itself — which makes it the rule's first live test.

Done when: the pin resolves from GitHub in a project I did not hand-configure, the release rule is
written into BACKLOG.md, and the Superpowers-in-the-template question has an answer either way.

Guardrails: don't set up stable/latest channels yet — one tag is enough until a second project
exists. Add no hook, agent, rule or plugin to FACTORY. Don't delete `spec` in this step; that is
Step 7's call. Don't bump the version unless something actually breaks or the template gains the
Superpowers pin. No re-pricing with `/context` — Step 5 settled the numbers. Anything that
misbehaves is fixed in `~/dev/factory-lite`, re-tested (smoke test plus all four validate calls),
and re-released by the rule above; both manifests currently say 3.0.1. Delete the scratch project
at the end.

Write the sub-guide for this step to `docs/subguides/step-6.md`, then wait for my go before
executing anything.

---
