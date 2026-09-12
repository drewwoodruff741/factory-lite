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

## Startup cost of v3 (Step 4, 2026-09-12)
Fresh session in `~/dev/scratch-hello`, the template's four files plus factory-lite loaded as
`factory-lite@skills-dir`, claude 2.1.269, opus-5 1M window.
- `/context` total **34.7k / 1.0M (3%)**, of which Messages was 8 tokens — so **startup ≈ 34.7k**,
  i.e. **+2.4k above the 32.3k empty-folder floor**, against v2's ~10.5k. Under target.
- Where the 2.4k sits: custom agents 156 (`reviewer` 89 + `explorer` 67) · memory files 300
  (the template `CLAUDE.md`) · skills 2.8k → 2.9k (~100) · **system tools 25.4k → 27.3k (+1.9k),
  unexplained and almost certainly not ours** — no plugin here defines a tool.
- So the harness's own share is ~560 tok, not 2.4k. `claude plugin details factory-lite`
  independently projects **~377 tok always-on** for the plugin, which agrees with the 156 + ~100
  measured above; the template `CLAUDE.md`'s 300 is the rest. Even crediting the whole 2.4k to
  v3, it costs **under a quarter of v2** while shipping four skills, two agents and one hook
  against v2's five agents and three always-on rules.
- **SPEC.md does not load at startup** — only `CLAUDE.md` appears under Memory files. The spec is
  read on demand, which is why the 60-line `CLAUDE.md` budget is the one that matters.
- Restating Step 2's headline so this number is not misread: v2's damage was **behavioural, not
  contextual**. 2.4k vs 10.5k is necessary, not sufficient. The gate test in the same step is what
  actually tests behaviour.

## Cost of Superpowers, and why totals can't be differenced (Step 5, 2026-09-12)
Fresh session in `~/dev/scratch-super`, template's four files, `factory-lite@skills-dir` 3.0.1 plus
`superpowers@claude-plugins-official` 6.3.0 installed at **project** scope. claude 2.1.269.

- **The `/context` Total is not a measuring stick. `system tools` is noise that swamps the
  harness.** Five readings on this machine at one CLI version: **25.4k · 27.3k · 27.3k · 26.5k ·
  24.5k** — a **±2.8k swing in a bucket we do not own**, larger than the whole harness. Installing
  Superpowers made the raw startup *fall* by 2.1k (34.86k → 32.8k), which is obviously not a real
  result. **Method correction: price a harness by summing the buckets you control, never by
  differencing totals.** This supersedes Step 4's subtraction method.
- Step 4's "+2.4k for v3" was therefore **mostly that noise**. Its own note that the harness's real
  share was ~560 tok was right; the ~1.9k it flagged as "probably not ours" is confirmed not ours,
  and *variable*, which is worse than a constant offset.
- **The buckets we control:**

  | | empty floor | v3 only | v3 + Superpowers |
  |---|---|---|---|
  | custom agents | 0 | 156 | 156 |
  | memory files | 0 | 300 | 300 |
  | skills | 2.8k | 2.9k | **3.7k** |
  | messages at turn zero | ~0 | 8 tok | **1.3k** |
  | **harness cost** | — | **~560 tok** | **~2.7k** |

- **Verdict: pass, at about a quarter of v2's ~10.5k, for both plugins combined.** Nowhere near the
  30k line that would have been a failure.
