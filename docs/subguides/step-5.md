# Step 5 sub-guide — Superpowers installed, priced, and scoped

**Goal:** Superpowers is installed where it belongs, you know what it costs in tokens, and no
FACTORY skill or agent is doing a job Superpowers already does.

**Done when:**
1. `/plugin` in the scratch project shows **both** plugins enabled, `factory-lite` exactly once.
2. You did one `/brainstorm` → `/factory-lite:spec` hand-off and watched what each one wrote.
3. The duplication check ran, with a written verdict per FACTORY skill and agent.
4. The cost is in `LESSONS.md` next to 32.3k (floor), 10.5k (v2), +2.4k (v3).

Everything below is either a command **I** run with my Bash tool, or a **you** action in VS Code.
Nothing here launches `claude` on its own.

**Guardrails for the whole step:**
- Install **nothing else** from that marketplace. The list is long and good-looking; that is
  exactly why the guardrail exists.
- Add no hook, agent, rule, or plugin to FACTORY in this step. The only edit FACTORY may receive
  here is a **deletion** (§6) plus its `LESSONS.md` line.
- Do not touch `template/.claude/settings.json`. Whether every future project pins Superpowers is
  a **Step 6** decision (pinning and the release rule). Deciding it here is scope creep.
- No code. This step writes a `SPEC.md` and nothing else.

---

## 0. Window layout (do this first)

Two VS Code windows again, for the same reason as Step 4: a plugin resolves at session start, and
the plugin under test lives in a different folder than the project under test.

- **Window 1 — `~/dev/factory-lite`** (this one). Scaffold fixes, `LESSONS.md`, commits, and every
  command I run. Never test from here — a slash command typed in this window returns
  `Unknown command`, because no plugin is loaded in the harness repo (Step 4 lesson).
- **Window 2 — `~/dev/scratch-super`** (created in §1). The test subject. Never fix the harness
  from Window 2.

Open Window 2 with **File → New Window**, then **File → Open Folder… → `/home/drew/dev/scratch-super`**.
Bottom-left must say `WSL: Ubuntu`. Don't open it until §1 is done — the folder won't exist, and
the extension needs at least one file present before it will open a session there (Step 1 quirk).

---

## 1. Build the scratch project — I run this

Step 4's method, verified, not redesigned. One block from Window 1:

1. `bash ~/dev/factory-lite/scripts/init.sh ~/dev/scratch-super` — copies `CLAUDE.md`, `SPEC.md`,
   `prove.sh` (CRLF-stripped, `chmod +x`), `.claude/settings.json`;
2. `git init` + first commit — the gate hashes git state to decide whether to re-run `prove.sh`;
   in a non-repo it re-runs on every chat turn;
3. `.gitignore` containing `.claude/skills/` — the symlink is a test-only artifact, and untracked
   it makes the gate's `git hash-object --stdin-paths` line choke on a directory symlink;
4. `jq` deletes `enabledPlugins` and `extraKnownMarketplaces` from the scratch
   `.claude/settings.json`, leaving only `permissions`;
5. `mkdir -p ~/dev/scratch-super/.claude/skills` **then**
   `ln -s ~/dev/factory-lite ~/dev/scratch-super/.claude/skills/factory-lite`. `init.sh` creates
   `.claude/` but not `.claude/skills/` — correctly, since the skills dir is a test-only artifact
   and no real project should get one. Without the `mkdir` the `ln` fails with a bare
   `No such file or directory`, which reads like a broken symlink target and is not.

**What you should see:** four `create` lines, then a printed `settings.json` holding **only** a
`permissions` block, then `ls -l` showing `factory-lite -> /home/drew/dev/factory-lite`.

### Why the two plugins load by two different mechanisms

This is the part to be deliberate about, because the failure mode is factory-lite loading twice.

| | factory-lite | superpowers |
|---|---|---|
| Mechanism | **skills-dir**: a symlink at `<project>/.claude/skills/factory-lite` containing `.claude-plugin/plugin.json` | **marketplace install**: `superpowers@claude-plugins-official`, project scope |
| Appears as | `factory-lite@skills-dir` | `superpowers@claude-plugins-official` |
| Why this one | it is the *thing under test* and lives in my working tree; the symlink means every scaffold fix is live in the next session with no re-copy or re-release | it is a *released dependency* I consume; there is no working tree to point at, and the marketplace pins it by commit sha |
| Recorded where | nowhere — presence of the folder is the whole mechanism | the scratch project's `.claude/settings.json` → `enabledPlugins` |

