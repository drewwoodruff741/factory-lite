# FACTORY-lite (v3) — build guide

A minimal Claude Code harness you install as a **plugin**, plus four per-project files you copy
**once**. It keeps the one thing FACTORY v2 got right (a hook-enforced proof gate) and moves
everything else to on-demand skills or deletes it. Superpowers is layered on top for planning,
TDD, and debugging, so FACTORY stops re-implementing those.

```
factory-lite/                              <- repo root is BOTH the plugin and its marketplace
├── .claude-plugin/
│   ├── plugin.json                        name/version; bump this to release
│   └── marketplace.json                   lists factory-lite with source "./"
├── hooks/
│   ├── hooks.json                         the ONLY always-on hook: Stop -> stop-gate.sh
│   └── stop-gate.sh                       runs the project's ./prove.sh; exit 2 blocks the turn
├── skills/
│   ├── pre-alpha/SKILL.md                 auto-loads while SPEC.md says Phase: pre-alpha
│   ├── verify/SKILL.md                    run ./prove.sh, show evidence, when to call reviewer
│   ├── spec/SKILL.md                      /factory-lite:spec  -> interview -> SPEC.md (manual)
│   └── harden/SKILL.md                    /factory-lite:harden -> graduate to hardening (manual)
├── agents/
│   └── reviewer.md                        fresh-context gap review vs SPEC.md, opus
├── template/                              per-project files a plugin can't ship; init.sh copies them
│   ├── CLAUDE.md                          ≤ 60 lines: run/prove commands, gotchas, 4 working rules
│   ├── SPEC.md                            walking skeleton, out-of-scope, Deferred
│   ├── prove.sh                           PROFILE=lite (one check) | strict (full suite)
│   └── .claude/settings.json              allowlist + marketplace/plugin pin
├── scripts/
│   ├── init.sh                            bootstrap a new project
│   └── harness-smoke.sh                   tests the harness itself; run before tagging
├── README.md                              this file: design and reference
├── START-HERE.md                          the fresh-start runbook (one fresh session per step)
├── LESSONS.md                             evidence carried over from v2 (no code)
└── BACKLOG.md                             harness wishes waiting for evidence
```

## 1. Design decisions (and the assumption each one encodes)

Every component carries **what assumption about the model it encodes, what evidence motivated it,
and when to delete it**. `hooks/stop-gate.sh` and `prove.sh` carry theirs as a file header; for
everything else the table below is the register, and it is the one you read in the reverse pass.
That pass — "what can I stop doing?" — is written down as a procedure at the top of `BACKLOG.md`,
and it is the half that keeps this small.

| Piece | Assumption it encodes | Delete when |
|---|---|---|
| Stop gate (`prove.sh`) | Claude sometimes stops before the check passes | a project runs to completion with the **hook** removed, the `verify` skill and CLAUDE.md's verify rule kept, and `prove.sh` still runs before every stop — see below |
| `pre-alpha` skill | Claude over-abstracts before there's a working slice | a pre-alpha runs clean with the skill **disabled**: no abstraction, no options, no parallel planning document |
| `reviewer` agent | the agent that wrote the code grades itself generously | two consecutive projects reach hardening with every `reviewer` pass returning no P0/P1 |
| `verify` skill | Claude reports success from intent rather than from output | Superpowers is unpinned from the template **and** a project stops asserting done without evidence for a whole phase |
| `spec` + `harden` commands | phase changes need a deliberate ritual | two projects write a correct `SPEC.md` (every heading, `Phase:`, scope bounded to the skeleton) without `spec`, and one graduates correctly without reading `harden` |

**A delete-when that cannot be counted must name an experiment, and "never" is not a delete-when.**
Step 9 rewrote four of these five rows, because the originals were unusable in exactly two ways.
Three said *never* or pointed at a judgement call, which makes a component permanent by default —
the opposite of what this table is for. The Stop gate's said `>95% of stops`, and two projects
proved that number cannot be produced *or* read: a pass and an unchanged-tree skip were both a
silent exit 0 (fixed in v3.3.0 — a pass now says so, the skip stays silent); the denominator is
stops, and it collapses as sessions run in longer turns; and a gate that never fires because the
session pre-empts it produces exactly the tally of a gate that was never installed. **Deterrence
and absence are indistinguishable from the outside**, so every row above that could not be counted
now names a removal experiment instead.