- **Superpowers' ~2.1k splits two ways, and the split matters.** ~0.8k is the 14 skill descriptions
  in the `skills` bucket (matching `claude plugin details`' ~688 projection). ~1.3k is its
  **SessionStart bootstrap**, which injects the entire text of `skills/using-superpowers/SKILL.md`
  (3,108 bytes) as `hookSpecificOutput.additionalContext`. Its matcher is `startup|clear|compact`,
  so **it is re-paid on every `/clear`** — and FACTORY's own runbook `/clear`s between spec and
  implementation.
- **"Project scope" means cached machine-wide, enabled per project.** The download lands in
  `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/` and is recorded in
  `~/.claude/plugins/installed_plugins.json` with the project path and the pinned
  `gitCommitSha`; only the *enable* lives in the project's `.claude/settings.json`. Deleting the
  project removes the enable but **not** the cache or the record — after `rm -rf` the scratch
  project, `claude plugin list` still showed `superpowers@claude-plugins-official 6.3.0 project`
  with a `projectPath` pointing at a folder that no longer exists, status `✘ disabled`. Harmless,
  and it means pinning Superpowers in `template/.claude/settings.json` (Step 6) costs no re-download.
- **`claude plugin details` under-reports a context-injecting hook.** It labels that SessionStart
  hook `(harness-only — no model context cost)`. It costs ~1.3k every session. Read the hook script
  itself before trusting the projection; the CLI counts components, not what a hook emits.

## Superpowers meets FACTORY: the duplication check (Step 5, 2026-09-12)
Superpowers 6.3.0: **14 skills, 0 agents, 1 SessionStart hook**, no `commands/` directory (all
skills are model-invocable, and each is also reachable as `/superpowers:<skill>`).

- **Nothing was deleted from FACTORY.** Verdicts, each earned by one sentence Superpowers cannot say:

  | FACTORY | Nearest Superpowers | Kept because |
  |---|---|---|
  | `verify` | `verification-before-completion` | Superpowers forbids unevidenced *claims*; it has no concept of a single project-defined gate. FACTORY's names `./prove.sh` as the definition of done *for the phase*. |
  | `spec` | `brainstorming` + `writing-plans` | produces `SPEC.md` — phase, walking skeleton, and the one check that becomes `prove.sh` line 1. **But see below: this is now the deletion candidate.** |
  | `pre-alpha` | — | no equivalent; Superpowers has no phase concept at all |
  | `harden` | `finishing-a-development-branch` | that one decides how to *integrate* finished work; `harden` flips the gate profile and ranks the backlog |
  | `reviewer` agent | `requesting-code-review` | that skill dispatches a `general-purpose` subagent for general quality; `reviewer` reviews a diff **against SPEC.md**. Superpowers ships **0 agents**, so no name shadowing is possible. |
  | `explorer` agent | `dispatching-parallel-agents`, `subagent-driven-development` | those are orchestration patterns, not a read-only research agent |

- **The collision I predicted did not happen, and the one that did is better news.** `brainstorming`
  classifies a new project as "architectural" by construction and its written path ends at *write a
  design doc to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`, commit, then invoke
  `writing-plans`*. **It did neither.** No `docs/` directory was created. It wrote **FACTORY's
  `SPEC.md`** instead, in the template's own sections, `Phase: pre-alpha`, `## Deferred` left empty,
  and updated CLAUDE.md's Run/prove lines *and* its title. README §3's division of labour held
  exactly as written: **Superpowers supplied the method, FACTORY supplied the artifact.** The
  template being present in front of it is what steered it, which is the condition in every FACTORY
  project.
  **Precision about what was and was not proved.** It never created `docs/` — that much is
  observed, and it is its own checklist step 6, replaced by SPEC.md. But it **did not stop of its
  own accord**: the human typed `stop` immediately after the CLAUDE.md edit, with its steps 7–9
  (spec self-review → user reviews the spec → invoke `writing-plans`) still ahead of it. So
  "it never reached `writing-plans`" is **not** established — only that it had not reached it yet.
  Step 7 must let brainstorming run to its own end to settle this, because the answer decides
  whether FACTORY's phase ritual has a competitor.
- **`verify` item 2 ("show evidence, don't assert") is now strictly dominated** by
  `verification-before-completion`, which does the same job across two tables of rationalizations.
  Trim candidate, not a deletion — items 1, 3 and 4 (`prove.sh` as the phase's definition of done,
  reviewer-vs-SPEC.md routing, the long-run escape hatch) have no Superpowers equivalent.
- **Two review paths now exist that do not know about each other:** `verify` step 3 dispatches the
  `reviewer` agent; `requesting-code-review` dispatches a `general-purpose` subagent from a template.
  No conflict observed, but a project that runs both reviews the same diff twice.
- **No agent shadowing is possible on this machine:** no `.claude/agents/` in the project and **no
  `~/.claude/agents/` directory at all**. The trap is real for v2-era projects; it is absent here.

## The brainstorm → spec hand-off, observed (Step 5, 2026-09-12)
- **`/superpowers:brainstorming` is a materially better interviewer than `/factory-lite:spec`.** Three
  rounds of `AskUserQuestion` with genuine pushback — *"you left JSON output, multiple files and stdin
  unpicked, which pulls against 'as small as possible'"* — producing a SPEC.md with **9 checkable
  numbered requirements and a 9-item out-of-scope list**, and a "Proven by" that is a byte-for-byte
  diff against a committed fixture rather than a smoke test. `spec`'s single-pass instruction has
  never produced that.
- **So `/factory-lite:spec` ran second and had nothing to do — and said so.** It declined to
  re-interview, listed the decisions already captured, and offered to revisit named answers. Correct
  behaviour, and the clearest possible evidence that the two overlap. `spec` is now the strongest
  deletion candidate in the harness; see BACKLOG item 2 for the trigger.
- **`spec` handles a junk argument correctly.** Given the literal string `<your one-line idea>` as
  `$ARGUMENTS` it stopped and asked rather than inventing a project.
- **The 3.0.1 dormant-gate fix held on a second project, on every stop** — the `spec` turn, the
  brainstorming turns, and the idle turns all ended cleanly with `FACTORY gate: dormant.` Step 4's
  defect does not recur.
- **BACKLOG item 1 gains no second observation.** CLAUDE.md's title and one-liner *were* filled, but
  by `brainstorming`, not by `spec` — `spec` never ran to completion. The item still rests on Step 4's
  single sighting.
- **A relayed slash command is not a run.** Asking the session to "run `/plugin`, `/hooks`,
  `/context`" produces an agent reading config files off disk and inferring — here it concluded the
  Stop gate "is not loaded" and that "a skills-dir symlink does not register hooks.json", while the
  gate's own `FACTORY gate: dormant` message was printing at the end of that very turn, and `/hooks`
  showed it `Plugin`-sourced. **Client commands must be typed by the human.** Same class as Step 4's
  trust finding: a capability inferred absent from disk state while live evidence says otherwise.
- **`claude plugin list` is cwd-sensitive, and says "disabled" from the wrong folder.** The same
  project-scope install read `superpowers@claude-plugins-official … Status: ✘ disabled` from
  `~/dev/factory-lite` and `✔ enabled` from `~/dev/scratch-super` — where it also listed the
  `factory-lite@skills-dir` entry that is invisible elsewhere. A project-scope plugin is enabled by
  the *project's* `.claude/settings.json`, so the CLI answers for whatever directory it is standing
  in. Always set cwd to the project under test before reading it, and never conclude an install
  failed from a "disabled" printed somewhere else. Third member of the family that includes Step
  4's CLI-vs-extension trust records and the wrong-window `Unknown command`.
- **What the post-install verification actually rested on.** The `/plugin` panel was **not** read
  after installing; the evidence for "both plugins loaded, factory-lite once" was `claude plugin
  list` run with cwd in the project, the `Plugin`-sourced `SessionStart` row in `/hooks`, and the
  +0.8k jump in the `/context` skills bucket. Three independent signals, but not the one the step's
  done-when named — recorded so the next reader does not treat it as a `/plugin` observation.
- **The Customize → Plugins UI does offer an install scope**, and writing `enabledPlugins` to the
  project's `.claude/settings.json` is what "project" means there. No CLI fallback was needed.
- **A third permissions-disarm mechanism found, at a new path.** `~/.claude/settings.local.json`
  carries `defaultMode: bypassPermissions` *and* its own copy of the `_autoAcceptManaged` PreToolUse
  hook. LESSONS previously recorded two (user `settings.json` `defaultMode: auto` + the hook); Step 1
  removed `bypassPermissions` from the VS Code *machine* settings and it is back, in a different
  file. This is BACKLOG chore 1's "re-disarms itself after you fix it once", confirmed twice by two
  different routes.

## The gate, observed live (Step 4, 2026-09-12)
Everything below was watched in the extension, in `~/dev/scratch-hello`, at v3.0.0.
- **The gate blocks and releases as designed.** A real premature stop — tree edited to break the
  skeleton, `prove.sh` red — was blocked three times running, then the 3-strike loop guard handed
  control back with `FACTORY gate: ./prove.sh still failing after 3 attempts.` A clean tree passed
  and stopped silently. Both exits from the gate are real, and the state-hash skip kept chat-only
  turns free.
- **It held under pressure, which is the part that matters.** With the gate red and a human
  instruction to "leave it broken", the session had two cheap outs — revert the edit, or edit
  SPEC.md so `goodbye` became legal — and refused both, naming the second as "weakening the
  contract by the back door". It escalated instead. At hardening it mutation-tested its own gate
  (8 mutants, all caught), negative-tested every new check before trusting it, caught a real lint
  error in its own test helper and fixed it rather than silencing the rule, chose stdlib
  `unittest` over available `pytest` because SPEC.md forbids an install step, and refused to fake
  the typecheck it had no tool for. **This is the v2 failure mode not happening.** The 2.4k
  startup number proved nothing; this does.
- **Defect found and fixed (v3.0.1): the gate blocked the first turn of a fresh project.** The
  template `prove.sh` exits 1 by design, so the Stop gate fired on the `/factory-lite:spec` turn —
  whose own rule is "write no code". The session's diagnosis was exact: *"the Stop gate runs
  unconditionally, but CLAUDE.md scopes verify to 'before stopping after a code change'…
  `/factory-lite:spec` cannot terminate cleanly on a fresh project by construction."* Fix: the
  gate is **dormant** while `prove.sh` still holds the template's TODO sentinel, announcing that
  it is dormant on each stop, and arms itself the moment a real check replaces it. `harness-smoke.sh`
  test 1 had encoded the old contract (placeholder → block) and was inverted, with a new 1b
  asserting a *real* failing check still exits 2.
- **Two wording traps in `skills/harden/SKILL.md`, fixed.** Step 3 said to change `PROFILE=lite`,
  a literal string that does not exist in the template (`PROFILE="${HARNESS_PROFILE:-lite}"`); the
  model resolved it correctly anyway, but the trap was real. Step 5 demanded a typecheck
  unconditionally, forcing a choice between faking a check and deviating from the checklist on a
  machine with no type checker. It now asks only for the checks the stack actually has and says to
  record an unavailable one as deferred.
- **A slash command typed in the wrong window reads as a harness bug.** `Unknown command:
  /factory-lite:harden` came from the window open on the *harness repo*, which has no
  `.claude/skills` symlink and therefore no plugin. Check which folder the session is rooted in
  before concluding a command does not register.

## The shipping mechanism, proved (Step 6, 2026-09-12)

Steps 4 and 5 both loaded factory-lite as `factory-lite@skills-dir`, a symlink into the working
tree. That is the *testing* path. Step 6 exercised the *shipping* path — `factory-lite@factory`,
a marketplace install from GitHub — for the first time, from a folder that had never existed, on a
machine where the `factory` marketplace had never been fetched.

**It did not work as designed, and the failure was silent.** A fresh project with
`extraKnownMarketplaces` + `enabledPlugins` in `.claude/settings.json` got: the marketplace
registered, the repo cloned to `~/.claude/plugins/marketplaces/factory`, the plugin copied into
`~/.claude/plugins/cache/factory/factory-lite/3.0.1`, and the running session's in-use marker
written into it. Three of the four things needed. What never happened was the install record in
`installed_plugins.json` — so `/plugin` showed one plugin (superpowers, disabled) and `/hooks`
showed four hooks, none of them the gate. A second fresh session did not fix it; this is not a
startup-ordering race.

**`enabledPlugins` is an enable flag for an already-installed plugin, not an install instruction.**
Nothing was wrong with the repo, the manifests, or `"source": "./"`:
`claude plugin install factory-lite@factory --scope project` succeeded in under a second against
the same settings file, untouched.

**The CLI does not read `extraKnownMarketplaces` out of the settings file either.** With the key
sitting in the project's `.claude/settings.json`, `claude plugin marketplace update factory` still
failed with "Marketplace 'factory' not found. Available marketplaces: claude-plugins-official".
The settings key works on the *session* path only. So the fix is two calls, not one, and
`scripts/init.sh` now makes them (`marketplace add … --scope project`, then `install … --scope
project`). `--scope project` re-declares the key the template already carries and leaves
`~/.claude/settings.json` clean — verified.

Confirmed working from true cold (marketplace, cache and install record all torn down first):
`init.sh` into a new folder, then in the extension `/plugin` shows `factory-lite@factory` enabled
and `/hooks` shows **five** hooks, with `Stop` carrying two — the notifier, and
`Running ./prove.sh` attributed to `Plugin`. That second Stop line is the proof.

### Which ref a project actually gets: `main`. The tag is decoration.

`~/.claude/plugins/marketplaces/factory` is a **shallow, depth-1 clone of the default branch**.
`git describe --tags` there fails with "No names found" — the clone never fetches tags at all.
Four independent confirmations: the clone reports branch `main`; the extracted plugin copy contains
`docs/step-6-prompt.md`, which does not exist at `v3.0.1`; every install record writes
`gitCommitSha` equal to `main`'s HEAD; and the `3.0.1` in the cache path is a string copied out of
`plugin.json`, not a resolved ref.

**Every push to `main` ships to every project, immediately.** There is no such thing as an
unreleased commit on `main`. And because the cache directory is named for the version while holding
whatever `main` said at install time, **content drifts under a fixed version number** — two projects
that both report 3.0.1 can hold different code. The release rule at the top of `BACKLOG.md` says
this where the rule is read.

### Two smaller interface facts from the same step

- **A project-scope `enabledPlugins` entry blocks uninstall.** `claude plugin uninstall
  factory-lite@factory` refuses: "enabled at project scope (.claude/settings.json, shared with your
  team)". Removing the marketplace removes the install record instead. Expect this when tearing a
  test project down.
