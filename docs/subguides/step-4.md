# Step 4 sub-guide — Prove the harness live, inside the extension

**Goal:** watch the Stop gate block a premature stop and then release once `./prove.sh` passes,
with your own eyes, without ever opening the terminal UI. Then record what the harness costs.

**Done when:**
1. You saw the gate block a stop, and saw it release after the check passed.
2. The scratch project's `/context` number is written into `LESSONS.md` next to v2's.

Everything below is either a command **I** run with my Bash tool, or a **you** action in VS Code.
Nothing here launches `claude` on its own.

---

## 0. Window layout (do this first)

You need **two VS Code windows**, because a plugin only loads at session start and the plugin
under test lives in a different folder than the project under test.

- **Window 1 — `~/dev/factory-lite`** (this one). Keep this session open. It is where scaffold
  fixes, `LESSONS.md`, and commits happen.
- **Window 2 — `~/dev/scratch-hello`** (created in §1). A *fresh* Claude session there is the test
  subject. Never fix the harness from Window 2.

Open Window 2 with **File → New Window**, then **File → Open Folder… → `/home/drew/dev/scratch-hello`**.
It must say `WSL: Ubuntu` in the bottom-left. Do not open it until §1 is finished — the folder
won't exist yet, and the extension needs at least one file present (Step 1 quirk).

---

## 1. Build the scratch project — I run this

One command block, run from Window 1 with my Bash tool. It:

1. makes `~/dev/scratch-hello` (a sibling of the repo, never nested inside it);
2. runs `bash ~/dev/factory-lite/scripts/init.sh ~/dev/scratch-hello` — copies `CLAUDE.md`,
   `SPEC.md`, `prove.sh` (stripped of CRLF, `chmod +x`), `.claude/settings.json`;
3. `git init` + first commit — the gate hashes git state to decide whether to re-run `prove.sh`,
   so a non-repo makes it re-run on every chat turn;
4. writes `.gitignore` containing `.claude/skills/` — the symlink is a test-only artifact, and
   leaving it untracked makes the gate's `git hash-object --stdin-paths` line choke on a
   directory symlink (harmless, but noise);
5. deletes `enabledPlugins` and `extraKnownMarketplaces` from the scratch
   `.claude/settings.json` with `jq`, leaving only `permissions` — **two copies of factory-lite
   loading at once is the known failure mode** (`START-HERE.md` troubleshooting table);
6. symlinks the repo in: `ln -s ~/dev/factory-lite ~/dev/scratch-hello/.claude/skills/factory-lite`.

**What you should see:** `create CLAUDE.md / create SPEC.md / create prove.sh /
create .claude/settings.json`, then a printed `settings.json` containing **only** a `permissions`
block, then `ls -l` showing `factory-lite -> /home/drew/dev/factory-lite`.

> Why a symlink and not `claude --plugin-dir`: `--plugin-dir` launches the terminal UI. A folder
> under `<project>/.claude/skills/` that contains `.claude-plugin/plugin.json` loads as a plugin
> with no marketplace and no install, appearing as **`factory-lite@skills-dir`**. Because it is a
> symlink to the working tree, any scaffold fix is live in the scratch project on the *next*
> session — no re-copy.
>
> Fallback if the extension refuses to follow the symlink (§7, symptom 1): `cp -r` the repo there
> instead, and remember that then every scaffold fix needs a re-copy.

---

## 2. Load the harness and verify it — you, in Window 2

Open `~/dev/scratch-hello` (see §0) and start a **new** session in the Claude Code extension.
Not a resumed one: plugins are resolved at session start.

**The CLI keeps its own trust record, separate from the extension's.** Observed here: the
extension opened sessions in both `~/dev/factory-lite` and `~/dev/scratch-hello` and ran freely
with no dialog, while `~/.claude.json` held no `.projects` entry for either — only the four
v2-era paths, each with `hasTrustDialogAccepted: true`. Until the folder is trusted *on the CLI
side*, every `claude plugin …` call there reports the skills-dir plugin as "skipped because this
workspace was not trusted when plugins were scanned", which is a statement about the CLI's store
and **not** about what your extension session loaded.