**The gate's experiment is staged, and `~/dev/coach` is the reason** — it read the condition the day
it shipped and pointed out that it could not run it. `template/CLAUDE.md` tells every project to run
`./prove.sh` before stopping after a code change, so in any FACTORY project *something other than the
hook* is always asking, and a naive "remove the gate and see" would retire it on evidence that only
shows the prose was doing the work. Stage it instead: **remove the hook, keep the prose.** If the
check still runs before every stop, the hook is the redundant component and the ~50-token rule is the
cheaper one that survives — a real result, and the one the evidence has been pointing at since Step 8.
The conclusion the experiment must never reach is "neither is needed": it compares two FACTORY
components against each other, it does not test the model with nothing.

**Run once, 2026-09-12, after close-out** (`BACKLOG.md` item 7). Drew reversed the
deliberately-not-running judgement and coach built hardening item 4 with the hook removed and the
prose kept. `./prove.sh` ran before every stop; the prose alone kept the check running. **That is
one clean data point, not a demonstration** — two stops is not a sample, and the session knew it
was being measured. The gate is still kept, and now on one run's worth of evidence rather than on
none. The hook's header carries the same record as of v3.3.3, along with the one thing no other
document held: **how** to remove a single plugin-supplied hook without taking the `verify` skill
with it.

The `spec`/`harden` row is the caution worth carrying:
its old wording ("you stop skipping them") technically fired — neither command was typed in the
one real project — while both rituals were performed anyway, one of them by reading the skill file
as a document. *Measure the artifact, not the invocation.* (`verify` had no row at all until Step 9
went looking — a shipped component with its delete-when nowhere, which is what a register is for.)

**One edge the PASS message inherits:** in a **non-repo** the gate never skips, because the fallback
tree state is `nogit-$(date +%s)` and can never match the last one. So a project that was never
`git init`-ed gets `prove.sh` re-run *and* the announcement on every stop, chat-only turns included
— the behaviour is unchanged from v3.2.0, only the noise is new. `git init` before the first
session, which was already the advice.

**Deleted in v3.3.0: the `explorer` agent** (read-only research, haiku), on the first reverse
pass. Two shipped projects and four scratch folders dispatched it **zero** times — the only
subagent ever dispatched in any of them is `reviewer`, 7 times — and the client now ships `Explore`
and `general-purpose`, which do the same job and are always present. Its delete-when had said
"never, same reason", which is how a component with no demand survives two projects. The
duplication check in Step 5 had compared every component against *Superpowers* and never against
the **client's own built-ins**; that is now part of the procedure.

What is **not** here on purpose: role-play agents (architect, PM, QA…), always-on rules, a
formatter hook, memory/work-record machinery, model-routing, security scanning as a hook.
Add any of these only after a project produces evidence for it, and add it at hardening
(`prove.sh` strict section, or a path-scoped rule), not to the plugin.

**Why plugin + template, not one or the other.** A plugin can bundle skills, subagents, hooks,
MCP and LSP servers, and projects pin it by version, so improvements flow back automatically.
But it cannot ship `CLAUDE.md`, `.claude/rules/`, or project permissions, and plugin-shipped
agents may not declare `hooks`, `mcpServers`, or `permissionMode`. So those four files are
copied once by `scripts/init.sh` and then belong to the project. Keep them small; that's the
point.

## 2. Fresh start (v2 is reference only)

v2 is archived, not migrated. Nothing from it is ported as code. `LESSONS.md` carries the
evidence; that is the whole inheritance. The build is: new repo → scaffold in → blanks filled →
smoke test → tag. `START-HERE.md` walks it one fresh session per step.

If you are ever tempted to bring something across from v2, it must pass this table first:

