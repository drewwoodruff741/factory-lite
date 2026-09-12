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
- **Step 7: how to count hook firings in a `.jsonl` transcript, because three separate ways of
  getting it wrong all showed up in one sitting.** The §8 gate tally is a ratio, so every counting
  error lands directly on a delete-when decision. The rule, in this order:
  1. **The record type depends on how the gate exited, and the two cases do not match.** A
     `dormant` announcement or a 3-strike release prints a `systemMessage` JSON object on stdout
     and exits 0, and lands as **`type == "attachment"`**. A **block** writes to stderr and exits
     2, and lands as **`type == "system"`**. A rule written for one silently reports zero of the
     other — which is what happened here: a first version of this rule filtered to
     `attachment.stdout`, and counted the project's only real block as 0.
  2. **Then de-duplicate, differently for each.** An `attachment` firing is written **twice**, as
     `.attachment.stdout` and `.attachment.content`, identical text, same timestamp to the
     millisecond — filter to one key or count distinct timestamps (the coach run's raw count of 8
     dormant announcements is **4** firings). A `system` block is written **once**; the `user` and
     `assistant` records carrying the same text afterwards are the session quoting it back.
  3. **Prose is never a firing.** Mentions inside `user`/`assistant` records are the gate being
     *discussed*. This matters most in the `factory-lite` transcripts, which is both where the gate
     gets discussed and where a tally is likely to be read from: one session matched the block
     string **13 times across 9 prose records with zero firings**.
  That this rule was wrong on its first writing, in the direction of under-counting the only
  outcome anyone cares about, is the lesson — not a footnote to it.
  And underneath both: **one counting method per comparison.** `grep -c` counts *lines*, `grep -o |
  wc -l` counts *occurrences*, and in `.jsonl` a single line carries an entire message — including
  a whole skill body — so mixing the two manufactures order-of-magnitude contrast out of identical
  content. That error produced a phantom "2 vs 10" difference between two brainstorming runs that
  are in fact 10 vs 10, and it was then *reproduced minutes after the rule against it was written*,
  by subtracting a record count from an occurrence count and inferring four records that do not
  exist. The general form: *a number read out of a transcript is a measurement, so state its unit
  and its filter before you compare it to anything.*
- **Step 7: a component with a quantitative delete-when has to be able to produce the quantity.**
  The Stop gate retires when `prove.sh` passes first time on >95% of the stops where it ran — and
  `hooks/stop-gate.sh` exits **silently** on a pass (`:71-74`) and equally silently on the
  unchanged-tree skip (`:59-61`), so the numerator and the excluded case look identical from
  outside, while blocks are double-written and therefore over-count. The two errors push the ratio
  in **opposite** directions. Recorded as `BACKLOG` item 7 and deliberately not fixed mid-project.
  The trap to avoid next time is treating this as evidence the gate has earned permanence: it is
  evidence the *measurement* was never designed, which is a different thing and a cheaper fix.