- **A bootstrap script that mutates machine state needs an opt-out, because the smoke test runs
  it.** The moment `init.sh` began installing plugins, `harness-smoke.sh` — which builds a
  throwaway project from the template in `$TMPDIR` — started writing install records for a
  directory it deleted seconds later. Two junk entries appeared in `installed_plugins.json` on the
  first run of the new rule. `init.sh` now honours `FACTORY_SKIP_PLUGIN_INSTALL=1`, the smoke test
  sets it, and the smoke test asserts all three of: the skip line printed, no install ran, and the
  registry file is byte-identical afterwards. Caught only because the release rule says to run the
  smoke test *before* committing.
- **Pinned but uninstalled is indistinguishable from broken, from inside the session.** The only
  signal that anything was wrong was an absence — no gate in `/hooks`. Nothing errored, nothing
  warned. This is the argument for `init.sh` doing the install loudly rather than trusting a
  declarative pin: a declarative pin that half-works fails quietly, and a project would run its
  whole pre-alpha with no proof gate and no indication it was missing.

## Before Step 7: chore 1's owner found, and how to count the gate (2026-09-12)

Recorded *before* Step 7 executes, from reading the machine rather than running the step. Nothing
here is a Step 7 result; Step 7's own findings get their own section.

### The auto-accept owner: one extension, four paths, rewritten on every startup