| v2 component | Only acceptable home in v3 | Test |
|---|---|---|
| rule that must never be violated | a check in `prove.sh` (strict) or, rarely, a `PreToolUse` hook | "would I want this enforced even when Claude disagrees?" |
| rule that only matters for some files | `.claude/rules/<name>.md` with quoted `paths:` globs, in the project | "does it apply to <20% of edits?" |
| rule that's judgment-level or obvious from the code | nowhere; delete | Anthropic cut >80% of Claude Code's own system prompt this way |
| workflow skill (brainstorm/plan/TDD/debug) | nowhere; Superpowers provides it | check the `superpowers` skill list first |
| project-specific skill (deploy steps, the sealed-partition machinery) | that project's `.claude/skills/`, never FACTORY | "would a different project ever need it?" |
| agent with a tool-restriction reason | `agents/`, minus `hooks:`/`mcpServers:`/`permissionMode:` | plugin agents can't declare those |
| agent that is a job title | nowhere; the main session does the work | |
| formatter/lint hook | a line in `prove.sh` strict | one gate beats five hooks |
| logging/recording hook | nowhere unless a project needed the log last month | |

Testing the harness locally happens **inside the VS Code extension, never the TUI**: a plugin
folder placed under a project's `.claude/skills/` (containing `.claude-plugin/plugin.json`)
loads as a plugin on the next session with no marketplace and no install step. Symlink the
repo there in a scratch project, open the extension, run `/hooks` and `/context`.

## 3. Integrate Superpowers

`scripts/init.sh` installs it, at project scope, alongside factory-lite — since Step 6 the template
pins both plugins and init.sh installs both. Nothing to do by hand. If the install warns (no `claude`
on PATH, no network), the manual path is `/` → Customize → Plugins → add marketplace
`anthropics/claude-plugins-official` → install `superpowers`, **project scope**.

Why every project pays its ~2.1k by default, and when to revisit that, is recorded in `BACKLOG.md`.

Division of labor:

| Superpowers owns | FACTORY-lite owns |
|---|---|
| brainstorming, writing plans, executing plans | what "done" means (`prove.sh` + Stop gate) |
| TDD, systematic debugging, worktree isolation | the phase discipline (pre-alpha → harden) |
| subagent-driven development with review | the SPEC.md-gap reviewer at stop time |

**Which one wins where they disagree (v3.3.0).** They do disagree, and Step 7 paid for finding
out: `brainstorming`'s Architectural path writes a design doc and hands off to `writing-plans`,
which produced 1911 lines of planning artifact beside a 71-line `SPEC.md`, specified a 57-test TDD
suite in pre-alpha, and put the `prove.sh` check at task 9 of 9 — which would have left the Stop
gate dormant for the entire build. All of it collided with `pre-alpha/SKILL.md`, both were loaded,
and only a human noticing kept the discipline. So `pre-alpha` now says it outranks them **in
pre-alpha**: SPEC.md is the only planning artifact, and the `prove.sh` check is task 1 of whatever
task list arrives. At hardening the precedence flips and Superpowers' planning and TDD skills are
the point.

The mitigation that does **not** work is asking `brainstorming` for its Bounded path: by its own
rule "a new project has no existing flow — it is architectural", so every FACTORY pre-alpha is
Architectural and requesting otherwise asks the model to break the skill it is invoking. The
mitigation that does work is stopping inside the path it will take anyway — **run its architectural
steps 1-5 and stop at 5**, where the design has been presented and approved but step 6's design doc
and step 9's `writing-plans` handoff have not happened. Everything useful is in steps 1-5; the
chain is 6-9.

Two knobs worth knowing:
- In pre-alpha, use Superpowers' brainstorming to feed `/factory-lite:spec`, but let the single
  `prove.sh` check stand in for a test suite. Turn on its full TDD loop at hardening, when a
  suite is worth its tokens. If its SessionStart bootstrap pushes startup context past ~15% of
  the window (`/context`), enable it per-project rather than globally.
- Project agents override same-named plugin agents. If v2 left a `reviewer.md` in a project,
  delete it or the plugin one never loads.

## 4. Where each researched feature lives