So step 4 above deletes the template's `enabledPlugins`/`extraKnownMarketplaces` keys: those pin
`factory-lite@factory` from GitHub, which would load the *released* 3.0.1 **alongside** the
symlinked working tree. In a real project it is the right and only mechanism; in the test project
it is a duplicate. After §4 the scratch `enabledPlugins` must list **superpowers and nothing else**.

---

## 2. Baseline the project *before* installing — you, Window 2, then me

Do not reuse Step 4's 34.7k as the pre-install number. Measure this project, today, so the
Superpowers delta is a subtraction between two readings taken minutes apart on one machine — the
unexplained +1.9k system-tools drift from Step 4 then cancels out instead of contaminating the
result.

Open Window 2, start a **new** session, and type these one at a time:

| Type | Expect | If not |
|---|---|---|
| `/plugin` | `factory-lite@skills-dir`, listed **once**; no `superpowers` yet | §9 symptom 2 |
| `/hooks` | exactly one `Plugin`-sourced Stop hook (`Running ./prove.sh`), alongside this machine's four user-scope hooks (one auto-accept `PreToolUse`, three `notify.js`) | §9 symptom 1 |
| `/context` | the token table — **report me the Total and the conversation/messages line** | §9 symptom 4 |

Expected Total ≈ **34.7k**, messages near zero. If it is materially different from Step 4's
reading, say so before we install anything — that difference is a finding of its own, and
installing on top of it would hide it.

Call this number **B** (baseline). I'll write it down in Window 1.

---

## 3. Add the marketplace — mostly already done

I checked this machine from Window 1 before writing the guide:

```
claude plugin marketplace list   ->  claude-plugins-official
                                     Source: GitHub (anthropics/claude-plugins-official)
claude plugin list               ->  No plugins installed.
```

So the marketplace is **already configured at user scope** (`~/.claude/plugins/known_marketplaces.json`,
last updated 2026-09-12) and nothing is installed from it. The "add the marketplace" half of this
step is therefore a **verify**, not a do. If it were missing, the extension path is
**`/` → Customize → Plugins → Add marketplace → `anthropics/claude-plugins-official`**, and the
print-and-exit equivalent I can run is
`claude plugin marketplace add anthropics/claude-plugins-official`.

Worth knowing what you are installing: in that marketplace, `superpowers` is not an Anthropic-hosted
copy — its source is `https://github.com/obra/superpowers.git` **pinned to a commit sha**. You get
that exact commit, not whatever `main` says today, and it moves only when the marketplace updates.

---

## 4. Install Superpowers at project scope — you, Window 2

**`/` → Customize → Plugins → `claude-plugins-official` → `superpowers` → Install → scope: project.**

Project scope, not user scope, for three reasons: the cost is charged per session in every folder
a user-scope plugin covers; Window 1 (the harness repo) has no business loading it; and README §3
already says to widen to user scope later *only if* `/context` stays cheap. Widening is a one-click
change later; a machine-wide install you then have to remember to undo is not.

If the Customize menu on 2.1.269 offers no scope choice (its contents vary by release), stop and
tell me — I'll run the print-and-exit equivalent from Window 1 with cwd set to the scratch project:

```
claude plugin install superpowers@claude-plugins-official --scope project
```

Then, before opening a new session, I will print the scratch `.claude/settings.json` and check:

- `enabledPlugins` contains **`superpowers@claude-plugins-official`: true** and nothing else;
- no `factory-lite@factory` key came back;
- no `extraKnownMarketplaces` block came back.

**Then start a NEW session in Window 2.** A plugin resolves at session start; installing inside a
live session changes nothing about that session.

---

## 5. Price it — you read, I record

In the new session, one at a time:

| Type | What to report back |
|---|---|
| `/plugin` | both entries: `factory-lite@skills-dir` **once** and `superpowers@claude-plugins-official`, both enabled |
| `/hooks` | any **new** hook rows sourced from the superpowers plugin — Superpowers ships a `SessionStart` bootstrap, so expect at least one |
| `/context` | the Total, the conversation/messages line, **and** the per-bucket lines (system prompt · system tools · memory files · custom agents · skills) |

Call the new total **N**. The arithmetic, so we don't fool ourselves:

```
superpowers cost   = N − B                 (B from §2, same project, same day)
whole harness cost = N − 32.3k             (empty-folder floor, LESSONS.md)
judgement          = whole harness cost  vs  v2's ~10.5k
```

- **Under 10.5k combined:** pass. v3 + Superpowers costs less than v2's bare harness did, while
  doing considerably more.
- **Approaching 30k:** report it as a **failure of this step**, not a pass. The 30k budget written
  in the original plan is three times all of v2; it was never a target, and the "15% of the
  window" rule it came from is dead (15% of 1M is 150k).