**`tjcg.auto-accept-claude-code` v0.5.0 owns all four permission-disarm paths.** Not three separate
mechanisms that happen to coexist, as Steps 1, 4 and 5 each concluded in turn — one extension,
writing all of them, on every activation (`onStartupFinished`):

| Path | What it writes |
|---|---|
| `~/.vscode-server/data/Machine/settings.json` | `initialPermissionMode: bypassPermissions` + `allowDangerouslySkipPermissions: true`, into **both** the `claudeCode` and `claude-code` config sections, at `ConfigurationTarget.Global` |
| `~/.claude/settings.local.json` | `defaultMode: bypassPermissions`, a 15-entry blanket allow list (`Bash(*)`, `Edit`, `Write`, `mcp__*`, …), its own copy of the hook, `__autoAcceptManaged: true` |
| `~/.claude/settings.json` | `PreToolUse` matcher `""` -> the hook, `_autoAcceptManaged: true` |
| `~/.claude/hooks/auto-accept-hook.sh` | the script itself: reads stdin, ignores it, returns `permissionDecision: allow` for every call |

**This is why Step 1's fix did not hold, and the lesson is about the shape of the problem, not the
files.** Step 1 removed `bypassPermissions` from the machine settings by hand and it came back.
Step 5 found `settings.local.json` and called it "a third path". Both were chasing outputs. The
finding that ends it is the **owner**: while the extension is enabled, hand-editing any of those
four rows is undone at the next window start. Generalisation worth keeping: **when a setting
re-appears after you remove it, stop fixing the file and find what writes it** — `grep -rl` over
`~/.vscode-server/extensions` located it in one call.

