# Step 7 sub-guide — the first real project, pre-alpha only

**The idea:** a nutrition and fitness tool that tracks intake (calories, macros, micros), tracks
body measurements over time, recommends workouts from available equipment plus goal plus recovery,
and over time learns enough about me to coach rather than just record.

**Language:** Python. `uv 0.12.9`, `ruff 0.16.6`, `python3 3.13.15` and stdlib `sqlite3 3.53.1` are
already on this machine (checked, §0). The skeleton therefore needs **no install step and no
dependencies**. TypeScript would need a corepack/pnpm bootstrap before the first line ran, which
puts an install step in front of a walking skeleton.

**Goal:** something runs end to end, proven by `./prove.sh`, before any architecture exists.

**Done when:**
1. `./prove.sh` passes on the walking skeleton, and the check in it is the one named in SPEC.md
   "Proven by" — not a weaker one.
2. The Stop gate is **armed** (not dormant) and has been seen to block at least once.
3. A human can run the thing with the one command written in `CLAUDE.md`.
4. BACKLOG item 2 has an answer recorded from observation (§5), and the gate-block tally (§8)
   is written into LESSONS.md.

Everything below is either a command **I** run with my Bash tool, or a **you** action in VS Code.
Nothing here launches `claude` on its own.

---

## Guardrails for the whole step

- **No new hooks, agents, rules, plugins, or MCP servers. Not one.** That is the rule v2 broke.
- **No harness edits** unless the harness is actually broken, and then by the release rule at the
  top of `BACKLOG.md`, from `~/dev/factory-lite`, never from the project.
- **Do not push work in progress to the harness's `main`.** Step 6 proved projects clone `main`
  shallow at depth 1 and never fetch tags, so every push ships to this project immediately. From
  this step on, `main` is production.
- **Do not decide BACKLOG items 4 or 5.** They were deliberately left undecided in Step 6. If this
  project produces real evidence for one of them, add the evidence line and leave the status
  `waiting`.
- **No `/context` re-pricing.** Step 5 settled the numbers and established that the Total cannot be
  differenced.
- **If I am asked to weaken `./prove.sh` to make a problem go away, I refuse** and report what the
  check is actually testing. The gate did exactly that three times in Step 4 and that was the
  result worth having.
- **Product wishes → `SPEC.md` `## Deferred`. Harness wishes → FACTORY's `BACKLOG.md`. Neither
  gets built mid-project.**

---

## 0. What I already checked, so no session re-derives it

I read `README.md`, `START-HERE.md`, `BACKLOG.md`, `LESSONS.md`, all four skills, `hooks.json`,
`stop-gate.sh`, `scripts/init.sh` and the whole `template/` before writing this.

1. **The toolchain is present.** `uv 0.12.9`, `ruff 0.16.6`, `python3 3.13.15`, stdlib `sqlite3
   3.53.1`, `corepack` present but `pnpm` absent. `pytest` is not on PATH — it does not need to be,
   because pre-alpha's definition of done is one check in `prove.sh`, not a suite. That question
   belongs to Step 8.
2. **The auto-accept blocker is one extension, and it has a clean teardown.**
   `tjcg.auto-accept-claude-code` v0.5.0 owns *all four* disarm paths, which is why Step 1's fix
   came back — it rewrites them on every activation (`onStartupFinished`). Details and the reversal
   in §1. This closes BACKLOG chore 1's open question of who the owner is.
3. **`permissions.defaultMode: "auto"` in `~/.claude/settings.json` is NOT extension-owned.** It
   carries no `_autoAcceptManaged` marker, so the extension's teardown will leave it behind. It
   needs a hand edit, and unlike the others it will stay fixed.
4. **The gate arms on the sentinel string, not on file contents generally.** `stop-gate.sh` greps
   for the literal `TODO: write the walking-skeleton check`. Deleting that one line is what arms
   the gate. A `prove.sh` that still contains it announces `FACTORY gate: dormant.` and blocks
   nothing, however much real code sits around it.
5. **The gate's denominator is not "turns".** It hashes HEAD + staged/unstaged diff + untracked
   file contents, and exits 0 without running `prove.sh` when the tree is unchanged since the last
   PASS. So chat-only turns never reach the check. §8's tally must count *stops where the gate
   actually ran*, or the >95% figure is inflated by conversation.