- **In between:** report the number plainly with the per-bucket breakdown and let the size of the
  jump argue for itself. Do not round it in Superpowers' favour.

### The SessionStart bootstrap needs separating out

Superpowers injects content at session start. That lands in a different `/context` bucket than an
always-on skill description — most likely it shows up in **messages/conversation** rather than in
**skills**, which is why §2 asked for the messages line too.

If `N − B` is large, I will not report a single number. I will report:

- how much landed in **skills** (always-on skill frontmatter — the per-prompt rent);
- how much landed in **messages** at turn zero (the bootstrap — also paid every session, so it
  counts as harness cost, but it is a different thing and a different fix);
- how much landed anywhere else.

The cross-check, which I run from Window 1 once the folder is trusted on the CLI side:

```
claude plugin details superpowers      # component inventory + projected always-on / on-invoke cost
```

Read it *alongside* `/context`, never instead of it: it counts only what the plugin contributes and
knows nothing about the bootstrap's injected text or the project's own files. `/context` in
Window 2 is the number of record. And if that command prints "skipped because this workspace was
not trusted when plugins were scanned", that is the CLI's own trust store talking, not a statement
about what your session loaded (Step 4 lesson) — the first `claude` subcommand in the folder raises
the CLI trust prompt; accept it and re-run.

**Standing caveat, restated because a good number here is the easiest thing to over-read:** v2's
damage was behavioural, not contextual. v2 only ever cost 10.5k. A cheap Superpowers is necessary
and not sufficient; §6 and §7 are what actually test whether it earns its place.

---

## 6. The duplication check — the real work of this step

### 6a. Skills and agents

FACTORY-lite currently ships four skills and two agents:

| FACTORY component | Its job, stated narrowly |
|---|---|
| `pre-alpha` (auto-loads) | what to build first and what not to abstract, while `SPEC.md` says Phase: pre-alpha |
| `verify` (auto-loads) | what counts as proof here: run `./prove.sh`, show evidence, never weaken a check |
| `spec` (`/factory-lite:spec`) | interview → write `SPEC.md` → update CLAUDE.md's Run/prove lines; no code |
| `harden` (`/factory-lite:harden`) | the phase-change ritual: lite → strict profile, ranked backlog, extend the gate |
| `explorer` agent | read-only research off the main context, haiku |
| `reviewer` agent | fresh-context gap review of a diff against `SPEC.md`, opus |

Once Superpowers is installed I will list its actual skills from Window 1 (`claude plugin details
superpowers`, plus the installed plugin directory) rather than trusting the marketplace blurb, and
put them side by side with the table above. Its own description advertises brainstorming, subagent-
driven development with built-in code review, systematic debugging, red/green TDD, and skill
authoring — so the three collisions to look at hardest are predictable:

| Suspected collision | The question that decides it |
|---|---|
| Superpowers brainstorming vs `spec` | Does brainstorming end in a **committed `SPEC.md` with a named walking skeleton and a first `prove.sh` check**, or in a discussion? If it produces a competing plan document, that is a collision. If it produces raw material that `spec` then commits, it is a hand-off — which is exactly what §7 tests. |
| Superpowers' code review vs `reviewer` | Is Superpowers' review a **general** code review, or a review **against `SPEC.md`**? FACTORY's reviewer only exists to catch spec gaps. General code quality is Superpowers' job. |
| Superpowers TDD / verification vs `verify` | Does Superpowers define what "done" means **for this project**? It cannot — `prove.sh` and the Stop gate do. `verify` is the local contract, not a testing methodology. |

**The decision rule, from README §3 and applied without sentiment:** Superpowers owns the *method*
(how to think, plan, test, debug). FACTORY owns the *contract* (what "done" means here, and the
phase discipline). If a FACTORY component turns out to own a method, it goes.

**If a collision is real, the fix is deletion, not coexistence.** That means, in order, and only in
`~/dev/factory-lite`:

1. delete the skill or agent from the scaffold;
2. a `LESSONS.md` line saying which one, what replaced it, and how it was decided;
3. re-test **everything**: `bash scripts/harness-smoke.sh`, then all four validate calls
   (`claude plugin validate .` covers the *marketplace* manifest only — the plugin manifest and
   components need `claude plugin validate .claude-plugin/plugin.json --strict`,
   `... validate skills --strict`, `... validate agents --strict`);
4. bump `version` in **both** `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`
   (both say 3.0.1 → 3.0.2), commit, tag, push.

A near-miss is not a collision. Overlapping *vocabulary* is not a collision. If I can state a
FACTORY component's job in one sentence that Superpowers' equivalent does not do, it stays, and I
write that sentence into `LESSONS.md` so Step 6 doesn't relitigate it.