The CLI raises its own trust prompt the first time you run a `claude` subcommand in the folder;
clicking trust writes `hasTrustDialogAccepted: true` and both commands below start working. So
read `/plugin` in the session as authoritative for the session, and treat a CLI "untrusted"
warning as a CLI-store artifact, not a failed load.

Permission prompts are expected now — Step 1 removed `bypassPermissions` from the WSL machine
settings. Approve them as they come; that is the harness behaving correctly.

Type these in the chat box, one at a time:

| Type | Expect to see | If not |
|---|---|---|
| `/hooks` | exactly **one Stop hook whose source is `Plugin`** (statusMessage `Running ./prove.sh`). User-scope hooks from `~/.claude` sit alongside it — this machine has four: a `PreToolUse` auto-accept and three `notify.js` notifier hooks. Count only the `Plugin`-sourced one. | §7 symptom 1 |
| `/context` | the token table. **Write down the Total, and the line for the conversation/messages** | §7 symptom 2 |
| `/plugin` | `factory-lite@skills-dir` listed once — **once**, not twice | §7 symptom 3 |

Report those three results back to me in Window 1. Two Stop hooks, or a `factory-lite@factory`
entry alongside the skills-dir one, means §1 step 5 didn't take and we stop and fix before
measuring anything.

**The `claude plugin details` cross-check works here — Step 3's blocker is gone.** Once the folder
is trusted on the CLI side, both of these print and exit from Window 1 with cwd set to the scratch
project:

```
claude plugin list                  # -> factory-lite@skills-dir  3.0.0  project  Status: ✔ loaded
claude plugin details factory-lite  # -> component inventory + projected token cost
```

Actual output, recorded 2026-09-12 at v3.0.0:

```
Component inventory
  Skills (4)  harden, pre-alpha, spec, verify
  Agents (2)  explorer, reviewer
  Hooks (1)  Stop  (harness-only — no model context cost)
  MCP servers (0) · LSP servers (0)

Projected token cost
  Always-on:   ~377 tok   added to every session
  per-component always-on: verify ~50 · pre-alpha ~70 · spec ~50 · harden ~70 · explorer ~70 · reviewer ~80
  on-invoke:               verify ~270 · pre-alpha ~720 · spec ~320 · harden ~430 · explorer ~120 · reviewer ~310
```

Read it as a *cross-check on* `/context`, not a replacement: it counts only what the plugin
contributes (~377 always-on), and says nothing about the template `CLAUDE.md` and `SPEC.md` the
project itself loads. `/context` in Window 2 remains the number of record for §3.

---

## 3. Record the number — I write it, you read it

Arithmetic, so we don't fool ourselves:

```
startup       = /context Total − the conversation/messages line
harness cost  = startup − 32.3k            (the empty-folder floor, LESSONS.md)
judgement     = harness cost vs v2's ~10.5k
```

- **Under 10.5k:** v3 is cheaper than v2 *and* doing less. That is the target.
- **Near or above 10.5k:** report it as a failure of this step, not a pass — v3 ships fewer
  components than v2, so it has no excuse to cost more.
- **Never** phrase it as "a fraction of v2's". v2's *total* startup was 42.8k but its *harness*
  was only ~10.5k; nothing can be a fraction of that. The comparison is above-the-floor to
  above-the-floor.
- And Step 2's headline stands: **v2's damage was behavioural, not contextual.** A good number
  here is necessary and not sufficient. §4 is the part that actually tests behaviour.

I'll add it to `LESSONS.md` under a new `## Startup cost of v3 (Step 4, <date>)` heading placed
directly after the v2 section, so the two numbers sit next to each other: total, messages,
startup, cost above floor, the per-component breakdown `/context` shows, and the verdict in one
sentence.

---

## 4. Walk the whole loop — you, in Window 2

Trivial subject on purpose: a CLI that prints hello. We are testing the harness, not the program.

### 4a. `/factory-lite:spec a CLI that prints hello`