6. **`init.sh` will now prompt.** Once §1 is done, permissions are live, so my Bash calls and
   `init.sh`'s two `claude plugin install` calls will raise dialogs. That is the point of §1, not a
   malfunction.

---

## 1. Clear the blocker first (BACKLOG chore 1, deadline: this step)

BACKLOG chore 1 set the deadline at *before Step 7* on the reasoning that harness work is cheap to
get wrong and a real project is not. This is that moment.

### 1a. What is actually there

One extension, four paths, written fresh on every VS Code startup:

| Path | Content | Owner |
|---|---|---|
| `~/.vscode-server/data/Machine/settings.json` | `claudeCode.initialPermissionMode: bypassPermissions`, `allowDangerouslySkipPermissions: true` | extension (`ConfigurationTarget.Global`, both the `claudeCode` and `claude-code` sections) |
| `~/.claude/settings.local.json` | `defaultMode: bypassPermissions`, a 15-entry blanket allow list, its own copy of the hook, `__autoAcceptManaged: true` | extension |
| `~/.claude/settings.json` | `PreToolUse` matcher `""` → the hook, `_autoAcceptManaged: true` | extension |
| `~/.claude/hooks/auto-accept-hook.sh` | returns `permissionDecision: allow` for every call, ignoring its input | extension |
| `~/.claude/settings.json` | `permissions.defaultMode: "auto"` | **not the extension** — no marker; hand edit |

**This is why Step 1's fix did not hold.** Step 1 removed `bypassPermissions` from the machine
settings by hand; the extension put it back at the next window start. Hand-editing any of the first
four rows is wasted work while the extension is enabled.

The extension does ship a genuine teardown: its disable path deletes the hook script, filters the
`_autoAcceptManaged` entries out of both settings files, and restores the two VS Code keys. **One
caveat:** the restore reads a snapshot taken at activation time. If it snapshotted
`bypassPermissions` (likely, since the value was already there), it will write `bypassPermissions`
back. So the teardown is not trusted — it is verified.

### 1b. You do this

1. `Ctrl+Shift+P` → **Auto Accept: Disable Auto-Accept**.
2. Extensions sidebar (`Ctrl+Shift+X`) → search `auto accept` → **Auto Accept for Claude Code** →
   gear → **Disable**. Disabling the *feature* is not enough; the extension re-arms on startup.
3. VS Code will offer **Restart Extensions** / **Reload Window**. Accept it.

**This will interrupt this chat session** — an extension-host restart is what disabling costs. That
is why this sub-guide is written and committed first: it is a file on disk and survives. Reopen the
session afterwards and we continue from §1c.

**What you should see:** the Claude Code chat reconnects, and the next tool call I make raises a
**permission dialog** instead of running silently. That dialog is the deliverable of §1.

### 1c. I verify, and hand-clean what survives

I snapshotted all six files to the scratchpad before the teardown, so this is a diff, not a guess.
I check all five rows in the table above and report each as clean or not. Then, whatever the
teardown left:

- Remove `permissions.defaultMode: "auto"` from `~/.claude/settings.json` (row 5, always mine to
  fix). The `notify.js` Notification/Stop/SubagentStop hooks stay — they are yours and unrelated.
- Remove any surviving `_autoAcceptManaged` / `__autoAcceptManaged` block.
- Remove `claudeCode.initialPermissionMode` and `claudeCode.allowDangerouslySkipPermissions` from
  the machine settings if the restore put them back.
- **Chore 2:** delete `~/dev/.claude/settings.local.json`. Stale from Step 0, references a Desktop
  zip and a `~/dev/.git` that no longer exists, and it can only ever grant.
- **Chore 3:** prune two dead entries from `~/dev/factory-lite/.claude/settings.local.json` —
  `Bash(rm -rf /home/drew/dev/scratch-hello *)` (project gone) and `Bash(claude config *)` (granted
  for something that turned out not to be a subcommand).

### 1d. The check that this was real

You start a **new** session in a project folder and type `/hooks`. Expected: **three** `notify.js`
hooks at User scope and **no** `PreToolUse` entry. Before the teardown there were four user-scope
hooks including the auto-accept one.