| Feature | Where in v3 | Phase |
|---|---|---|
| Verification ladder (prompt → `/goal` → Stop hook → verifier subagent) | Stop gate + `reviewer`; `/goal` optional for long runs | both |
| Keep CLAUDE.md short, progressive disclosure | 60-line template; details in skills | both |
| Hooks for zero-exception actions only | one hook, everything else is a skill | both |
| Fresh-context adversarial review | `reviewer` agent, opus | end of pre-alpha, every hardening item |
| Hook profiles (lite/strict) | `PROFILE` in `prove.sh`, flipped by `/factory-lite:harden` | both |
| Worktree isolation | Superpowers `using-git-worktrees`; agents may set `isolation: worktree` | hardening |
| Path-scoped rules | `.claude/rules/*.md` with quoted `paths:` globs, in the project | hardening |
| Security/secrets scan | commented line in `prove.sh` strict | hardening |
| Work-record / progress persistence | SPEC.md `## Deferred` + git log; add `claude-progress.txt` only for multi-day unattended runs | hardening |
| Plugin + marketplace pinning | `.claude-plugin/`, `template/.claude/settings.json` | both |
| Loop guard (Ralph-style) | 3-strike counter in `stop-gate.sh`; Claude Code caps at 8 anyway | both |

## 5. New-project runbook

```
bash ~/dev/factory-lite/scripts/init.sh my-app && cd my-app && git init   # then open the folder
/factory-lite:spec  <one-line idea>       # interview -> SPEC.md. No code.
/clear                                     # fresh context for implementation
"Implement the walking skeleton in SPEC.md. Write the ./prove.sh check first, then make it pass."
                                           # the Stop gate keeps the session honest
/factory-lite:harden                       # only after prove.sh passes on the skeleton
```

Those five lines are the whole harness. What follows is what one project cost to learn, folded in
at the point where each thing bites — the evidence for every item is in `LESSONS.md`, and none of it
is obvious from the five lines above.

### Phase 0 — the folder, before any session

`init.sh` copies the four files a plugin cannot ship (`CLAUDE.md`, `SPEC.md`, `prove.sh`,
`.claude/settings.json`) and installs both plugins at project scope. Those four are the project's
from that moment; everything else arrives from the plugin.

- **`git init` before the first session.** In a non-repo the gate cannot tell that nothing changed —
  the fallback tree state can never match — so it re-runs the check and announces itself on *every*
  stop, chat-only turns included.
- **Read `init.sh`'s output for `warn:`.** The pin *enables* a plugin; it does not *install* one.
  When the install fails you get no gate, silently, for the life of the project: nothing errors, it
  is simply absent.
- **Then confirm it, by typing `/hooks` yourself.** You want `Stop` carrying the gate. A session
  asked to check this reads config off disk and infers, and has been wrong about it twice.

### Phase 1 — the spec, in its own session, with no code

`/factory-lite:spec <one-line idea>`, or `superpowers:brainstorming` for the harder interview.

- **If you use brainstorming, stop it at architectural step 5.** A new project is Architectural by
  that skill's own rule, and its step 6 writes a design doc while step 9 hands off to
  `writing-plans`. That chain once produced **1911 lines of planning artifact beside a 71-line
  `SPEC.md`**, referencing itself rather than the file the gate and skills actually read. Steps 1-5
  are the half you want. `pre-alpha/SKILL.md` says this too, at the moment it matters.
- **Pre-alpha means the walking skeleton, full stop.** Everything the skeleton does not need goes in
  `## Deferred` *at spec time*. When the requirement list becomes the scope instead, you reach
  `harden`'s gate with most of the product unbuilt and nothing notices.
- **The most important line in the spec is "Proven by."** It becomes the `prove.sh` check, which
  becomes the definition of done. Make it a value only a working system could produce — a remainder
  rather than a total, a computed figure rather than an echo.

Then `/clear`.

### Phase 2 — the walking skeleton

- **The check goes first, always.** The gate is *dormant* until the `TODO` in `prove.sh` is
  replaced, so a build that writes the check last runs its entire length unenforced. A planning
  skill will hand you a task list with it at the end; reorder it to task 1.
- **`.gitignore` the database, logs and caches on day one.** Anything the app writes into its own
  directory changes the tree hash, so the gate re-runs on every turn — and `pytest` and `ruff` add
  their own caches the moment the project goes strict.
- **Do not change the harness mid-build.** The wish goes in `## Deferred`, in one line. Harness
  changes happen in FACTORY, between projects, with evidence.

### Phase 3 — hardening