**The extension ships a real teardown, and it is still not trusted.** Its disable path deletes the
hook script, filters `_autoAcceptManaged` entries out of both settings files, and restores the two
VS Code keys. But the restore reads a **snapshot taken at activation time**, and on this machine
that snapshot was almost certainly taken with `bypassPermissions` already in place — so the
"restore" can write the bad value back. A teardown that restores from a snapshot of an
already-broken state is not a fix. Verify all five rows afterwards against a backup.

**`permissions.defaultMode: "auto"` in `~/.claude/settings.json` is NOT extension-owned** — it
carries no managed marker, so the teardown leaves it. It is also **not inert**: `auto` is a real
permission mode at 2.1.269. The CLI binary's own enum is
`default | acceptEdits | plan | auto | bypassPermissions`, and it carries the string *"Maps to
`defaultMode: auto`, which repo-level settings cannot grant in Claude Code"* — so user scope can
grant it and project scope cannot, which is precisely why a project's `settings.json` could never
have overridden it. That row needs a hand edit, and unlike the other four it will stay fixed.

### Three facts about the gate that decide how its delete-when is measured

README's delete-when for the Stop gate is *"passes first time on >95% of stops"*. Read
`stop-gate.sh` before counting, because "stops" is not what it sounds like.

- **Chat-only turns never reach `prove.sh`.** The gate hashes HEAD + staged/unstaged diff +
  untracked non-ignored file contents, and exits 0 without running the check when that hash matches
  the last PASS. So the denominator is **stops where the gate actually ran**, i.e. stops after a
  tree change. Counting every stop would inflate the ratio toward 95% with conversation and retire
  the gate on the strength of chatter.