Then BACKLOG chore 1 gets `Status: done <date>` with the owner named, and LESSONS.md gets the line
that matters for next time: *the machine had a VS Code extension whose job was to rewrite four
separate permission paths on every startup; fixing files by hand was never going to hold, and the
finding is the owner, not the files.*

---

## 2. Name and shape

- **Folder:** `~/dev/coach` (say the word if you want a different name; it appears in the folder
  name and in `CLAUDE.md`'s title, nowhere else).
- **Run command, predicted:** `uv run coach.py …`. A single file with a PEP 723 header if a
  dependency ever appears, and no `pyproject.toml` at pre-alpha. The `pre-alpha` skill says *one
  file or module until it hurts, hardcode before configuring* — a package layout, a `src/`
  directory and a console-script entry point are all things to add when something hurts, and
  nothing hurts yet.

---

## 3. Create the project — I run this

From this window (`~/dev/factory-lite`):

1. `bash ~/dev/factory-lite/scripts/init.sh ~/dev/coach` — copies `CLAUDE.md`, `SPEC.md`,
   `prove.sh` (CRLF-stripped, `chmod +x`), `.claude/settings.json`, then runs the four plugin calls
   (marketplace add + install, for `factory-lite@factory` and
   `superpowers@claude-plugins-official`, all `--scope project`).
2. `git init` in `~/dev/coach` and a first commit of the four template files. **Do this before the
   first session.** The gate hashes git state to decide whether to re-run `prove.sh`; in a non-repo
   it falls back to `nogit-$(date +%s)`, which never matches, so it re-runs on every chat turn.
3. `.gitignore` with the local data file (see §7) so the real log never enters git.

**What you should see:** four `create` lines, then install output from the four `claude plugin`
calls with no `warn:` lines, then the git commit. If any `warn:` appears, stop — the fallback is
Customize → Plugins, and a silently absent gate is Step 6's exact failure.

---

## 4. Gate-armed checkpoint — you type this

Open `~/dev/coach` with **File → New Window → Open Folder**. Bottom-left must read `WSL: Ubuntu`.
Start a **new** session. Type `/hooks` and paste back what you see.

**Pass:** `Stop` carries **two** hooks — the `notify.js` notifier, and `Running ./prove.sh`
attributed to **`Plugin`**.

**Fail:** one `Stop` hook. Then the gate is absent, and Step 6 established that nothing will say
so — no error, no warning, only an absence. Do not start building. We fix the install first.

This is a hard checkpoint because the whole step is a test of a gate, and a project that runs its
entire pre-alpha ungated would look exactly like a success.

> This checkpoint is also the standing evidence for BACKLOG item 4 (*a project cannot tell whether
> the harness loaded*). It is not a decision on that item, and this step does not make one. If the
> check fails here, in a real project, that is new evidence and it gets an evidence line — status
> stays `waiting`.

---

## 5. Session 1 — the spec, and the BACKLOG item 2 observation

BACKLOG item 2 named **this step** as its trigger: if `superpowers:brainstorming` again writes a
correct `SPEC.md` unprompted, `/factory-lite:spec` is deleted in that release, together with item
3's trim of `verify` item 2 — one edit, one bump, not two.

**Decide what counts before it runs, not after.** That is the whole reason this section exists.

### 5a. What you type, exactly

```
/superpowers:brainstorming a nutrition and fitness tracker: log food and get calories and macros,
track body measurements over time, and later recommend workouts from equipment, goal and recovery
```

**Say nothing about `SPEC.md`.** Not "write the spec", not "use the template", not "fill in
SPEC.md". The entire claim under test is that it does that *unprompted*, steered only by the
template file sitting in front of it. One nudge and the observation is void.

### 5b. Let it run to its own end

This is the caveat Step 5 left open and this step must close. In Step 5 the human typed `stop`
immediately after the CLAUDE.md edit, with brainstorming's own steps 7–9 — spec self-review, user
review, then *invoke `writing-plans`* — still ahead of it. So "it never reached `writing-plans`" was
never established, only that it had not reached it yet.

**Do not stop it early.** Answer its questions, let it finish. If it hands off to `writing-plans`
and produces a plan document, that is an observation, not a catastrophe: we record it and delete
the file afterwards, because the `pre-alpha` skill says SPEC.md is the only planning artifact.

### 5c. The scorecard — fill this in after it finishes

| # | Observation | Result |
|---|---|---|
| 1 | `SPEC.md` filled, in the template's own sections, with every heading kept | |
| 2 | `Phase: pre-alpha` retained | |
| 3 | `## Deferred` left empty (it is the hardening backlog, not a wish list yet) | |
| 4 | Requirements are **numbered and checkable** | |
| 5 | No `docs/` directory and no `docs/superpowers/specs/*-design.md` created | |
| 6 | It reached its own end without being stopped | |
| 7 | Did it invoke `writing-plans`? If so, what did that produce? | |
| 8 | *(secondary, BACKLOG item 1)* Were `CLAUDE.md`'s title and one-liner filled, and by which skill? | |

**Item 2 fires** only if 1–6 are all yes and 7 produced no competing design or plan document.
Anything else: record precisely what happened and the item stays `waiting`. A deletion gets the
same evidence bar as an addition.

Row 8 is free evidence for BACKLOG item 1, which still rests on Step 4's single sighting — Step 5
saw the title filled, but by `brainstorming`, not by `spec`. If `spec` is deleted, item 1 dies with
it, so note which skill did it.

### 5d. Optional probe, only after the scorecard is written

Type `/factory-lite:spec` with no argument. In Step 5 it correctly found nothing to do and said so.
Running it now is a cheap second data point on the same overlap. It is a probe, not part of the
observation — write the scorecard first so this cannot colour it.

### 5e. The out-of-scope list must hurt

The step prompt is blunt about this: *if the out-of-scope list contains nothing attractive, it is
decoration and the interview was too polite.*

So here is a list of the things **I predict you will be tempted to build**, written before the
interview so it can be scored against, not after so it can be rationalised. For this idea:

1. **The learning / self-improving layer.** "Grows itself and gets better at coaching." This is the
   most attractive item and it is also v2's failure mode wearing new clothes — a system that
   improves itself is an architecture, and there is no working slice yet for it to improve.
2. **A real food database.** USDA FoodData Central, barcode scanning, a 9,000-row CSV import. It
   feels like table stakes. It is a network dependency and an install step in front of a skeleton.
3. **The full micronutrient panel.** Thirty micros with RDA percentages, before one macro total
   prints correctly.
4. **The workout recommender.** Equipment × goal × recovery is the most fun subsystem in the idea
   and a second whole application.
5. **A UI.** A web app, or charts of body measurements over time.
6. **An LLM in the loop as "the coach."**
7. **Wearable / HRV / sleep integration** to make "recovery" real.
8. **A provider or plugin abstraction** for food data sources — the `pre-alpha` skill's named
   prohibition: no abstraction before three concrete uses exist in this codebase.
9. **A config layer** — units, profiles, goals, targets.
10. **Sync, accounts, multi-device.**

**The test:** when `SPEC.md` comes out of §5a, at least three or four of these should appear under
*Out of scope for pre-alpha*. If the list is made of things you never wanted anyway, the interview
was too polite and it gets run again.

> **Honest note on contamination.** You will have read this list before the interview, so the
> out-of-scope list is not an untouched observation. That is a deliberate trade: item 2 is about
> whether brainstorming produces *the artifact* unprompted, which reading this cannot affect. Do
> not paste this section into the project window.

**My predicted walking skeleton, sealed here to be scored, not to be adopted:** log one food from a
small hardcoded table and print that day's calorie and macro totals. One input, one output, one
command. Measurements, workouts, micros and learning all wait. If brainstorming lands somewhere
else and can say why, brainstorming wins — it has the interview and I do not.

---

## 6. `/clear`, then plan mode for the skeleton only

1. `/clear`. (Superpowers' SessionStart bootstrap re-injects its ~1.3k here. Expected, priced in
   Step 5, not re-measured.)
2. Plan mode, scoped to the walking skeleton in SPEC.md and nothing else. Reject any plan that
   introduces a module boundary, a config layer, a second data source or a class hierarchy — the
   `pre-alpha` skill's Don't list is the review criteria, and it is already loaded because SPEC.md
   says `Phase: pre-alpha`.
3. The first implementation prompt:

```
Implement the walking skeleton in SPEC.md. Write the ./prove.sh check first — replace the TODO
sentinel line with the real check from SPEC.md "Proven by" — then make it pass.
```

**Why the check first, in this exact order.** The sentinel string is what keeps the gate dormant.
Until it is gone, the gate announces `FACTORY gate: dormant.` and enforces nothing, so a session
that writes code first is unsupervised for exactly as long as it takes to get comfortable. Writing
the check first is what makes the rest of the session honest. Do not let it slide to "after it
works".

---

## 7. The two traps specific to this project

Both belong in `CLAUDE.md`'s **Gotchas** section, which exists for things Claude cannot infer by
reading the code.

**1. `prove.sh` must not touch the real log.** This project's whole substance is an accumulating
personal data file. A check that logs a test food into it corrupts your data a little on every run,
and — worse — becomes non-deterministic, because the totals it asserts depend on what you ate. The
check must point the tool at a throwaway database (a `mktemp` path, or a `--db` flag, or an env
var) and clean up after itself.

**2. "Today" is not deterministic.** A check that logs food and asserts today's totals passes at
23:59 and fails at 00:01, and behaves differently in another timezone. The skeleton must accept an
explicit date, and `prove.sh` must pass one. Anything that reads the clock inside the assertion is
a check that will eventually fail for a reason unrelated to the code — and the first instinct when
that happens is to weaken the check, which is precisely the move the gate exists to refuse.

Both are `prove.sh` design constraints, so they are decided in §6 before the code, not discovered
in §8.

---

## 8. Count the gate blocks

README's delete-when for the Stop gate is *`prove.sh` passes first time on >95% of stops*. One
project is not 95% of anything, but it is the first real data and nobody has collected any.

Keep a tally as we go:

```
stops where the gate RAN and passed:   ____
stops where the gate RAN and blocked:  ____
3-strike releases:                     ____   ("still failing after 3 attempts")
```

**Count only stops where the gate ran.** Chat-only turns exit 0 on the state hash without running
`prove.sh` (§0.5); counting those as passes would inflate the number toward 95% with conversation.
The denominator is stops after a tree change.

Also record, in one line each: what the gate blocked *on* (a genuinely incomplete change, or a
flaky check), and whether it was ever right to be annoyed by it. That is the qualitative half, and
for a delete-when decision it matters more than the ratio.

---

## 9. The timebox, enforced

Three sessions. Session 1 is the spec (§5), session 2 is the skeleton (§6), session 3 finishes it.

**If `./prove.sh` is not passing at the end of session three, the slice is too big.** Halve it,
out loud, in `SPEC.md` — move half the walking skeleton into `## Deferred` and say in the session
that we are doing it and why. Do not quietly extend to a fourth session. For this idea the obvious
halving axis is the food table: from several foods with macros to one food with calories only.

I will say this at the end of session three whether or not you ask me to.

---

## 10. Close-out

When the four Done-when conditions hold:

1. `SPEC.md` reflects what was actually built, `## Deferred` carries every product wish that came
   up during the build, and nothing on that list was built.
2. Any harness wish that came up went to `~/dev/factory-lite/BACKLOG.md` in the item format
   (wish / assumption / evidence / delete-when / status) — and was **not** built.
3. `LESSONS.md` gains a Step 7 section: the chore 1 teardown and its owner, the §5c scorecard
   outcome, the §8 tally, and anything that bit us.
4. `BACKLOG.md` item 2 gets its decision or its "still waiting, here is why". If it fires, the
   deletion is a separate act under the release rule — `spec` removed, `verify` item 2 trimmed,
   one bump — and **not** while this project is mid-build, because `main` is production.
5. Tick Step 7 in `START-HERE.md` and commit.

**The harness commits during this step, if any:** this sub-guide and the close-out prose. Both are
prose-only under the release rule — steps 1, 2 and 4, no version bump. They still reach the
project's marketplace clone on push, which is harmless because no plugin component changes. Any
change to `hooks/`, `skills/`, `agents/`, the manifests, `template/` or `scripts/` is a behaviour
change that ships instantly, and gets the full five-part rule or does not get pushed.