Expect an interview (multiple-choice questions), then `SPEC.md` filled in with `Phase: pre-alpha`,
a "Proven by" line, and `CLAUDE.md`'s Run/prove lines updated. **No code.**

> **Predicted finding A — watch for this.** `init.sh` ships `prove.sh` as a template that
> deliberately exits 1 (`echo "TODO: write the walking-skeleton check…" >&2; exit 1`). The Stop
> gate runs on *every* stop, including this chat-only spec turn. So the spec turn will very likely
> be **blocked** by the gate and Claude will be pushed to edit `prove.sh` mid-interview — during a
> phase whose whole rule is "writes no code". If that happens, it is a real scaffold defect: on a
> brand-new project, turn one of any conversation is gated before any code exists.
>
> Don't patch it in the scratch project. Tell me, and we fix it in `~/dev/factory-lite`. The
> candidate fix is one condition in `hooks/stop-gate.sh`: exit 0 while `prove.sh` still contains
> the untouched `TODO: write the walking-skeleton check` sentinel, so the gate arms itself the
> moment a real check is written and stays silent before that. That adds no hook, agent, rule or
> plugin — it edits the one hook that already exists. Re-test and re-release per §6, plus a
> `LESSONS.md` line.
>
> If it *doesn't* fire here, say so — that is equally worth recording.

### 4b. `/clear`

Fresh context for implementation. This is the method, not a nicety.

### 4c. The implement prompt

Paste exactly:

```
Implement the walking skeleton in SPEC.md. Write the ./prove.sh check first, then make it pass.
```

**What you are watching for — this is the whole step.** When Claude tries to stop while
`./prove.sh` still fails, the gate exits 2 and you see the turn *continue* instead of ending, with
the gate's message in the transcript:

```
./prove.sh failed (exit 1). Fix the root cause, re-run ./prove.sh, show the result, then stop.
Do not weaken or skip a check to make it pass. If the check itself is wrong, say so explicitly.
--- last 40 lines of ./prove.sh ---
```

Then Claude fixes it, `./prove.sh` exits 0, and the next stop is **not** blocked. That pair —
block, then release — is the Done-when. Screenshot it if you like; it is the one thing this whole
step exists to produce.

Two behaviours that are by design, not bugs:
- **Three strikes and it lets go.** If `prove.sh` fails on three consecutive gated stops, the gate
  exits 0 with `FACTORY gate: ./prove.sh still failing after 3 attempts. Stopping so you can
  look.` That is the loop guard releasing you, not the check passing — it does **not** satisfy the
  Done-when. Read `./prove.sh` yourself and restart the turn.
- **Chat-only turns are free.** After a PASS, the gate records the git tree state and skips
  re-running `prove.sh` until something changes.

**If the gate never blocks** (Claude writes the check and passes it before its first stop):
that's a clean run, not a failure — but you still need to see a block. Then, in the scratch
project, break the skeleton on purpose: edit the printed string so the check can't match, and ask
Claude "is that still working? stop when you're done looking." The gate must block on that stop.
Fix, watch it release. Breaking the *test subject* is fine; breaking the harness to make a point
is not.

### 4d. `/factory-lite:harden`

Expect the checklist in order: confirm `prove.sh` passes → `reviewer` subagent reviews the
skeleton against `SPEC.md` → `Phase: pre-alpha` becomes `Phase: hardening` in `SPEC.md` and the
`PROFILE` default in `prove.sh` becomes `strict` → `## Deferred` turned into a ranked backlog with
evidence per item → `prove.sh` extended and still passing.

Verify by eye in Window 2: open `SPEC.md`, confirm `Phase: hardening`. Open `prove.sh`, confirm
the `PROFILE=` line now defaults to `strict`.

> **Predicted finding B.** The `harden` skill says *"In `./prove.sh` change `PROFILE=lite` to
> `PROFILE=strict`"*, but the template line is `PROFILE="${HARNESS_PROFILE:-lite}"` — the literal
> string the skill names does not exist in the file. Claude will probably do the right thing
> anyway; if it hesitates, edits the wrong thing, or rewrites the line and loses the
> `HARNESS_PROFILE` override, that is a scaffold wording bug. Fix = reword step 3 of
> `skills/harden/SKILL.md` to name the actual line. Same re-release path (§6).