- **Untracked, non-ignored files are in the hash.** A project that writes its own data into its
  working directory — a log file, a SQLite database, a cache — changes the tree on every run, so
  the gate re-runs `prove.sh` on every turn until those paths are gitignored. This is the gate
  behaving correctly and being useless at the same time.
- **In a non-repo the gate never skips.** The fallback state is `nogit-$(date +%s)`, which can
  never match the stored marker. `git init` before the first session, not after.

### Toolchain present on this machine (checked 2026-09-12, extends Step 1's list)

`uv 0.12.9` · `ruff 0.16.6` · `python3 3.13.15` · stdlib `sqlite3 3.53.1` · `corepack` present ·
**`pnpm` absent** · **`pytest` not on PATH**. So a Python project can reach a walking skeleton with
no install step and no dependencies, and a TypeScript one cannot. `pytest`'s absence does not
matter in pre-alpha, where the definition of done is one check in `prove.sh`; it is a Step 8
question.

### No scaffold defect found

Said plainly so that silence is not read as a clean bill of health nobody checked for: the scaffold
was read end to end while writing the Step 7 sub-guide and **nothing in it was found to be wrong**.
`harness-smoke.sh` prints `harness smoke: PASS` and all four validate calls pass at v3.1.0. Steps
4, 5 and 6 each found a real defect at this point in the step; this one did not, and that is a
result rather than an omission.

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
- **Step 3:** `claude plugin validate .` on this repo validates **only the marketplace manifest**,
  because the root holds both manifests and the marketplace wins. The plugin manifest and the
  components need their own calls: `claude plugin validate .claude-plugin/plugin.json --strict`,
  `... validate skills --strict`, `... validate agents --strict`. It taught: one green "Validation
  passed" is not proof that everything in a dual-role repo was checked — read *which* file it
  names on the first line.
- **Step 3:** `claude plugin details <name>` works only on an **installed** plugin. Its own error
  message suggests `--plugin-dir <path>`, but that option does not exist on the `details`
  subcommand (`error: unknown option '--plugin-dir'`). **Superseded in Step 4:** it works fine on a
  skills-dir plugin, so a pre-`/context` token read does exist — see the trust finding below.
- **Step 4:** the **CLI and the extension keep separate trust records.** Extension sessions ran
  freely in `~/dev/factory-lite` and `~/dev/scratch-hello` with no dialog while `~/.claude.json`
  had no `.projects` entry for either. Until the folder is trusted on the CLI side, every
  `claude plugin …` call there prints "skipped because this workspace was not trusted when plugins
  were scanned" — a statement about the CLI's own store, not about what the session loaded. It
  taught: **do not infer a capability is missing from a CLI error raised in an untrusted folder.**
  Both "skills-dir plugins never enter the registry" and "`details` doesn't work here" were
  concluded from that state and both were wrong; once trusted, `plugin list` reports
  `Status: ✔ loaded` and `plugin details` prints the full inventory and token projection.