### 6b. The shadowing check

A **project** agent silently overrides a **plugin** agent of the same name — no warning, no log
line; the plugin one simply never loads. Three cheap checks I run from Window 1:

```
ls -la ~/dev/scratch-super/.claude/agents   2>/dev/null   # must not exist
ls -la ~/.claude/agents                     2>/dev/null   # user-scope agents shadow plugin ones too
ls -la ~/dev/.claude                        2>/dev/null   # the stale parent-dir settings from BACKLOG chore 2
```

`init.sh` never creates `.claude/agents/`, so the scratch project should be clean and this is
really a check on **this machine** and a rehearsal for real projects — a v2 project with a leftover
`reviewer.md` is the exact case that bites. If a user-scope `reviewer.md` or `explorer.md` exists,
that is a finding for `BACKLOG.md`'s environment-chores list (like the auto-accept hook), not a
FACTORY change.

---

## 7. The `/brainstorm` → `/factory-lite:spec` hand-off — you, Window 2

One trial, one throwaway idea. Something small and concrete you can judge in two minutes — the
point is the seam between the two tools, not the idea.

1. Run Superpowers' brainstorming skill. **Take the exact command name from `/plugin`** (or from
   the `claude plugin details superpowers` inventory I'll have printed in §5) rather than guessing:
   plugin skills are namespaced, so it may be `/superpowers:brainstorm` and not `/brainstorm`. If
   it returns `Unknown command`, first confirm the window is rooted in `~/dev/scratch-super` and
   not the harness repo (Step 4 lesson), then §9 symptom 3.
2. Let it run to its natural end. **Note what it wrote to disk, if anything, and where.**
3. Then `/factory-lite:spec <your one-line idea>` in the **same** session, feeding it what
   brainstorming produced.

What to watch for, and tell me about — this is the evidence the step exists to collect:

- Did `spec` **re-interview** you on things brainstorming already settled? That is friction worth a
  `BACKLOG.md` wish (one clause in `skills/spec/SKILL.md`: read an existing brainstorm artifact
  first), not a plugin change today.
- Did brainstorming write a **plan document that competes with `SPEC.md`**? That is the §6a
  collision question, answered live.
- Did `SPEC.md` come out with `Phase: pre-alpha`, a named walking skeleton, and one check that can
  become the first line of `prove.sh`? That is `spec` doing its job regardless of what came before.
- Known and expected: `CLAUDE.md` will still open with the literal `# <project name>` placeholder.
  That is `BACKLOG.md` item 1, already logged in Step 4. If it happens again, I add "second
  project's evidence" to that item — which is the condition it was waiting on.
- Also expected, and a free re-confirmation of the 3.0.1 fix: when the `spec` turn ends, the Stop
  gate should announce it is **dormant** (the template `prove.sh` still holds its TODO sentinel)
  and let the turn stop. If it *blocks* the spec turn, that is a regression and we stop and fix
  before anything else.

Write no code. If either tool starts implementing, stop it — that is a finding too.

---

## 8. Close out — I do this, in Window 1

1. `LESSONS.md` gets a new `## Cost of Superpowers (Step 5, 2026-09-12)` section placed directly
   after the v3 section, so all four numbers sit together: floor 32.3k · v2 10.5k · v3 +2.4k ·
   Superpowers `N − B` · combined `N − 32.3k` — plus the bootstrap-vs-always-on split, the
   duplication verdict per component, and one sentence on how the hand-off actually went.
2. Any *defect* found goes into `LESSONS.md`; any *wish* goes into `BACKLOG.md` in that file's item
   format, with evidence. Never straight into the plugin.
3. Tick Step 5's box in `START-HERE.md` and fold the corrections into the Context block and the
   Step 6 brief, the way Steps 2, 3 and 4 did. Step 6 is pinning and the release rule, so anything
   learned here about `enabledPlugins` and scope belongs in that brief.
4. **Delete the scratch project:** `rm -rf ~/dev/scratch-super`. I'll show you `ls ~/dev` before and
   after, and I won't run it until you say so. Keeping it is how a scratch project becomes a second
   source of truth.
5. Commit in `~/dev/factory-lite`: `step 5 done: Superpowers priced and scoped`.

Note what close-out does **not** include: Superpowers stays installed only in a project I am about
to delete. Pinning it for real projects is Step 6.

---

## 9. Troubleshooting

