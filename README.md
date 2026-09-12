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
│   ├── explorer.md                        read-only research, haiku
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

Every component here follows the header convention in `hooks/stop-gate.sh`: **what assumption
about the model it encodes, what evidence motivated it, and when to delete it**. That is the
"what can I stop doing?" pass Anthropic recommends, made routine.

| Piece | Assumption it encodes | Delete when |
|---|---|---|
| Stop gate (`prove.sh`) | Claude sometimes stops before the check passes | it passes first time on >95% of the stops **where the gate actually ran** — see below |
| `pre-alpha` skill | Claude over-abstracts before there's a working slice | `/doctor` says it's redundant or a model release fixes it |
| `reviewer` agent | the agent that wrote the code grades itself generously | never, cheap and still recommended by Anthropic |
| `explorer` agent | research bloats the main context | never, same reason |
| `spec` + `harden` commands | phase changes need a deliberate ritual | you stop skipping them |

**Reading the Stop gate's delete-when.** "Stops" is not every stop. The gate hashes the tree
(HEAD + staged/unstaged diff + untracked non-ignored file contents) and exits 0 without running
`prove.sh` when nothing has changed since the last PASS, so chat-only turns never reach the check
and must not be counted as passes — doing so inflates the ratio toward 95% with conversation and
retires the gate on the strength of chatter. Count only stops after a tree change. In a non-repo
the gate never skips at all (the fallback state can never match), which is one more reason to
`git init` before the first session.

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
bash ~/dev/factory-lite/scripts/init.sh my-app && cd my-app && git init   # then open the folder in VS Code
/factory-lite:spec  <one-line idea>       # interview -> SPEC.md. No code.
/clear                                     # fresh context for implementation
"Implement the walking skeleton in SPEC.md. Write the ./prove.sh check first, then make it pass."
                                           # the Stop gate keeps the session honest
/factory-lite:harden                       # only after prove.sh passes on the skeleton
```

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