- **Step 7: the discipline was negotiated by a document that was good, not by one that was bad.**
  `superpowers:writing-plans` produced a 1608-line stage-1 plan — correctly scoped to five
  requirements, explicit about its own omissions, self-reviewing hard enough to catch its own
  arithmetic error — and it placed **the `prove.sh` check at task 9 of 9, line 1529 of 1608**. Three
  separate FACTORY instructions say the opposite (`pre-alpha/SKILL.md:12` "write the check before
  the code it checks"; the Step 7 sub-guide §6; the step prompt's third deliverable). Under that
  ordering the sentinel survives tasks 1-8, so the **Stop gate announces `dormant` and enforces
  nothing across the entire build**, arming only once everything already works. Two more collisions
  came with it: the plan's header names the *design doc* as `Spec:` rather than `SPEC.md`, so the
  chain routes around the file the gate and skills actually read; and it specified **57 tests in
  pre-alpha**, where `README.md:115-117` puts the full TDD loop at hardening and lets the single
  `prove.sh` check stand in for a suite.
  **The lesson is about the shape of the failure, not the tool.** v2 did not die of sloppy work
  either. An artifact that is thorough, internally consistent and clearly the product of real effort
  is *harder* to refuse than a bad one, and "it would be a waste not to use it" is the whole
  mechanism. The guardrail that held was having written down, before the project existed, that the
  check goes first — because in the moment the plan was plainly better than anything the constraint
  would produce. **Decide the order of operations while nothing is at stake, or the best available
  artifact decides it for you.**
- **Step 7: when deleting a document, read it for load-bearing decisions first.** The plan was
  deleted under `pre-alpha`'s "SPEC.md is the only planning artifact", but one decision existed
  *only* inside it: display precision (kcal 0dp, macros 1dp), which `prove.sh` depends on because it
  asserts on rendered strings. Deleting it unread would have left the proof resting on a formatting
  rule nothing recorded — and the failure would have surfaced months later as a broken check with no
  traceable cause. Promoted to `SPEC.md` and `CLAUDE.md` Gotchas before the delete. The general
  form: *a document being in the wrong place is not evidence that everything in it is worthless;
  grep it for the things the rest of the system depends on before it goes.*
- **Step 7, §8 — the gate's delete-when measures session shape, not model reliability.** First real
  project, final tally:

  ```
  ran and passed:    unknown but >= 1  (a pass is silent; see BACKLOG item 7)
  ran and blocked:   1                 (deliberately induced, see below)
  3-strike releases: 0
  ran DORMANT:       6                 (session 1, all before the sentinel came out)
  ```

  **The whole walking skeleton was built without the gate firing once.** The build happened in a
  single continuous agentic run, and the gate only runs at a *stop*; by the time the session
  stopped, `prove.sh` was already green. Read naively that is a 0% block rate — a perfect score,
  and an argument to retire the gate. It is the opposite: the gate scored perfectly because it was
  barely consulted. **The denominator is stops, and long agentic runs have almost none.** Combined
  with the fact that writing the check first (which FACTORY mandates) guarantees the check is red
  for most of a build, the ">95% of stops" condition cannot be read off a pre-alpha at all. Whatever
  replaces it has to be measured over something that does not collapse when the model works in
  longer turns.
- **Step 7: the gate had to be provoked to be tested, and the provocation was worth more than the
  build.** Because the real build never tripped it, the block was induced deliberately — the
  `reviewer` agent's mutation, one character in a pure function (`targets[m] - totals[m]` to `+`),
  then stop without fixing it. The gate ran `./prove.sh`, refused the stop, and named the failing
  assertion: `AssertionError: missing '1745'`. Three things that only a real defect could show.
  It caught a **one-character change in a domain function with no test suite in the project at
  all**. It pointed at the exact assertion rather than a generic failure. And the assertion that
  caught it was a **remainder**, not a total — with one entry the row and the total render the same
  string, so a check asserting totals alone would have passed a visibly broken page. *When a check
  has only one fixture, assert on a number that could only be produced by the computation you care
  about, not one that any intermediate value also produces.* Reverted immediately; tree clean, no
  check touched in either direction.
  The general form, and the reason this is in LESSONS rather than a commit message: **a gate that
  never fires is indistinguishable from an absent one, and a project cannot tell the difference
  from the inside.** That is BACKLOG item 4 arriving as evidence rather than as a hypothetical, on
  a real project, one step after it was written down.
- **Step 7 audit: the harness had two definitions of "pre-alpha done" and no way to notice.**
  `skills/harden/SKILL.md` gates graduation on `pre-alpha`'s three-item done-when, all of which are
  about the **walking skeleton**. `template/SPEC.md` invited a numbered list headed "Pre-alpha
  requirements" with nothing bounding it to the skeleton. Coach's spec came back with **ten**
  requirements and had to **invent a "## Build order" section** to stage them — a project inventing
  structure the template should have supplied is the tell. The result: coach passed `harden`'s gate
  with four of its own stated pre-alpha requirements unbuilt, and the harness had no answer about
  which definition won. Fixed in v3.2.0 by bounding the list to the skeleton, because that is what
  the phase was always for. The general form: *when a template invites a list, it must also say
  what bounds the list, or the list becomes the scope.*
- **Step 7 audit: the harness was the one repo where its own gate could not run.** `~/dev/factory-lite`
  had no `prove.sh` **and** no `.claude/settings.json` enabling the plugin — so the Stop gate had
  nothing to execute and was never even loaded. The release rule was therefore enforced by memory
  alone, and **it was broken twice in the session that was auditing the harness for exactly this
  class of defect.** Both times the checks passed when finally run, so nothing shipped broken; that
  was luck, not a control. Fixed by dogfooding: a repo-root `prove.sh` running the smoke test, the
  four validate calls, and a new assertion that both manifests carry the same `version` — release
  rule step 3's named failure, and the only part of the rule that leaves no trace when you get it
  wrong, since every diagnostic keeps reporting *a* version, just not the same one. The provocation
  test earned its place immediately: **all four `validate` calls passed a deliberately desynced pair
  of manifests**, and only the new check caught it. The general form: *a tool that enforces a
  discipline on others and exempts itself is not enforcing a discipline, it is expressing a
  preference.*
- **v3.2.0: `claude plugin list` aggregates install records across projects, so "three enabled
  copies" is one registration.** Verifying the harness's own gate, `plugin list` in
  `~/dev/factory-lite` reported **three** `factory-lite@factory` entries (3.1.0, 3.2.0, 3.1.0), all
  "Scope: project", all enabled — which would mean `prove.sh` running three times per stop. `/hooks`
  in the same folder showed `Stop` carrying exactly **two** hooks, the notifier and the gate. The
  listing was install records from coach, the harness and old scratch folders, with no path to tell
  them apart. Same family as Step 3's lesson: **`/hooks` is the authority on what is loaded; the CLI
  inventory is the authority on what is on disk, and they answer different questions.** The version
  duplication is expected too — the cache directory is named for the version while holding whatever
  `main` said at install time.
- **v3.2.0: the silent-pass defect blocked the verification of its own fix.** After installing the
  harness's gate, the transcript carried **no gate record of any kind** — which is equally
  consistent with "wired and passing silently" and "not wired at all", because a pass leaves no
  trace (`BACKLOG` item 7). The fix could only be confirmed by a human typing `/hooks`. Leaving item
  7 open is a defensible call — it wants a second project's evidence — but the cost is no longer
  hypothetical: *a component that cannot report success cannot be verified by the same evidence that
  would verify anything else, and every check of it degrades into asking a person.*
- **Step 8: a `prove.sh` gate protects against regression, not against introduction.** The best
  sentence the build produced, and it came from the session being gated. Hardening coach through
  three backlog items gave the gate its first real sample — **0 blocks across 7 stops, with `/hooks`
  confirming it was armed the whole time**, so the zero is a measurement and not an artifact. In
  those same stops the `reviewer` agent found a P0 (`food_id=10**30` returning a 500 with a
  traceback — *the exact defect the shipped item existed to prevent*), a P1 (`servings=1e308` making
  a day's totals read `inf` permanently), three tests that could not fail under any circumstances,
  and three whole sections deleted from `SPEC.md`, `## Constraints` among them. **`./prove.sh` was
  green through all of it**, and correctly so: at the moment a defect is written, the check that
  would catch it is part of the same unwritten work. Every one of those findings was then *converted*
  into a check the gate now enforces. So the honest delete-when is not "does it pass >95%" but
  **"does anything else run `prove.sh` if the gate doesn't?"**
- **Step 8: a test you have not watched fail is not a test.** Three of the suite's tests could not
  fail under any input, and the suite passed them happily — they were written by the same session
  that wrote the code, and nothing about a green run distinguishes a passing test from an inert one.
  The `reviewer` agent caught all three. The `harden` skill already says each new strict check must
  be shown to fail on a broken input; Step 8 is the evidence for why that clause is load-bearing
  rather than ceremonial, and coach's `CLAUDE.md` now carries the rule because the session broke it
  three times. Generalise past tests: *any assertion, check, gate or alarm you have not seen fire is
  a decoration until you have.*
- **Step 8: where FACTORY's value actually sits, on the evidence so far.** Two projects in, the
  component that has produced findings you can point at is the **`reviewer` agent**, followed by the
  **check-written-first rule** and the **phase discipline**. The always-on **Stop gate** has blocked
  exactly twice in the entire build, and both were defects induced deliberately to see whether it
  would. That is not a case for deleting it — deterrence and absence remain indistinguishable on
  this metric, and the sessions ran `prove.sh` by hand precisely because the gate exists. But if the
  harness is ever trimmed, the evidence says trim toward *keeping the cheap fresh-context review*
  and re-examining the always-on hook, which is the reverse of the intuition that a hook is rigorous
  and an agent is soft.
- **Step 9: a component survived two reviews because every duplication check compared it against the
  other *plugin*, and never against the *client*.** The `explorer` agent — read-only research on
  haiku, ~70 tokens always-on — was dispatched **zero** times across two shipped projects and four
  scratch folders. The only subagent ever dispatched in any FACTORY session is `reviewer`, 7 times.
  Step 5 ran an explicit duplication pass against Superpowers and correctly concluded that
  `dispatching-parallel-agents` is an orchestration pattern rather than a research agent — and it
  was the wrong comparison, because Claude Code itself now ships `Explore` and `general-purpose`,
  which are always present and need no plugin. The general form: *the client gains capabilities
  between releases, so "is this duplicated?" has to be re-asked against the client's own built-ins,
  not only against the other thing you installed.* Deleted in v3.3.0, which is the whole reason the
  reverse pass exists.
- **Step 9: "never" is not a delete-when — it is a component declaring itself permanent.** Four of
  the five rows in `README.md` §1 could not be evaluated at all: three said *never* or pointed at a
  judgement call, and the fourth was a ratio two projects proved unreadable. A table of retirement
  conditions that cannot be evaluated is a table that will never retire anything, and it took a
  year's worth of build steps to notice because every individual row looked reasonable. The rule
  now, and the reason the count came down for the first time: **if a delete-when cannot be counted,
  it must name an experiment** — usually "remove it and see" — and that experiment has to be
  written down while the component is still wanted, not when someone is already arguing to keep it.
- **Step 9: deterrence and absence produce identical evidence, so a silent control cannot be
  retired on its own telemetry.** The Stop gate's delete-when asked for a pass rate; the number
  cannot be read even when counted live, because a gate that never fires *because the session
  pre-empts it* and one that never fires *because it was never installed* look the same from
  outside — and the sessions ran `./prove.sh` by hand precisely because the gate exists. No amount
  of instrumentation touches that; it is a property of what a deterrent is. What instrumentation
  *did* fix was a smaller and genuinely recurring cost: with a pass and an unchanged-tree skip both
  a silent exit 0, "is the gate wired?" needed a human to type `/hooks` three times across two
  projects and one audit. v3.3.0 makes a pass say so and keeps the skip silent, so silence after
  real work now means absent. The general form: *instrument what is ambiguous, but don't mistake
  instrumentation for an answer to "is this worth keeping" — for a deterrent, that question is
  answered by taking it away.*
- **Step 9: measure the artifact, not the invocation.** `/factory-lite:harden` was typed **zero**
  times in the one project that reached hardening — and its checklist was followed step by step
  anyway, because the session was pointed at `skills/harden/SKILL.md` and read it. `/factory-lite:spec`
  was likewise never typed there, while `SPEC.md` got written correctly by `brainstorming`. A usage
  count keyed on command invocations would have retired both skills on the strength of a ritual that
  was actually performed. **The skill file does work as a document whether or not the command fires**,
  so deleting the command deletes the document — which is the opposite of what the count appeared
  to recommend. Two of the three FACTORY components with real evidence behind them are read far
  more often than they are invoked.
- **Step 9: a backlog that only accumulates is the same failure as a harness that only accumulates,
  one file over.** Five of nine items were rejected in the first maintenance pass, every one of them
  with shipped-project evidence pointing at "do nothing" that had been sitting in the item for one
  or two steps already. Nothing had rejected them because `waiting` is free to write and reads as
  diligence, while `rejected (why)` reads as a decision someone could be wrong about. The rule that
  fixed it is mechanical rather than a matter of taste: **an item that has waited through two
  projects with no evidence is evidence about the item**, and a `waiting` that cannot name the
  specific observation that would settle it is a `rejected` nobody wanted to write. Every rejection
  in the pass carries its reopen trigger, which is what makes rejecting cheap enough to do.
- **Step 9: the mitigation contradicted the skill it cited, and only reading the skill caught it.**
  Item 9's whole job is arbitrating between two co-pinned skills that give opposite instructions,
  and the first draft of the fix told `pre-alpha` to ask `superpowers:brainstorming` for its
  **Bounded** path — on the recorded premise that "nothing about a fresh scaffold predicts which
  path it picks". `brainstorming/SKILL.md` predicts it exactly: *"If there is no existing flow to
  change, the task is not bounded"*, *"Architectural — new projects…"*, and in its Red Flags table
  *"A new project has no existing flow — it is architectural"*, directly under *"Reaching for a
  label to skip work IS the doubt — take the heavier path."* **Every FACTORY pre-alpha is a new
  project**, so the mitigation asked the model to break the skill it was invoking, *inside the
  instruction whose purpose was to stop those two skills fighting.* The `reviewer` agent found it in
  the release diff, which is the third time in three projects that the reviewer is the component
  that caught the thing nothing else would have.
  Two general forms, and the second is the one that will recur. *A rule about another component has
  to be checked against that component's source, not against your own notes on it* — the premise had
  been sitting in `BACKLOG.md` since Step 7, restated through two steps, and was never once checked
  against the 200-line file it described. And: **an inference from two runs is not a rule**. The
  runs "differed" because one applied the skill's classification step and the other never declared a
  path at all; reading that as "selection is unpredictable" put a *coin-flip* in the record where
  there was a *deterministic rule*. The corrected finding is narrower and strictly better news —
  FACTORY gets the design-doc path **every time**, which is a fixed collision, and a fixed collision
  can be closed by a fixed instruction. The wrong version could not have been.
- **Step 9: "every push to `main` ships to every project immediately" is one word too strong.**
  Pushing v3.3.0 refreshed the marketplace clone at once — and `~/dev/coach`'s install record still
  pointed at `cache/factory/factory-lite/3.2.0` afterwards, because a project runs the cache
  directory its install record pins until *that project* is updated. Step 6's finding stands (the
  clone is `main`, tags are never fetched, and content drifts under a fixed version number); what
  was wrong is the timing word attached to it, carried forward through three steps because it was
  never re-observed after the one push that could check it. The correction makes the discipline
  slightly *more* important rather than less: you control what the next install receives, not when
  it is received, so a work-in-progress push sits on `main` waiting for someone to collect it at a
  moment you will not witness. The general form: *a claim about timing needs an observation at two
  times; one measurement can only ever establish the state, never the latency.* (Corroborated the
  same afternoon: coach updated itself to 3.3.0 in its own session, by its own `/plugin` run —
  which is the mechanism, arriving exactly as described.)
- **Step 9, v3.3.1: the new delete-when was falsified by the downstream project within a day, and
  the confounder turned out to be the question.** The Stop gate's replacement condition — "run a
  project to completion with the gate removed and see whether `./prove.sh` still runs" — survived a
  full `reviewer` pass on the release diff. `~/dev/coach` read it hours later and reported it could
  not run the experiment: that session ran `./prove.sh` before every stop because **CLAUDE.md's
  verify rule told it to**, so removing the gate would show the check still running and prove only
  that the *rule* was doing the work. `template/CLAUDE.md:19` ships that rule to every FACTORY
  project, so the condition was unrunnable across the harness's entire installed base, by
  construction, from the moment it was written.
  **The instinct — control for the confounder — was wrong, and seeing why is the lesson.** There is
  no version of a FACTORY project where nothing but the hook asks for `prove.sh`, so "isolate the
  gate" means deleting the harness to test the harness. Stage it instead: remove the **hook**, keep
  the **prose**. If the check still runs, the hook is redundant and the ~50-token rule is the
  cheaper component that survives — which is a result, not a contaminated experiment, and it is the
  one Step 8's evidence already pointed at. The general form: *when a control cannot be isolated
  because something else always does its job, stop calling that a confounder — name the two things
  and ask which one you would keep.*
  And the procedural half, which is the better news: **the first thing to test the new delete-when
  was the project downstream of it, within a day, and it found what the release review did not.**
  The reverse pass was designed to be run by whoever holds the harness; it turns out the projects
  can run it too, and they are standing closer to the evidence.
- **Close-out: "a second project" is the most expensive words you can put in a reopen trigger.**
  Step 9 rejected five backlog items and gave each a named trigger, which is the rule that makes
  rejecting cheap enough to do honestly. Four of those triggers said *a second project* — and the
  next day the decision came that there would not be one. Three were retargeted at the single live
  project; one was unreachable and the item closed for good. The triggers were not careless: at the
  time they were written a second project was the obvious next thing, and "one project's observation
  is one observation" is the rule that made them the right shape. The lesson is narrower and it is
  about dependency, not about discipline: **a trigger that depends on work you have not committed to
  is a deferral wearing a condition's clothes.** Prefer a trigger the system you already have can
  fire — for these items that turned out to be "coach is bitten", "coach is found running against a
  damaged spec", "a work-in-progress push reaches coach" — and when only an uncommitted project
  could fire it, say so and close the item instead of leaving it open against a future that may not
  arrive.
- **Close-out: a harness that stops growing still rots, but by a different mechanism, and only one
  half of the loop defends against it.** The forward pass consumes shipped-project evidence, so with
  one project in maintenance it goes quiet on its own. The reverse pass does not, because its input
  is not *your* work — it is the client's. `explorer` was a defensible component until the day
  Claude Code shipped `Explore`, and nothing about FACTORY changed on that day; the world moved
  underneath it. So the close-out keeps the reverse pass at full strength and retires the forward
  pass, with the trigger changed from "after a project ships" to "after a model or client release".
  *Accretion is the failure mode of a harness that is being used; obsolescence is the failure mode
  of one that is finished, and they need different passes.*
- **Close-out: label the untested instead of deleting it or trusting it.** Two instructions shipped
  in v3.3.x can now never be exercised — the `brainstorming` step-5 stop (it applies at spec time,
  and no spec time remains) and the gate's removal experiment. Deleting them would discard findings
  that cost two projects to obtain; leaving them unmarked would let a future reader mistake
  *shipped* for *confirmed*, which is the same error as mistaking a green test suite for a tested
  one. They are tabled in `BACKLOG.md` with why they cannot be tested and what would let them be.
  The same move applies to the gate itself: **kept by decision, not by evidence**, written on the
  component. An honest label is a better resting state than a retirement condition nobody can run.

**Step 10: a delete-when that names an experiment has to name how to run it.** The Stop gate's
retirement condition — "remove the hook, keep the prose" — was carefully worded and genuinely
runnable, and it still cost an hour of investigation before it could start, because no document
said *how* to remove one plugin-supplied hook. Two of the three obvious mechanisms turn out to
violate the condition's own "keep the prose" clause: uninstalling the plugin removes the `verify`
skill with it, and a project-scope `enabledPlugins` entry refuses uninstall outright. The client's
hook UI cannot do it, and the settings schema has no per-hook disable. The answer was to empty the
`Stop` array in the plugin's own `hooks.json` at the project's pinned install path. **General form:
an experiment is an instruction, and an instruction that omits its mechanism is a wish.** If a
delete-when says "remove X", it should say which file, and what must still be true afterwards.

**Step 10: the first time one of these five delete-whens was actually executed, the result was
real and almost worthless at the same time, and both halves matter.** `./prove.sh` ran before every
stop with the hook removed — a clean result for "the prose is sufficient" — across *two stops*, in
a session that knew it was being measured. Recording it as a result without recording the sample
size and the observer effect would have turned one data point into a retirement. **General form:
when a component's retirement finally becomes measurable, the temptation is to act on the first
measurement. Write down what the measurement cannot support, in the same breath as the
measurement.**