| Symptom | Check |
|---|---|
| 1. `/hooks` shows no `Plugin` Stop hook | Did you start a **new** session after the symlink existed? Then check `~/dev/scratch-super/.claude/skills/factory-lite/.claude-plugin/plugin.json` resolves. If the extension won't follow the symlink, `cp -r` the repo there instead — and remember every scaffold fix then needs a re-copy. |
| 2. `factory-lite` appears **twice** in `/plugin` | The §1 `jq` strip didn't take, or the §4 install rewrote `enabledPlugins` and brought `factory-lite@factory` back. I'll print the scratch `.claude/settings.json` and fix it, then you restart the session. Do not measure anything until it is once. |
| 3. `superpowers` missing from `/plugin` after install | (a) new session started? (b) did it install at **project** scope — is the key in the scratch `.claude/settings.json` and not `~/.claude/settings.json`? (c) is the window rooted in `~/dev/scratch-super`? |
| 4. `/context` prints no path line | Known extension quirk (Step 1). It is not evidence of anything. |
| 5. `claude plugin …` says "workspace was not trusted when plugins were scanned" | CLI trust store, separate from the extension's. The first `claude` subcommand in the folder raises the prompt; accept it, re-run. It says nothing about what your session loaded. |
| 6. A slash command returns `Unknown command` | Which folder is that window rooted in? The harness repo has no plugin loaded (Step 4 lesson). Then check the namespace: `/superpowers:x` vs `/x`. |
| 7. Superpowers suggests installing companions, or asks to enable more skills | No. §0 guardrail. Note the suggestion in `BACKLOG.md` if it looked genuinely useful and move on. |
| 8. The combined number lands near 30k | Report it as a failed step with the per-bucket breakdown, and we decide between user-scope-off, project-scope-only, or not adopting it. Do not pass it because it is "still only 3% of the window". |

---

## 10. If something in FACTORY misbehaves — the fix-and-re-release path

Unchanged from Step 4, and it is a guardrail, not a suggestion: **fixed in `~/dev/factory-lite`,
re-tested, re-released. Never patched in the scratch project.** The symlink makes a fix live in the
next scratch session, but "live" is not "released".

```
# 1. fix in ~/dev/factory-lite
# 2. re-test — ALL of these, not just the first:
bash scripts/harness-smoke.sh                                   # -> harness smoke: PASS
claude plugin validate .                                        # marketplace manifest ONLY
claude plugin validate .claude-plugin/plugin.json --strict      # the plugin manifest
claude plugin validate skills --strict
claude plugin validate agents --strict
# 3. you confirm the fix in a NEW session in Window 2
# 4. bump "version" in BOTH .claude-plugin/plugin.json AND .claude-plugin/marketplace.json
#    (3.0.1 -> 3.0.2), commit, git tag v3.0.2, git push && git push --tags
```

Both manifests get bumped or the two disagree about what 3.0.2 is. Batch several fixes into one
bump.

---

## 11. What this guide got wrong (written after executing it)

Kept rather than silently edited, because the errors are the useful part.

- **§2's measuring method was unsound.** "Take a baseline, install, subtract" assumes the buckets
  you don't own hold still. `system tools` read 25.4k · 27.3k · 27.3k · 26.5k · 24.5k across five
  sessions — a ±2.8k swing that made the raw startup *fall* 2.1k after installing a plugin. The
  method that works is the one LESSONS.md now records: **sum the buckets you control**
  (custom agents + memory files + skills + messages at turn zero) and ignore the total.
- **§7 predicted the wrong collision.** It expected `brainstorming` to write and commit
  `docs/superpowers/specs/<date>-<topic>-design.md` and hand off to `writing-plans`. It did
  neither — it wrote FACTORY's own `SPEC.md`, filled CLAUDE.md's Run/prove lines *and* its title,
  and stopped. The collision is the opposite shape: Superpowers doesn't compete with the artifact,
  it **outperforms the skill that writes it**.
- **§7 was wrong that there is no slash command.** No `commands/` directory does not mean no slash
  command: `/superpowers:brainstorming` autocompletes and runs. Every skill in a plugin is
  reachable that way.
- **§2 and §5 said "type these in the chat box" without saying who types them.** Relaying
  `/plugin`, `/hooks`, `/context` to the session produces an agent reading config files and
  inferring — which here concluded the Stop gate "is not loaded" while the gate's own message was
  printing in that same turn. **Say: the human types client commands.**
- **§1 omitted a `mkdir`** (corrected in place above).
- **What the guide got right and is worth keeping:** insisting on a fresh session for the
  measurement (the first reading came from a session with 15.3k of messages in it and was
  worthless); reading the Superpowers skills rather than their names before judging duplication;
  and refusing to price the SessionStart hook from `claude plugin details`, which calls a
  ~1.3k-per-session context injection "no model context cost".