---

## 5. Close out — I do this, in Window 1

1. `LESSONS.md` gets the v3 startup number (§3) and one line per finding actually observed
   (A, B, or anything new). Findings that are *wishes* rather than defects go to `BACKLOG.md` in
   the item format that file already defines — never straight into the plugin.
2. Tick Step 4's box in `START-HERE.md`, and fold the corrections into the Context block and the
   Step 5 brief the way Steps 2 and 3 did.
3. **Delete the scratch project:** `rm -rf ~/dev/scratch-hello`. I will show you `ls ~/dev` before
   and after, and I will not run it until you say so. Nothing in it is worth keeping; keeping it
   is how a scratch project becomes a second source of truth.
4. Commit in `~/dev/factory-lite`: `step 4 done: gate proven live, v3 startup recorded`.

---

## 6. If something misbehaves — the fix-and-re-release path

Guardrail: **fixed in `~/dev/factory-lite`, re-tested, re-released. Never patched in the scratch
project.** Because the scratch loads the repo through a symlink, a fix is live there on the next
session start — but "live" is not "released".

Order, run by me from Window 1:

```
# 1. fix in ~/dev/factory-lite
# 2. re-test — ALL of these, not just the first one:
bash scripts/harness-smoke.sh                                   # -> harness smoke: PASS
claude plugin validate .                                        # marketplace manifest ONLY
claude plugin validate .claude-plugin/plugin.json --strict      # the plugin manifest
claude plugin validate skills --strict
claude plugin validate agents --strict
# 3. you confirm the fix in a NEW session in Window 2
# 4. bump "version" in BOTH .claude-plugin/plugin.json AND .claude-plugin/marketplace.json
#    (both currently 3.0.0 -> 3.0.1), commit, git tag v3.0.1, git push && git push --tags
```

Both manifests get bumped or the two disagree about what v3.0.1 is. Batch several fixes into one
bump — one release at the end of the evening beats three tags in an hour.

---

## 7. Troubleshooting

| Symptom | First thing to check |
|---|---|
| 1. `/hooks` shows nothing | Did you start a **new** session after the symlink existed? Plugins resolve at session start. Then check `~/dev/scratch-hello/.claude/skills/factory-lite/.claude-plugin/plugin.json` resolves; if the extension won't follow the symlink, `cp -r` instead (§1). Note `claude plugin list` is only a valid cross-check once the folder is trusted **on the CLI side** (§2) — an untrusted CLI store prints a "skipped … not trusted" warning that has nothing to do with the session. |
| 2. `/context` shows no path line | Expected — Step 1 found the extension prints only the token table. Ask "what is your working directory?" in the chat box if you need to confirm the folder. |
| 3. factory-lite listed twice | The `enabledPlugins` / `extraKnownMarketplaces` keys came back in the scratch `.claude/settings.json`, or a user-scope install exists. Remove them; restart the session. |
| 4. The gate never fires at all | `/hooks` shows the Stop hook? `ls -l ~/dev/scratch-hello/prove.sh` executable? No CRLF? (`init.sh` handles both — if not, that is finding worth logging.) |
| 5. The gate blocks forever | It self-releases after 3 strikes, and Claude Code caps at 8. Run `./prove.sh` in Window 2's integrated terminal and read the output. |
| 6. `/factory-lite:spec` missing from autocomplete | Known bug — type it anyway and restart the session. Do not add a `commands/` copy to fix it unless it genuinely fails to run; that is a `BACKLOG.md` item. |

---

## 8. Scope fence for this step

This step **observes** the harness. It adds no hook, no agent, no rule, no plugin, no MCP server —
not even a tempting one-liner, and not in the scratch project either. Superpowers is Step 5; don't
install it early to "see how it interacts". The only edits this step may produce are: a fix to an
already-existing scaffold file, a line in `LESSONS.md`, a line in `BACKLOG.md`, and the Step 4
updates to `START-HERE.md`.