- **Step 4:** permissions are disarmed machine-wide by **two** mechanisms in
  `~/.claude/settings.json`: `permissions.defaultMode: "auto"`, and a `PreToolUse` hook
  (`~/.claude/hooks/auto-accept-hook.sh`, matcher `""` = all tools, flagged
  `_autoAcceptManaged: true`) whose script does no filtering at all — it ignores its input and
  returns `permissionDecision: allow` for every call. Found via `/hooks` in the scratch project,
  which listed 5 hooks: that one, three `notify.js` notifier hooks, and factory-lite's Stop gate.
  Two consequences. First, **the permissions block in `template/.claude/settings.json` is
  decorative on this machine** — every project init.sh creates ships an allowlist that can never be
  consulted. Second, **no permission configuration anywhere can be observed or tested while this is
  on**, which is why the question of whether a parent directory's `.claude/settings.local.json`
  reaches a child project could not be answered in Step 4. It is the same class of finding as
  Step 1's `bypassPermissions`, by a different route: **the environment silently disarms the safety
  the harness assumes, and re-disarms it after you fix it once.**
- **Step 4:** `claude <unrecognized-subcommand>` is **treated as a prompt**, not rejected —
  `claude config list` (no such subcommand in 2.1.269) started a headless session and answered the
  words as a question. Only verified subcommands print and exit. Do not guess at them.
- **Step 7:** the machine-wide auto-accept that Steps 1, 4 and 5 each re-diagnosed as a *new*
  mechanism was **one VS Code extension** (`tjcg.auto-accept-claude-code` v0.5.0) writing four
  separate permission paths on every activation. Step 1 fixed the machine settings by hand and the
  extension put them back at the next window start; Step 4 found the `PreToolUse` hook and called
  it a second mechanism; Step 5 found `settings.local.json` and called it a third. They were one
  thing seen three times. **The finding is the owner, not the files** — while the owner is enabled,
  editing any file it writes is wasted work, and the growing count of "mechanisms" is itself the
  tell that you are fixing outputs instead of the source. The general form: *before hand-fixing a
  config file that came back, find out what writes it.*
- **Step 7:** an uninstall teardown is not a fix, it is a claim to verify. This extension shipped a
  real one — it deleted its hook script, filtered its `_autoAcceptManaged` entries out of both
  settings files, and restored the two VS Code keys — and three of four rows came back clean. The
  fourth restored from a snapshot taken at *activation* time, when the bad value was already
  present, so the teardown faithfully wrote `bypassPermissions` back. **A restore is only as good
  as the state it snapshotted.** Snapshot before the teardown and diff after; the row that survives
  is the one nobody predicted, unless you predicted it.
- **Step 7:** "nothing prompted me" is **not** evidence that permissions are disarmed. Immediately
  after chore 1, §0.6 predicted that `init.sh` would raise dialogs; four Bash calls went out and the
  human reported all four as silent, which is the sub-guide's stop condition. Every one of the five
  disarm rows was in fact clean, and a grep for `bypassPermissions|defaultMode|allowDangerouslySkip`
  across all Claude config returned zero. Three of the four calls were read-only (`ls`, `cat`,
  `grep`, `git ls-files`) and ran **sandboxed**, which never prompts and is correct behaviour; the
  fourth had prompted and been granted *always*, which is why it also looked silent on the calls
  after it. Two things settled it, and both are cheap: the allowlist file's **mtime matched the
  install to the second** and its new last entry was the exact command — a grant can only be written
  by an approved dialog, since bypass mode records nothing — and then a deliberate **write probe**
  (`touch` into the project, unsandboxable and unallowlisted) raised a dialog on demand. The general
  form: *absence of a prompt is ambiguous, so test a disarm claim with an action that must prompt,
  and read the allowlist's mtime — grants are evidence that permissions were live.* Also: tell the
  human to answer such a probe **Yes**, not **Always**, or the probe silently pollutes the allowlist
  and cannot be repeated.