`/factory-lite:harden` once `prove.sh` passes on the skeleton. It flips the phase and the profile,
ranks `## Deferred`, and asks for one line of evidence per item.

- **Watch every new check fail on a broken input before trusting it.** Three tests in the first
  project could not fail under any input and the suite passed them happily — one of them on the
  exact behaviour its item existed to deliver. *Any assertion you have not seen fire is a decoration.*
- **An item with no evidence stays deferred.** The bug it would have prevented, or the second and
  third concrete use that now exists. Wanting it is not evidence.
- **Never fake a check you cannot run.** No type checker installed? Record it in `## Deferred` with
  that as the reason. `harden` step 5 asks for this explicitly.

### The rhythm, and why two components rather than one

One backlog item at a time → its own branch → `prove.sh` green → **the `reviewer` agent before you
stop** → merge.

The reviewer has the best record of anything here by a distance: seven dispatches across the first
project, finding a P0, a P1, three tests that could not fail, and three deleted `SPEC.md` sections —
**with `./prove.sh` green throughout all of it**. That is not a contradiction, it is the division of
labour: **a `prove.sh` gate protects against regression, not against introduction.** At the moment a
defect is written, the check that would catch it is part of the same unwritten work. The gate holds
you to what already works; the review catches what you are adding. Neither substitutes for the other.

### Where harness wishes go

**`~/dev/factory-lite/BACKLOG.md`, never the project.** Then they wait. One project's observation is
one observation, and deletions get the same bar as additions. After a project ships, run the review
procedure at the top of that file once — forward pass over the items, reverse pass over the
components, and the standing rule that adding requires deleting. Five of nine items were *rejected*
the first time it ran, which is the procedure working rather than failing.

## 6. Known edges

- Hooks are bash. Run under WSL (or Git Bash on Windows). `init.sh` strips CRLF from `prove.sh`
  and marks it executable; if the gate "never fires", check `chmod +x` and line endings first.
- `jq` is recommended (the official hook examples assume it). Without it the gate still works:
  it reads `CLAUDE_PROJECT_DIR` instead of the hook's `cwd`, so in a worktree it proves the
  main checkout. Install jq before relying on worktrees.
- `marketplace.json` `source` must be `"./"`, not `"."`. Relative sources only resolve when the
  marketplace is added via git (`/plugin marketplace add <owner>/factory-lite`), not via a raw URL.
- Path-scoped rules: quote every glob in `paths:` (YAML treats `*` and `{` as syntax) and check
  `/memory` to confirm the file loaded. Keep them in the project, not `~/.claude/rules`.
- A hook that exits 1 does **not** block; only exit 2 does. `prove.sh` can exit anything non-zero;
  the gate translates.
- Update `extraKnownMarketplaces.factory.source.repo` in `template/.claude/settings.json` if
  the plugin ever moves repos.
- **The pin enables, it does not install** (Step 6). `enabledPlugins` is a flag for a plugin that is
  already installed, and the CLI does not read `extraKnownMarketplaces` out of the settings file at
  all. `init.sh` therefore runs `claude plugin marketplace add … --scope project` and
  `claude plugin install … --scope project` for both plugins. Without them a project silently gets
  no plugin and no Stop gate — nothing errors, the gate is simply absent from `/hooks`.
  `FACTORY_SKIP_PLUGIN_INSTALL=1` suppresses that block; `harness-smoke.sh` sets it.
- **Projects track `main`, not the newest tag.** The marketplace is cloned shallow, depth 1, from the
  default branch, and tags are never fetched. Every push to `main` ships to every project. Don't push
  work in progress to it. The version number is bookkeeping — see the release rule in `BACKLOG.md`.
- Local plugin testing without the TUI: symlink (or copy) the repo to
  `<scratch>/.claude/skills/factory-lite/`; it loads as `factory-lite@skills-dir`. Remove the
  `enabledPlugins`/`extraKnownMarketplaces` keys from that scratch project's settings first so
  only one copy loads. `claude --plugin-dir` also works but launches the terminal UI.
- If `/factory-lite:spec` doesn't appear in autocomplete, type it anyway and restart the session;
  a known bug hid plugin skills from autocomplete, and the workaround is a `commands/` copy.
