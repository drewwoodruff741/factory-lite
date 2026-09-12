# BACKLOG (harness wishes)

## Release rule (every change to the scaffold, no exceptions)

Written in Step 6, and first executed against Step 6's own two changes. Run all five. Steps 3, 4
and 5 each found a piece that a shortened version of this rule leaves out.

1. `bash scripts/harness-smoke.sh` -> `harness smoke: PASS`
2. **All four validate calls.** `claude plugin validate .` covers only the *marketplace* manifest —
   the repo root holds both and the marketplace wins — so the plugin manifest and the components
   need their own:
   - `claude plugin validate .claude-plugin/plugin.json --strict`
   - `claude plugin validate skills --strict`
   - `claude plugin validate agents --strict`
3. **Bump `version` in BOTH** `.claude-plugin/plugin.json` **and** `.claude-plugin/marketplace.json`
   (`metadata.version`). Bumping one leaves the two disagreeing about what the release is.
4. `git commit`, `git tag vX.Y.Z`, `git push && git push --tags`.
5. Projects update via **Customize -> Plugins**, or `claude plugin update factory-lite@factory`.

**What counts as a change:** anything a project receives as behaviour — plugin components
(`hooks/`, `skills/`, `agents/`, the manifests), `template/`, or `scripts/`. Prose-only edits to
`README.md`, `LESSONS.md`, `BACKLOG.md`, `START-HERE.md` or `docs/` still run steps 1, 2 and 4
before committing, but skip the version bump: bumping for a typo makes the version number stop
meaning anything, and the version number is the only thing every diagnostic reports.

**What the tag actually does: nothing.** Step 6 established by observation that an installing
project gets **`main`**, not the newest tag. `~/.claude/plugins/marketplaces/factory` is a
*shallow, depth-1 clone of the default branch* — `git describe --tags` there fails with "No names
found", because the clone never fetches tags at all. Confirmed four ways: the clone is on `main`;
the extracted plugin copy contains `docs/step-6-prompt.md`, which does not exist at `v3.0.1`; the
install record writes `gitCommitSha` = `main`'s HEAD; and the version in the cache path is a label
copied out of `plugin.json`, not a resolved ref.

So **every push to `main` ships to every project**, with no tag and no release.
**Precision added at Step 9, by observation rather than inference — "immediately" was too strong.**
Pushing v3.3.0 refreshed the marketplace clone at once, and `~/dev/coach`'s install record still
read `installPath: …/cache/factory/factory-lite/3.2.0` afterwards: a project keeps running the
cache directory its install record pins until that project is *updated* (Customize -> Plugins, or
`claude plugin update factory-lite@factory --scope project` **from inside that project**). What a
push controls is what the next install or update receives, which can be minutes or weeks later and
is not something the pusher observes. The discipline is unchanged and the reason for it is slightly
worse: you do not control *when* a project picks up what you pushed, so there is still no such
thing as an unreleased commit on `main` — only one that has not been collected yet.
Steps 3 and 4 above remain worth doing — the version number is what `plugin list`, the cache path
and the install record report, so a stale one makes every diagnostic lie — but understand what they
are: bookkeeping and a human-readable marker, not a mechanism that controls what anyone receives.
The only thing that controls that is what is on `main`. Two consequences to hold onto:
- **There is no such thing as an unreleased commit on `main`.** Don't push work-in-progress to it.
- The cache directory is named for the version (`cache/factory/factory-lite/3.0.1`) while holding
  whatever `main` said at install time, so **content drifts under a fixed version number**. A
  project that installed at 3.0.1 and one that installs later at 3.0.1 can hold different code.

## Review procedure (Step 9) — run after every project ships, and after every model or client release

Written in Step 9 and first executed against Step 9's own nine items. Two passes, and **the second
one is the point**: an improvement loop that only adds is how v2 happened.

### Forward pass — the items in this file

Per item, in order: restate the **assumption** it encodes, check the **evidence** against it, set a
**status**. Rules that make the pass honest rather than a formality:

1. **Every item leaves the pass with a status.** `waiting` is a legitimate result — but only if it
   names the specific observation that would settle it. A `waiting` with no such line is a
   `rejected` that nobody wanted to write.
2. **No evidence → it waits. Evidence → build it here**, in this repo, with the
   assumption/evidence/delete-when convention, under the release rule at the top of this file.
   Never in the project that noticed it.
3. **One project's observation is one observation, and deletions get the same bar as additions.**
   A wish to remove something needs shipped-project evidence exactly as a wish to add something does.
4. **An item that has waited through two projects with no evidence is evidence — about the item.**
   Reject it, say why, and name the trigger that would reopen it. A backlog that only accumulates
   is the same failure mode as a harness that only accumulates, one file over.
5. **Prefer the candidate that is prose, and then the candidate that is nothing.** Most items here
   arrive with a list of candidates; sort them by what they cost the harness, not by what they
   would feel like solving. "Nothing at all, because this is the project's job" is a real candidate
   and has twice been the one with the evidence.
6. **Count before you conclude.** Anything read out of a transcript is a measurement: state the
   unit and the filter, de-duplicate per the record type, and remember that prose mentioning a
   component is not that component firing. The rule is in `LESSONS.md` and it was wrong on its
   first writing, in the direction that mattered.

### Reverse pass — the components themselves

The register is `README.md` §1's table, plus the file headers in `hooks/stop-gate.sh` and
`prove.sh`. Open each one and ask, in order:

1. **Has the delete-when fired?** If yes, delete the component in this release.
2. **Can the delete-when even be evaluated?** If it cannot be counted it must name an experiment,
   and **"never" is not a delete-when** — it makes the component permanent by default, which is the
   thing this table exists to prevent. Rewrite it in this pass rather than next time.
3. **Is it duplicated?** Check *both* the other installed plugin and **the client's own built-ins**.
   The client gains agents, skills and commands between releases; a component that was unique when
   it was written may not be any more. Checking only the other plugin is how `explorer` survived
   two reviews.
4. **Was it used?** Count dispatches and invocations in the transcripts, not impressions. Zero uses
   across two shipped projects is a finding, not a gap in the record — but read it carefully: in
   `~/dev/coach` neither `spec` nor `harden` was ever *typed*, and `harden`'s checklist was followed
   anyway, by reading the file. **Measure the artifact, not the invocation.**
5. **Net rule, and it is the one that binds:** after the pass, FACTORY has the component count it
   had after Step 3 **or fewer**. Adding requires deleting. If nothing can be deleted, nothing gets
   added, and the wish goes back to waiting.

### Closing the pass

Run `./prove.sh`, apply the release rule in full (it is a component change the moment `hooks/`,
`skills/`, `agents/`, the manifests, `template/` or `scripts/` is touched), and write what the pass
*found* into `LESSONS.md` — not what it decided. The decisions live here; the evidence has to be
readable by the next pass, which will have forgotten this one.

## Close-out (2026-09-12) — the plan is finished, and there will be no second project

All ten steps of `START-HERE.md` are done and FACTORY-lite is **complete as a build**. One project
was built on it and hardened. There will not be another. That last fact is not a footnote — it
changes what this file is for, and pretending otherwise would leave a backlog of conditions that can
never fire, which is the exact rot the review procedure above exists to prevent.

**What the decision costs, stated plainly.** Four reopen triggers named "a second project". Three
were retargeted at `~/dev/coach`, which is still live and still the only evidence source; one —
item 2's — is **unreachable and the item is closed for good**. Two shipped instructions can now
never be exercised and are recorded as **known-untested** rather than left looking settled: item 9's
arbitration clause in `pre-alpha` (it applies at spec time, and no spec time remains) and, unless
someone deliberately runs it, the Stop gate's removal experiment.

**The forward pass goes dormant. The reverse pass does not.** The forward pass runs on
shipped-project evidence, and with one project in maintenance the flow of new evidence is a trickle
rather than a source — coach can still bite (items 6 and 8 are live), but nothing new will arrive at
the rate that made a standing procedure worth having. The **reverse pass keeps its full force**, and
its trigger is no longer "after a project" but **"after a model or client release"**. That trigger is
not theoretical: `explorer` was defensible until the day the client shipped `Explore`, and nothing
except the reverse pass would ever have noticed. A harness that stops growing still rots, just more
quietly, and it rots by the world moving underneath it rather than by accretion.

### The close-out procedure

Run this, and nothing else, on a Claude Code or model release that changes the built-in agents,
skills or commands. Twenty minutes.

1. **`claude --version`**, and note what the release changed.
2. **Reverse pass only** — `README.md` §1's table, five rows. For each: has the delete-when fired,
   and *is the component now duplicated by something the client ships*? That second question is the
   one that pays. Delete what has expired.
3. **`./prove.sh`** — it enforces release-rule steps 1-3 by itself.
4. If anything changed: the **full release rule**, because `~/dev/coach` is downstream of every push
   and receives it the next time that project updates its plugins.
5. If nothing changed, write nothing. A pass that finds nothing is a result, and a note saying so is
   the kind of accretion this harness exists to refuse.

**What is explicitly not in the close-out:** running the forward pass on a schedule, adding
components, "improving" the template, or reopening decided items without the trigger they name. The
five rejections above are decisions, not deferrals. If a genuinely new project ever appears, the
full procedure resumes and item 2 is the first thing to re-open.

### Status of the two untested instructions

Neither is a defect and neither should be removed for being untested — they encode findings that
were expensive to obtain, and removing them would discard the finding along with the instruction.
They are marked so that a future reader does not mistake "shipped" for "confirmed".

| Instruction | Where | Why it cannot be tested | If it ever can be |
|---|---|---|---|
| Stop at `brainstorming`'s architectural step 5; SPEC.md is the only planning artifact | `skills/pre-alpha/SKILL.md` | applies at spec time; no spec time remains | a new project's first session |
| ~~The gate's removal experiment (remove the hook, keep the prose)~~ **RUN 2026-09-12** | `hooks/stop-gate.sh` header, `README.md` §1 | ~~needs a project willing to drop its safety net for a phase~~ | done: coach, hardening item 4 — see item 7 |

**The Stop gate is therefore kept by decision, not by evidence, and that is written down on
purpose.** Its delete-when is runnable — on coach, on one hardening item, at the cost of a phase
without the net — and the judgement here is that a harness in maintenance should not degrade its one
working project to study itself. Whoever picks this up later gets the experiment, the reasoning, and
an honest label instead of a condition quietly rotting into permanence.

## Decided in Step 6: the template pins both plugins

`template/.claude/settings.json` enables **both** `factory-lite@factory` and
`superpowers@claude-plugins-official`, and `scripts/init.sh` installs both. Decided 2026-09-12;
recorded here so it is not reopened.

The argument against was real and is recorded rather than discarded: every project pays
Superpowers' ~2.1k whether or not it ever brainstorms, and because that cost is mostly a
SessionStart bootstrap it is re-paid on **every `/clear`** — per context, not per project. The
argument that won: ~0.2% of a 1M window on projects that don't brainstorm is a smaller harm than a
silent capability gap on projects that do, the ritual would be needed in a project's first ten
minutes when nobody is thinking about plugin management, and BACKLOG item 2 (delete `spec` in
favour of `brainstorming`) is only safe if Superpowers is present by default.

**Revisit when:** a project reaches hardening and demonstrably never uses a Superpowers skill
again, or the bootstrap grows past ~5k.


Every "FACTORY should do X" thought from inside a project lands here, never in that
project's harness. Items are reviewed after a project ships its pre-alpha. An item is built
only when it has evidence; until then it waits, and that is fine.

Format per item:
- **Wish:** what the harness should do
- **Assumption it encodes:** what the model can't do on its own that makes this necessary
- **Evidence:** the bug it would have prevented, or the second and third project that needed it
- **Delete when:** the condition under which this component should be removed again
- **Status:** waiting | built in vX.Y.Z | rejected (why)

## Environment chores (not harness components — nothing here enters the plugin)

Noted in Step 4, deliberately deferred. None of these is a FACTORY component; they are machine
settings that change what the harness can be trusted to prove.

1. **Turn off machine-wide auto-accept.** **Owner identified 2026-09-12, before Step 7:
   `tjcg.auto-accept-claude-code` v0.5.0.** It is not three separate mechanisms, as Steps 1, 4 and
   5 each concluded in turn — it is **one VS Code extension writing all four paths on every
   activation** (`onStartupFinished`):
   - `~/.vscode-server/data/Machine/settings.json`: `initialPermissionMode: bypassPermissions` +
     `allowDangerouslySkipPermissions: true`, in **both** the `claudeCode` and `claude-code`
     sections, at `ConfigurationTarget.Global`. **This is why Step 1's hand fix came back.**
   - `~/.claude/settings.local.json`: `defaultMode: bypassPermissions`, a 15-entry blanket allow
     list, its own copy of the hook, `__autoAcceptManaged: true`. (Step 5's "third path".)
   - `~/.claude/settings.json`: `PreToolUse` matcher `""` -> the hook, `_autoAcceptManaged: true`.
   - `~/.claude/hooks/auto-accept-hook.sh`: allows every call unconditionally, ignoring its input.

   **The fix is to disable the extension, and then to verify — not to trust its teardown.** It does
   ship one (delete the hook, filter the managed entries, restore the VS Code keys), but the restore
   reads a snapshot taken at *activation* time, which on this machine was taken with
   `bypassPermissions` already set. A teardown that restores a snapshot of an already-broken state
   can put the bad value straight back.

   **One row is not the extension's and needs a hand edit:** `permissions.defaultMode: "auto"` in
   `~/.claude/settings.json`. It carries no managed marker, so the teardown leaves it, and it is
   **not** inert — `auto` is a real mode at 2.1.269 (the CLI enum is
   `default | acceptEdits | plan | auto | bypassPermissions`, and the binary carries *"Maps to
   `defaultMode: auto`, which repo-level settings cannot grant in Claude Code"*, i.e. user scope can
   grant it and a project cannot override it). Unlike the other four, once removed it stays removed.

   The procedure, the five-row verification and the `/hooks` check that closes it are in
   `docs/subguides/step-7.md` §1. **Deadline: before Step 7**, the first real project — harness work
   is cheap to get wrong, a real project is not. Until it is done, the template's permissions block
   is inert and no permission rule on this machine is testable.
   **Status: done 2026-09-12.** Executed at the top of Step 7. The extension is **uninstalled**,
   not merely disabled — gone from `~/.vscode-server/extensions/` and from the Windows-side
   `.vscode/extensions/` — and its teardown ran: the hook script is deleted, `settings.local.json`
   is back to `{}`, and the `PreToolUse` block and both `_autoAcceptManaged` markers are gone from
   `~/.claude/settings.json`. **The distrust of the teardown was warranted on exactly the predicted
   row:** the machine-settings restore wrote `initialPermissionMode: bypassPermissions` and
   `allowDangerouslySkipPermissions: true` straight back from its activation-time snapshot. Those
   two keys and `permissions.defaultMode: "auto"` were removed by hand; `files.eol` and the three
   `notify.js` hooks were left alone. Pre-edit snapshots of both states (09:07 teardown-time, and
   `*.PRE-1c.json` hand-edit-time) are in `~/backups/factory-lite-chore1-2026-09-12/`.
   **§1d confirmed the same day:** `/hooks` lists exactly three `notify.js` hooks at User scope
   (`Notification`, `Stop`, `SubagentStop`) and **no** `PreToolUse` entry — down from four. The
   half of §1d that a client command cannot show, that a tool call now raises a permission dialog,
   is confirmed by the first session started after the machine-settings edit.

2. **Delete `~/dev/.claude/settings.local.json`.** **Status: done 2026-09-12** (the directory is
   now empty). Stale leftover from Step 0, when `~/dev` was
   briefly its own project: it references a Desktop zip and a `~/dev/.git` that no longer exists.
   Whether a parent directory's local settings reach a child project is unverified (see chore 1 —
   it cannot be tested while auto-accept is on), and the file can only ever *grant*, so deleting
   is strictly safer either way.
3. **Prune `~/dev/factory-lite/.claude/settings.local.json`.** **Status: done 2026-09-12**, allow
   list 35 -> 33. (Chores 2 and 3 were done in the same pass as chore 1 — see
   `docs/subguides/step-7.md` §1c.) Two entries this build wrote and
   nothing needs: `Bash(rm -rf /home/drew/dev/scratch-hello *)`, pointing at a project that no
   longer exists, and `Bash(claude config *)`, granted for a call that turned out not to be a
   subcommand at all.

4. **The template's permissions block has still never been exercised end to end.** Checked at
   Step 9 rather than deferred again — it costs one transcript read, not a project. `~/dev/coach`'s
   session records show **51 turns in `auto` permission mode and 6 in `plan`, and `default` never
   once**, so the six-entry allowlist in `template/.claude/settings.json` was never the thing
   deciding anything. Two findings, and the second is the reassuring one:
   - **Permissions are live on this machine now** — chore 1 worked. `~/dev/coach/.claude/settings.local.json`
     contains exactly **one** granted entry for the whole project, and a grant can only be written
     by an approved dialog (Step 7's lesson). So the machinery records, prompts and persists.
   - **The grant is `Bash(mkdir -p /home/drew/dev/coach/docs/superpowers/specs && echo created)`,
     plus an `additionalDirectories` entry for the same path.** The only permission dialog the
     entire project ever raised was the Superpowers document chain asking for somewhere to put
     itself — which is item 9, arriving from a direction nobody was watching.
   **Status: open, and deliberately not a component.** What is unverified is narrow: whether the
   six allow entries are ever *consulted*, which needs one session run in `default` mode. A match
   leaves no record, so the only way to see it is to run in `default` and notice which commands do
   **not** prompt. Worth doing on the next project's first session; not worth a project of its own,
   and nothing in the harness changes either way.

## Items

**Step 9 pass, 2026-09-12 — all nine items have a status, and the file is closed to `waiting`.**
Built: **1** (spec fills CLAUDE.md's title), **4** (the gate says it passed), **7** (measurement
fixed, delete-when replaced), **9** (pre-alpha outranks Superpowers' planning skills in pre-alpha)
— all four in v3.3.0, and none of them a new component. Rejected, each with a named reopen trigger:
**2** (delete `spec` — the evidence reversed), **3** (trim `verify` — trigger void, and the trade is
bad in kind), **5** (`main` is production — the habit held two projects), **6** (project data dirties
the hash — zero noisy runs in two projects), **8** (guard `SPEC.md` — one project, fixed unaided, and
the cheapest candidate contradicts "exactly one check"). The reverse pass deleted the **`explorer`
agent**: **13 components, one fewer than after Step 3.**

Five of the nine were rejected, four were built, and nothing was left `waiting`. That ratio is the
procedure working, not a purge: rule 4 says an item that waits through two projects without
evidence has told you something, and five of them had.

### 1. `/factory-lite:spec` should fill CLAUDE.md's title and one-liner, not just Run/prove
- **Wish:** the `spec` skill already rewrites the "Run / prove" lines; it should also replace
  `# <project name>` and the `<One sentence: what this is and for whom.>` placeholder.
- **Assumption it encodes:** none about the model — it is a gap in the skill's instruction, which
  names only the Run/prove lines.
- **Evidence:** Step 4, scratch-hello. After a full `/factory-lite:spec` run that produced a
  detailed SPEC.md, `CLAUDE.md` still opened with the literal `# <project name>` and the
  placeholder sentence. Every project would start with an unfilled header that the always-loaded
  file carries into every session.
- **Delete when:** n/a — if built, it is one clause in `skills/spec/SKILL.md`, not a component.
- **Status:** waiting (one project's evidence; a second confirms it is the skill and not a fluke).
  **In tension with item 2** — if `spec` is deleted, this item dies with it. Step 5 produced no
  second sighting: CLAUDE.md's title *was* filled, but by `brainstorming`, not by `spec`.
  **Step 7 carries a free probe for this** as row 8 of the scorecard in `docs/subguides/step-7.md`
  §5c: whether the title and one-liner get filled, and *by which skill*. Costs nothing to observe
  and settles whether this item survives item 2.
  **Step 7 result (2026-09-12): filled, and again by `brainstorming`, not by `spec`.** `~/dev/coach`
  got a real title and a real one-liner; `/factory-lite:spec` was never invoked in that session at
  all. So this is the **second** sighting for `brainstorming` and still the **first and only** for
  `spec` — the evidence for the wish as written (a gap in *`spec`'s* instruction) has not moved
  since Step 4. What did move is this item's survival odds: item 2 did not fire, so `spec` lives on
  for now, and with it this item.

- **Step 9 decision: built in v3.3.0. Item closed.** `skills/spec/SKILL.md` now replaces
  `# <project name>` and the `<One sentence…>` placeholder as well as the Run/prove lines, and says
  why: CLAUDE.md is loaded into every session, so a placeholder left there is carried for the life
  of the project. Built on **one** sighting deliberately, and the reasoning is worth keeping because
  it is the exception rather than a loosening of the rule: the evidence bar in this file is for
  *components*, and this is one clause inside a skill that already exists — no new component, no
  per-session cost, nothing to delete later. The gap was also confirmed by **reading the
  instruction**, not only by observing the output: the skill named the Run/prove lines and nothing
  else, which is a defect visible in the source. Waiting for a second sighting would have meant
  waiting for someone to type `/factory-lite:spec` again, and two projects did not.

### 2. Delete `/factory-lite:spec` — Superpowers' brainstorming does the job better
- **Wish:** remove `skills/spec/SKILL.md` from the plugin and let `superpowers:brainstorming` write
  `SPEC.md`, which it already does unprompted when the template file is present.
- **Assumption it encodes:** the current `spec` skill assumes phase changes need FACTORY's own
  ritual. Step 5 suggests the ritual is the *artifact* (`SPEC.md` + `Phase:`), not the interview,
  and the artifact survives deletion because it lives in `template/`.
- **Evidence:** Step 5, scratch-super. `/superpowers:brainstorming` ran three rounds of
  `AskUserQuestion` with real scope pushback and wrote a SPEC.md with 9 checkable requirements, a
  9-item out-of-scope list, and a byte-for-byte fixture diff as "Proven by" — better than anything
  `spec` has produced. `/factory-lite:spec` then ran, found nothing to do, and said so. It also
  never wrote its own competing `docs/superpowers/specs/` design doc. **Caveat that Step 7 must
  close:** it was stopped by the human right after the CLAUDE.md edit, with its own steps 7-9
  (including `invoke writing-plans`) still ahead of it — so we do **not** yet know whether it
  would have handed off to a competing plan document. Let it run to its own end before acting.
- **Evidence (Step 7, 2026-09-12): the caveat did NOT resolve against this item, and the sentence
  above about the competing design doc is withdrawn as unverified.** In `~/dev/coach` brainstorming
  again wrote a correct `SPEC.md` unprompted — 10 numbered requirements, an out-of-scope list that
  fences the workout recommender, `CLAUDE.md`'s title and one-liner filled — **and also** wrote a
  303-line `docs/superpowers/specs/2026-09-12-nutrition-fitness-tracker-design.md`. That is **not**
  a reversal of Step 5, because the two runs were on different paths and the skill *mandates* the
  doc on one of them. `brainstorming/SKILL.md` has a **Bounded** path (5 steps, step 5 says "no plan
  document" in as many words) and an **Architectural** path whose **step 6 is "Write design doc —
  save to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` and commit"**. The coach run
  declared `Path: architectural` in its first message. The Step 5 run **never declared a path at
  all** — its only path statement was that it could not yet classify the work. So coach wrote the
  doc *because its path told it to*, and Step 5 not writing one is evidence of restraint only if
  Step 5 was also Architectural, which is unestablished.
  **So `BACKLOG.md`'s own "steps 7-9 still ahead of it" is a reconstruction, not an observation:**
  on the Architectural path step 6 precedes 7-9, so a run stopped there would have left a design
  doc, and none exists. On the Bounded path there are no steps 7-9 to be ahead of. It can no longer
  be settled — `~/dev/scratch-super` has been deleted and the transcript is the entire record.
  Measured like-for-like the runs differ on `superpowers/specs` occurrences (**2 vs 37**) and on the
  path declaration; `writing-plans` is **10 vs 10** and discriminates nothing.
- **Defect in the pre-registered bar, recorded rather than re-scored.** `docs/subguides/step-7.md`
  §5c row 5 ("no `docs/` directory and no `*-design.md` created") can only be *failed* by an
  Architectural run and only *passed* by a Bounded one, so it scores **path selection**, not the
  behaviour this item is about. The scorecard never named a path. The honest record is that the bar
  was not met **and** two of its criteria were poorly specified. A future scorecard fixes the path
  first, or scores the design doc only when the path did not call for one.
- **Second defective criterion, found in the v3.2.0 audit: row 3 was also wrong.** Row 3 failed
  `brainstorming` for not leaving `## Deferred` empty. v3.2.0 settled that **pre-alpha means the
  walking skeleton**, so scope beyond the skeleton belongs in `## Deferred` **at spec time** — which
  is exactly what brainstorming did. `skills/spec/SKILL.md`'s "leave `## Deferred` empty" was the
  instruction that made row 3 look like a rule, and it has been removed. Row 3 is withdrawn.
  **Net effect on this item: it now fails on the document chain alone** — rows 6 and 7, the 1911
  lines of design-plus-plan referencing themselves rather than `SPEC.md`. That is the genuine,
  path-independent finding, and a cleaner verdict than the one first recorded. Two of the three
  original failures turned out to be defects in the bar, which is itself the lesson: *a
  pre-registered criterion is only as good as the model it encodes, and this one encoded a phase
  definition the harness had not yet settled.*
- **Row 7 closed, 2026-09-12: it did hand off, and the handoff is the strongest argument against
  this item.** Allowed to reach its own end, brainstorming invoked `writing-plans`, which wrote
  `docs/superpowers/plans/2026-09-12-coach-stage-1-walking-skeleton.md` — **1608 lines, 9 TDD tasks,
  57 tests**. Scored against four criteria fixed before it ran: it scoped cleanly to stage 1 and
  stopped without writing code (both good), it listed its own omissions explicitly (good practice),
  but it **introduced a load-bearing decision `SPEC.md` did not carry** — display precision, which
  `prove.sh` asserts on — and **its header points at the design doc as "Spec:", not at `SPEC.md`**.
  Totals: **1911 lines of planning artifact beside a 71-line `SPEC.md`**, in a chain that references
  itself rather than the file the gate, the skills and the `reviewer` agent all read.
- **Status (Step 7): still waiting, and now with a live counter-argument rather than a neutral
  one.** Rows 1, 2, 4 and 8 passed; row 3 failed (`## Deferred` pre-populated with 10 items —
  path-independent, so it stands); rows 5, 6 and 7 are accounted for above. The item's own rule is
  that deletions get the same evidence bar as additions, and this observation moved the evidence
  *against* deleting `spec`: brainstorming writes an excellent `SPEC.md` **and** brings a parallel
  document chain that `pre-alpha`'s Don't list forbids. `spec` writes the artifact and stops.
  **What would settle it:** a third project where brainstorming is confined to the Bounded path (5
  steps, "no plan document") and still produces a correct `SPEC.md`. **Step 9: that experiment
  cannot be run** — a new project is Architectural by the skill's own rule, so the Bounded path is
  unreachable here. Read "stopped at architectural step 5" wherever this paragraph says Bounded. If that holds, the wish is not
  "delete `spec`" but "invoke brainstorming in a way that cannot start a document chain", which is a
  different and cheaper change. The finding nobody predicted stands behind all of it: **two
  identical starting conditions — fresh factory-lite template, no code, placeholder `SPEC.md` — were
  classified onto different paths.**
  **Withdrawn at Step 9 — see item 9.** Reading `brainstorming/SKILL.md` rather than the record of
  it: a new project is Architectural *by the skill's own rule*, stated three times including in its
  Red Flags table. The Step 7 run classified correctly; the Step 5 run never declared a path at all,
  which is a skipped step and not a second classification. The runs differ in whether the rule was
  applied, not in what it says — and that makes this collision **fixed and predictable**, which is
  better news for item 9 than the version it replaces.
- **Delete when:** n/a — this *is* a deletion. **Trigger to act:** if brainstorming again writes a
  correct `SPEC.md` unprompted in Step 7's first real project, delete `spec` in that release. One
  observation is not enough; deletions get the same evidence bar as additions.
- **Status:** waiting (one project's evidence). Counter-argument to weigh at Step 7: `spec` costs
  ~50 tok always-on, is command-only, and is the only guarantee the artifact gets written in a
  project where Superpowers is not installed.
- **The bar is fixed in advance, before the observation runs** — `docs/subguides/step-7.md` §5c is
  an eight-row scorecard written before Step 7 executes, precisely so the result cannot be scored
  to taste afterwards. Two conditions in it matter most: brainstorming is invoked with **no
  mention of `SPEC.md`** (the claim is that it writes it unprompted, so one nudge voids the run),
  and it is **allowed to reach its own end** rather than being stopped after the CLAUDE.md edit as
  in Step 5 — that is the open caveat this step exists to close. If it fires, the deletion is a
  separate act under the release rule, *after* the project's pre-alpha ships, because `main` is
  production and this project is downstream of it.

- **Step 9 decision: rejected.** Two projects, and the evidence moved *against* the deletion rather
  than failing to arrive. `brainstorming` writes an excellent `SPEC.md` — twice now — and brings a
  parallel document chain that `pre-alpha`'s Don't list forbids; `spec` writes the artifact and
  stops. Deleting the one that stops, in favour of the one that has to be restrained, is the wrong
  direction. The cost of keeping it is ~50 tokens, command-only, `disable-model-invocation: true`.
- **A usage count from Step 9's reverse pass, because it cuts both ways and the second half is the
  one that decides it.** Across every FACTORY-era transcript, `/factory-lite:spec` was typed **3
  times in scratch folders and 0 times in the one real project**. Read alone that is an argument for
  deletion. But `/factory-lite:harden` was typed **0 times in that project too** — and its checklist
  was followed anyway, step by step, because the session was pointed at `skills/harden/SKILL.md` and
  read it. **The skill file is doing work as a document whether or not the command is invoked, and
  deleting the command deletes the document.** That is now rule 4 of the reverse pass.
- **What would reopen it** is no longer "a third project where brainstorming writes a correct
  SPEC.md" — there are two of those. It is a project where brainstorming is **stopped at
  architectural step 5** (see item 9, corrected: the Bounded path is unreachable for a new project
  by brainstorming's own rule) and still produces a correct `SPEC.md` with no document chain.
  **Close-out, 2026-09-12: that trigger is now unreachable and the item is closed for good.** There
  will be no second project, and `~/dev/coach` is long past spec time — nothing will run
  `brainstorming` from a fresh scaffold again. `spec` stays, permanently, on the evidence as it
  stands: it writes the artifact and stops, which is more than the alternative does. The clause
  item 9 shipped to make this comparison observable will therefore never be observed — recorded as
  a **known-untested instruction** rather than left looking settled.

### 3. Trim `verify` item 2 — Superpowers says it better
- **Wish:** cut or shorten item 2 of `skills/verify/SKILL.md` ("show evidence, don't assert").
- **Assumption it encodes:** that Claude will assert success without running the command. Still
  true — but no longer FACTORY's job to say.
- **Evidence:** Step 5. `superpowers:verification-before-completion` covers exactly this across an
  Iron Law, a gate function, and two rationalization tables. FACTORY's one sentence is strictly
  dominated. Items 1, 3 and 4 have no Superpowers equivalent and stay.
- **Delete when:** n/a — a trim, not a component.
- **Status:** waiting (do it in the same release as item 2, if item 2's trigger fires — one edit to
  the skill, one bump, not two)

- **Step 9 decision: rejected.** Its stated trigger — "do it in the same release as item 2, if item
  2's trigger fires" — is void, because item 2 is rejected. On its own merits it has waited through
  two projects and neither produced a single instance of the duplication costing anything, which
  procedure rule 4 treats as evidence about the item. And the trade is bad in kind rather than in
  size: `verify` item 2 is the human-readable half of the only claim FACTORY makes for itself — what
  "done" means — and trimming ~25 tokens makes that claim depend on a separately-pinned plugin being
  present to state it. Subtraction is the point of this pass; subtracting your own load-bearing
  sentence in favour of another plugin's copy of it is not the same act. **Reopen when:** Superpowers
  is ever unpinned from the template, at which point the question inverts and this line is the only
  place the rule exists.

### 4. A project cannot tell whether the harness actually loaded
- **Wish:** something should make a missing Stop gate *loud*. Candidates, none chosen: `init.sh`
  verifying the install record after it writes it; `prove.sh` refusing to report PASS if it wasn't
  invoked by the gate; a line in `CLAUDE.md` telling the session to check `/hooks` on day one.
- **Assumption it encodes:** that a harness which silently isn't there is worse than no harness,
  because the project proceeds believing it is protected.
- **Evidence:** Step 6. A fresh project with the pin in `settings.json` got the marketplace
  registered, the repo cloned, the plugin cached and an in-use marker written — and no install
  record. From inside the session the only symptom was an **absence**: four hooks in `/hooks`
  instead of five. Nothing errored, nothing warned, and a second fresh session behaved identically.
  A real project could have run its entire pre-alpha with no proof gate and never known. `init.sh`
  now installs loudly, which closes *this* instance, but not the class: any future breakage of the
  load path fails the same silent way.
- **Delete when:** n/a until something is chosen.
- **Status:** waiting. **Noted in Step 6, deliberately not decided there** — Step 6's guardrail was
  to add no hook, agent or rule, and every candidate above is a change to the harness's behaviour
  that wants a real project's evidence first. Revisit after Step 7, which is the first time the
  answer matters to something other than a scratch folder.
  **Still undecided going into Step 7, deliberately.** The step's guardrail forbids adding a hook,
  agent or rule, and every candidate above is one. What Step 7 does instead is *collect*:
  `docs/subguides/step-7.md` §4 makes "`/hooks` shows `Stop` carrying two hooks" a hard checkpoint
  before any code is written, and makes it a human-typed check rather than an inferred one. If it
  fails there — in a real project, not a scratch folder — that is the second instance this item
  needs, and it gets an evidence line, not a decision.
  **Step 7 evidence line (2026-09-12), status deliberately unchanged.** §4's checkpoint *passed* —
  `/hooks` showed `Stop` carrying both hooks — so this item gets no instance from there. It got one
  from somewhere nobody was looking: **the gate then sat armed through the entire build without
  firing once**, because the skeleton was written in a single continuous run and the gate only runs
  at a stop. For the whole of stage 1 a correctly-installed, correctly-armed gate and a missing one
  would have produced **identical** evidence from inside the project — no message, no block, no
  trace. It took a deliberately induced defect to show the gate was live at all. That widens this
  item: the wish was "make a *missing* gate loud", and the real requirement is closer to "a project
  should be able to tell the gate is **working**", which a missing install and a never-triggered
  install both fail. Still no candidate chosen, still `waiting`.

- **Step 9 decision: built in v3.3.0, and the item is closed — both halves, by two different
  mechanisms.** The **missing-install** half was closed in Step 6: `init.sh` installs loudly and
  fails loudly, which is why Step 7's `/hooks` checkpoint passed. The **is-it-working** half — the
  widening above, and the harder one, since a never-triggered install and a missing one were
  indistinguishable — is closed by the same one line that fixes item 7's measurement: the gate now
  prints `FACTORY gate: ./prove.sh passed.` after a real run and stays **silent** on the
  unchanged-tree skip. So on the first stop after any code change, silence now means *absent*, where
  before it meant either. Both halves of that behaviour are asserted in `scripts/harness-smoke.sh`,
  each watched failing on a broken gate before being trusted.
- **Residual, recorded rather than papered over:** a chat-only turn is still silent, so the signal
  is diagnostic only after work. That is deliberate — a gate that announces itself on every turn is
  one that gets tuned out — and it means "I saw nothing" is still ambiguous if nothing was built.
- **Rejected from the candidate list:** `prove.sh` refusing to report PASS unless the gate invoked
  it. It couples a project's definition of done to the harness being present, which is backwards:
  `prove.sh` has to work for a human typing it, in a checkout with no plugin installed.

### 5. `main` is production, and nothing marks the difference
- **Wish:** some separation between "pushed" and "released" — a `release` branch, a pinned `ref` in
  the marketplace source, or a second marketplace entry. Explicitly **not** chosen yet.
- **Assumption it encodes:** that the harness will eventually need a place to land work in progress
  that isn't instantly live in every project.
- **Evidence:** Step 6 established that an installing project gets `main` via a shallow depth-1
  clone that never fetches tags. Every push ships, immediately, to every project. Today that is
  harmless — the only consumers are scratch folders. From Step 7 onward there is a real project
  downstream of every commit, and the release rule's `git tag` step protects nothing.
- **Delete when:** n/a until something is chosen.
- **Status:** waiting. **Noted in Step 6, deliberately not decided there** — the step's guardrail
  was "don't set up stable/latest channels yet; one tag is enough until a second project exists",
  and that reasoning still holds. The interim discipline is a habit, not a mechanism: don't push
  work in progress to `main`. Recorded so that when the habit fails, the failure is expected rather
  than surprising.
  **As of Step 7 the hypothetical is real: there is now a project downstream of every commit.**
  Still not decided, and deliberately so — the reasoning above is unchanged, and one project is
  still not a second project. What changes is the cost of the habit failing, so Step 7's close-out
  rule is explicit: prose-only commits (`README`, `LESSONS`, `BACKLOG`, `START-HERE`, `docs/`)
  reach the marketplace clone but change no plugin component and are safe; anything under
  `hooks/`, `skills/`, `agents/`, the manifests, `template/` or `scripts/` ships as behaviour the
  moment it is pushed, and gets the full five-part rule or does not get pushed at all.

- **Step 9 decision: rejected, with a named reopen trigger.** Two projects, and the habit held both
  times. The part of the release rule that used to depend on memory — and was broken twice in one
  session — is now *enforced*: `./prove.sh` runs the smoke test, the four validate calls and the
  manifest-agreement check, and the Stop gate runs `./prove.sh`. What is left to the habit is a
  single decision, "don't push work in progress to `main`", and none of the candidates (release
  branch, pinned `ref`, second marketplace entry) removes that decision — they relocate it, and
  charge a permanent piece of machinery for the move. One project downstream is not enough to buy
  it. **Reopen when:** a work-in-progress push actually reaches `~/dev/coach`. The other half —
  "or a **second** project exists downstream of `main`" — is **struck at close-out, 2026-09-12:
  there will be no second project**, so the coordination problem this item was saving itself for
  cannot arrive. One consumer, one habit, and the mechanical half of the release rule is enforced by
  `./prove.sh` either way.

### 6. A project's own data files make the gate re-run on every turn
- **Wish:** something should stop a project's runtime data from being counted as a source change.
  Candidates, none chosen and none justified yet: `init.sh` writing a starter `.gitignore`; the
  template shipping one; a line in the template `CLAUDE.md` saying to ignore data paths on day one;
  or nothing at all, because this is the project's job and not the harness's.
- **Assumption it encodes:** that a gate which fires on every turn gets ignored, and an ignored gate
  is worse than an absent one because it still costs the time.
- **Evidence:** **none observed — this is a prediction, recorded so it can be checked rather than
  rediscovered.** The mechanism is read from `hooks/stop-gate.sh`, not guessed: the tree state it
  hashes is HEAD + staged/unstaged diff + the contents of untracked **non-ignored** files. So any
  project that writes its own data into its working directory — a log, a SQLite file, a cache —
  changes that hash on every run and never hits the "nothing changed since the last PASS" skip. Step
  7's project (a food and measurement log) is the first FACTORY project that will actually do this;
  Steps 4, 5 and 6 used scratch projects that wrote nothing. `docs/subguides/step-7.md` §3 has that
  project gitignore its data file on day one, which means **Step 7 will most likely produce no
  evidence for this item either way** — the right trade, since the alternative is letting a real
  project run noisily to prove a point.
- **Step 8 evidence line (2026-09-12), status deliberately unchanged — and it widens the surface
  rather than supporting the wish.** The prediction named *the project's own data file* as the
  trigger. Hardening `~/dev/coach` showed the trigger is broader than that: adding `pytest` and
  running `ruff` wrote `.pytest_cache/` and `.ruff_cache/` into the working directory, both
  untracked and non-ignored, and both rewritten by **every `prove.sh` run** — that is, by the gate
  itself, so the gate would have dirtied the very hash it uses to decide whether anything changed.
  Dev tooling, not project data, and it arrives the moment a project goes strict. **Still zero
  noisy runs observed:** they were added to `.gitignore` in the same commit that introduced pytest,
  before any gate run saw them. Which is the point. The fix was two lines of `.gitignore` written
  by the project, in the project, at the moment the project created the problem — with no harness
  involvement available, wanted, or missed. Two projects have now had this exact shape and neither
  needed the harness to solve it, so the "or nothing at all, because this is the project's job"
  candidate has gained the only evidence either way.
- **Delete when:** n/a until something is chosen.
- **Status:** waiting, on **zero** observations. Explicitly **not** to be built on the strength of
  the prediction above — that is the accretion failure mode LESSONS records for v2, where every
  addition sounded good on paper. It needs a project that actually got bitten.

- **Step 9 decision: rejected.** Two projects have now had this exact shape — coach's own data
  file, then `.pytest_cache/` and `.ruff_cache/` arriving with `pytest` and `ruff` at hardening —
  and both were solved inside the project by two lines of `.gitignore`, with no harness involvement
  available, wanted or missed. **Zero noisy gate runs have been observed in two projects**, which is
  precisely the observation the item's own status line said it required. Per procedure rule 5, the
  candidate holding the only evidence either way is "nothing at all, because this is the project's
  job", and that is now the decision rather than the default. **Reopen when:** `~/dev/coach` is
  actually bitten — the gate re-running on every turn because of files it did not think to ignore,
  observed, not predicted. **This trigger survives close-out (2026-09-12)**: coach is mid-backlog,
  and each hardening item can introduce tooling that writes into the working directory, which is
  exactly how `.pytest_cache/` and `.ruff_cache/` arrived.

### 7. The Stop gate's own delete-when condition cannot be measured

- **Wish:** the gate should leave enough of a trace that "`prove.sh` passes first time on >95% of
  the stops where the gate actually ran" is countable afterwards. Candidates, **none chosen**: a
  one-line `systemMessage` on PASS; an append-only counter next to the existing `$marker.count`; or
  nothing at all, on the grounds that a gate which announces its successes is a gate that gets
  tuned out, and a tally kept by hand during the three sessions is cheap enough.
- **Assumption it encodes:** that a component carrying a quantitative retirement condition should
  be able to produce the quantity, or the condition is decoration and the component is permanent by
  default.
- **Evidence:** Step 7, `~/dev/coach`, found while trying to fill in §8's tally. Three separate
  measurement failures, all in one sitting:
  1. **A pass is silent.** `hooks/stop-gate.sh:71-74` writes the marker, clears the count file and
     exits 0 with no output. The unchanged-tree skip at `:59-61` is *also* a silent exit 0. So the
     two cases §8 must tell apart — *ran and passed* versus *skipped, nothing changed* — are
     indistinguishable from outside. Only blocks (exit 2, stderr), `dormant`, and the 3-strike
     release emit anything at all.
  2. **The two outcomes record in different shapes, and the obvious rule catches only one.** A
     `dormant`/3-strike firing prints `systemMessage` on stdout, exits 0, and lands as
     `type == "attachment"` **written twice** (`.stdout` and `.content`, same text, same timestamp
     to the millisecond) — a naive count of the coach run's dormant announcements gave 8 against a
     real 4. A **block** writes stderr and exits 2, and lands as `type == "system"` **written
     once**. The first counting rule written for this filtered to `attachment.stdout` and therefore
     reported the project's only real block as **zero**.
  3. **Prose counts as firings.** In the factory-lite transcripts the gate is *discussed*, and
     those mentions match the same strings. One session matched the block string 13 times across 9
     user/assistant records with **zero** actual firings. This matters most precisely where the
     sessions 2-3 tally will be read from.
  Errors 1 and 2 push the measured ratio in **opposite** directions, and neither is visible unless
  you go looking. The counting rule that survives all three is in `LESSONS.md`.
  **A fourth failure, found at close-out, is worse than the three above because it needs no
  mistake.** Step 7's whole walking skeleton was built in one continuous agentic run, and the gate
  only runs at a *stop*. It never fired. The tally reads **0 blocks out of ~1 stop** — a flawless
  score that argues for retirement, produced by a gate that was never consulted. So the delete-when
  does not merely lack a numerator: **its denominator collapses as the model works in longer
  turns**, and the metric drifts toward "delete" precisely as sessions get more autonomous. Any
  replacement has to count something that does not shrink with turn length.
  **A fifth, found in v3.2.0: the defect obstructed the verification of its own fix.** After the
  harness was given its own `prove.sh` and the plugin enabled, "is this gate actually wired?" could
  not be answered from the transcript — **no gate record of any kind existed**, which is equally
  consistent with "wired and passing silently" and "not wired at all". Settling it required a human
  to type `/hooks`. The cost of leaving this item open is therefore concrete and recurring rather
  than hypothetical: **every future check of the gate degrades into asking a person.** This is the
  strongest argument yet for the cheapest candidate on the list — a one-line `systemMessage` on
  PASS — and it should be weighed first at Step 9.
  **Step 8 evidence line (2026-09-12), status deliberately unchanged. The step's job was to supply
  the denominator Step 7 could not; it supplied one, and in doing so falsified the item's own
  proposed workaround.**

  The tally, kept live across the session rather than reconstructed, hardening `~/dev/coach`
  through three backlog items:

  ```
  stops where the gate did NOT block:  7
  stops where the gate RAN and blocked: 0
  3-strike releases:                    0
  ```

  (Counted live at each stop, through and including the session's close-out message. Step 7's
  comparable figure was ~1 stop, so the denominator did grow — it grew because hardening ships one
  reviewed item at a time, which is what Step 8 predicted, not because anything was done to the
  gate.)

  **Note the first row is not the row Step 8 asked for.** It asked for "stops where the gate RAN
  and passed", and that number cannot be produced *even by counting live*, because a pass and an
  unchanged-tree skip are both a silent exit 0 — finding 1 above. Step 8 assumed the problem was
  reconstruction after the fact ("a pass is silent and cannot be reconstructed afterwards"), and
  the item's own cheapest candidate rests on the same assumption: "a tally kept by hand during the
  three sessions is cheap enough". **It is not.** Counting live gets you "did not block", which is
  the complement of the blocks you can already count from the transcript. The hand-tally candidate
  should be struck at Step 9: it does not produce the quantity.

  **The qualitative half, which matters more here than the ratio.** The gate blocked on nothing,
  so it was never once annoying. It was also never once useful, and the session says precisely why:
  during the six working stops (the seventh was the close-out) the `reviewer` agent found a P0
  (`food_id=10**30` returning a 500 with a
  traceback — the exact defect the shipped item existed to prevent), a P1 (`servings=1e308`
  accepted, making a day's totals read `inf` permanently), three tests that could not fail under
  any circumstances, and three whole sections of the project's SPEC.md deleted by a scripted edit,
  `## Constraints` among them. **`./prove.sh` was green throughout all of it.**

  That is not an argument that the gate is worthless, and Step 9 should resist reading it as one.
  It is an argument about *what kind* of thing it catches: **a gate that runs `prove.sh` protects
  against regression, not against introduction.** At the moment a defect is written, `prove.sh` by
  definition does not yet check for it — the check that would catch it is part of the same unwritten
  work. Every defect above was found by review and then *converted* into a check the gate now
  enforces. So the honest framing for the delete-when is not "does it pass >95%" but "does anything
  else run `prove.sh` if it does not".

  **And that last question exposes the ratio's deepest problem, worse than the denominator
  collapse.** The 0 blocks are not evidence the gate is redundant, because the session ran
  `./prove.sh` manually before every single stop — following the `verify` skill, which the gate's
  existence is partly why anyone follows. A gate that never fires *because the agent pre-empts it*
  and a gate that never fires *because it is not wired* produce identical tallies. Step 7 could not
  tell those apart without a human typing `/hooks` (finding 5); Step 8 could not either, for the
  same reason, and asked. **The metric cannot separate deterrence from absence, which is the one
  distinction retiring the gate actually turns on.**
  **The experiment was run, 2026-09-12, and it is the first of these five delete-whens ever to be
  executed.** Drew reversed the close-out judgement and coach built hardening item 4 — the
  `/measure` chart — with the hook removed and the prose kept.

  Setup, because the mechanism turned out to be the first finding: **no factory-lite document says
  how to remove the hook**, and two of the three obvious ways are invalid against this item's own
  requirement that the prose stay. Uninstalling the plugin also removes the `verify` skill.
  A project-scope `enabledPlugins` entry blocks `claude plugin uninstall` outright. The client's
  `/hooks` UI cannot disable a plugin-supplied hook either — it says to edit settings directly, and
  the settings schema has no key that does it (`disableAllHooks` would also kill the user's own
  notifier hook). **Emptying the `Stop` array in the plugin's own `hooks/hooks.json` at the
  project's pinned install path is the only mechanism that removes the hook alone.** Control
  confirmed by `/reload-plugins` reporting "1 hook", down from 2. *A delete-when that names an
  experiment has to name how to run it, or the next person re-derives all of that first.*

  Result: **`./prove.sh` ran before every stop.** Two stops with the hook removed, both preceded by
  a full strict run; a third at handoff, before the reload, so its gate state is ambiguous and it is
  not counted. The prose alone kept the check running.

  **What that is worth, which is less than it looks.** Two stops is not a sample — the same
  denominator collapse this item already records, since one hardening item built in long turns
  produces almost no stops. And the observer effect is not incidental here: the session set the
  experiment up and knew it was running. So this is one clean data point for "the prose is
  sufficient", not a demonstration of it. **The gate stays**, now on one run's worth of evidence
  instead of none.

  **The observation worth more than the tally.** The only real defect in item 4 was caught by
  driving the app over HTTP against a month of seeded readings — a weekly rate rendering
  "-0.0 in per week", true and useless, because every test written for it used weights where one
  decimal place happens to be enough. Meanwhile the `reviewer` agent found two tests that could not
  fail, one of them on the smoothing that *is* item 4: the trend polyline could be swapped for the
  raw readings coordinate-for-coordinate and all 163 tests stayed green. **Neither is reachable by
  a gate that runs `prove.sh`, however reliably it fires.** That is Step 8's finding with a second
  project behind it — a `prove.sh` gate protects against regression, not against introduction — and
  it reframes the question for good: not how often the gate passes, but whether anything else runs
  `prove.sh`. On this run, something did.

- **Delete when:** n/a until something is chosen.
- **Status:** waiting, on two projects' observations, and deliberately **not** decided in Step 7 —
  the step's guardrail forbids changing the harness mid-project, and every candidate above is a
  change to gate behaviour. Note the circularity this item sits on: the gate's delete-when is the
  main reason to collect the number, so a gate that cannot report it is a gate that cannot be
  retired on evidence. That is an argument for fixing the measurement, **not** an argument that the
  gate has earned permanence.

- **Step 9 decision, in three parts. Item closed.**
  1. **The hand-tally candidate is struck**, exactly as Step 8's evidence requires. It rested on the
     assumption that the problem was reconstruction after the fact; counting live was tried and
     produced "did not block", which is the complement of the number you can already read from the
     transcript. A candidate whose assumption has been tested and falsified does not stay on a list.
  2. **The numeric delete-when is retired and replaced with a removal experiment.** ">95% of stops
     where the gate ran" fails three separate ways, and only the first is fixable: pass and skip
     were both a silent exit 0 (fixed, part 3); the denominator is *stops*, and it collapses as
     sessions run in longer turns, so the ratio drifts toward "delete" precisely as the model gets
     more autonomous; and a gate that never fires because the session pre-empts it produces exactly
     the tally of one that was never installed. The third is fatal, and no amount of instrumentation
     touches it — **deterrence and absence are indistinguishable from the outside**. The replacement,
     now in `README.md` §1 and the file header: *delete when a project runs to completion with the
     gate removed and `prove.sh` still runs before every stop.* Taking it away is the only test that
     separates the two cases, so that is the test.
  3. **The `systemMessage` on PASS is built in v3.3.0** — but justified by **finding 5**, not by the
     ratio, which is being abandoned. The recurring, concrete cost was that "is the gate actually
     wired?" could not be answered from any transcript and needed a human to type `/hooks`, three
     times across two projects and one audit. The gate now says `FACTORY gate: ./prove.sh passed.`
     after a real run and stays silent on the unchanged-tree skip; `scripts/harness-smoke.sh`
     asserts both, and both assertions were watched failing on a deliberately broken gate first.
- **Refined in v3.3.1, hours after shipping, by the project it shipped to.** `~/dev/coach` read the
  new delete-when and reported that it could not run it: that session pre-ran `./prove.sh` before
  every stop because **CLAUDE.md's verify rule says to**, so removing the gate would show the check
  still running and prove only that the rule was doing the work. Checking the claim rather than
  taking it: `template/CLAUDE.md:19` ships exactly that line to **every** FACTORY project, so this
  is structural, not a quirk of coach — the experiment as written was nearly unrunnable anywhere in
  the harness's own installed base.
  **The fix is to stage it rather than to design around it, because the confounder is the question.**
  Remove the **hook**, keep the `verify` skill and the CLAUDE.md rule. If the check still runs before
  every stop, the hook is the redundant component and the ~50-token prose rule is the cheaper one
  that survives — which is a genuine result, and the one Step 8's evidence has been pointing at all
  along ("if the harness is ever trimmed, trim toward keeping the cheap review and re-examining the
  always-on hook"). The guard rail on it: the experiment compares **two FACTORY components against
  each other** and never tests the model bare, so "neither is needed" is a conclusion it cannot
  support.
  Worth noting what just happened procedurally: the first thing to test the new delete-when was the
  downstream project, within a day, and it found a defect the release review did not. That is the
  maintenance loop running in the direction it was built to run.
- **What is deliberately left unsolved:** the ratio. Not because it is hard to instrument but
  because it does not answer the question it was written for. The residue is a fact about the
  component rather than a defect in the item — **retiring this gate will cost a deliberate
  experiment, not a tally** — and knowing that in advance is cheap.

### 8. Nothing guards `SPEC.md`, which is what everything else is measured against

- **Wish:** something should notice when `SPEC.md` loses content. Candidates, **none chosen**: the
  `template/prove.sh` lite section asserting the standard headings are present; a line in
  `template/CLAUDE.md`; or **nothing at all**, because the project can add the check itself the
  moment it needs one — which is what actually happened.
- **Assumption it encodes:** that every other component defers to `SPEC.md` — the gate proves what
  it names, `pre-alpha` and `harden` read its `Phase:`, the `reviewer` grades against its
  requirements — so damage to it degrades all of them silently, and it is the one file with no
  check of its own.
- **Evidence:** Step 8, hardening `~/dev/coach`. A scripted edit deleted **three whole sections**
  of `SPEC.md`, `## Constraints` among them. `./prove.sh` was green before and after; the gate has
  no opinion about the spec, and the loss was caught by the `reviewer` agent rather than by any
  check. Note what was lost: `## Constraints` is where "personal data never enters git" lives, and
  it is upstream of a check the same session had just written.
- **Counter-argument, and it is strong:** coach fixed this unaided, adding a seven-heading assertion
  to its own `prove.sh` in the same session, with no harness involvement wanted or missed. That is
  **item 6's shape exactly** — a problem a project meets and solves locally — and item 6's evidence
  now argues the harness should stay out of it. One project is not two.
- **Delete when:** n/a until something is chosen.
- **Status:** waiting, on one project's observation. Recorded rather than built, per the standing
  rule that a component enters FACTORY only with evidence from a shipped project — and this one has
  a live counter-argument from the item directly above it. Revisit if a second project loses spec
  content, or if one is found to have been running against a damaged `SPEC.md` without noticing.

- **Step 9 decision: rejected.** One project, which found the damage *and fixed it unaided* in the
  same session — item 6's shape exactly, and item 6's rejection is the precedent. The cheapest
  candidate is worse than unearned: it **contradicts a settled design decision**. `template/prove.sh`'s
  lite section is *exactly one check*, the walking-skeleton check, and shipping a seven-heading spec
  assertion inside it makes every new project's pre-alpha start with two. Coach added its assertion
  at **hardening**, which is where a second check belongs and where `harden` step 5 already asks for
  one. **Reopen when:** `~/dev/coach` is found to have been running against a damaged `SPEC.md`
  without noticing. **Retargeted at close-out, 2026-09-12** — "a second project loses `SPEC.md`
  content" is struck, no second project is coming, and the surviving half is the dangerous one
  anyway: the first loss was caught inside one session by the `reviewer` agent, while a silent one
  has nothing watching for it. Coach's own `prove.sh` asserts its seven headings, which is that
  check, in the project, where item 6's evidence says it belongs.

### 9. Superpowers and FACTORY give contradictory instructions, and nothing arbitrates

- **Wish:** the stack should say which planning tool applies at which phase, rather than shipping
  two and hoping. Candidates, **none chosen**: a line in `template/CLAUDE.md` naming the entry
  point for the phase; `pre-alpha` explicitly overriding Superpowers' document steps; pinning
  `brainstorming` to its Bounded path at invocation time (the current, purely operational
  mitigation); or nothing, on the grounds that a human choosing deliberately each time is fine.
- **Assumption it encodes:** that two installed components giving opposite instructions is resolved
  by whichever one the model happens to read first, and that this is not a stable way to run a
  harness whose whole claim is discipline.
- **Evidence:** Step 7, twice over.
  - `superpowers:brainstorming` has a **Bounded** path (5 steps, "no plan document") and an
    **Architectural** path whose step 6 writes a design doc and step 9 hands off to
    `writing-plans`. `skills/pre-alpha/SKILL.md:24` says **"SPEC.md is the only planning
    artifact."** Both are loaded, and they cannot both be obeyed.
  - ~~**Path selection is not predictable from project state.**~~ **Corrected at Step 9: it is
    perfectly predictable, and that is worse.** A new project is Architectural by the skill's own
    rule, so FACTORY pre-alpha gets the design-doc path *every time* — the Step 7 run was right and
    the Step 5 run had simply not declared a path. It produced 1911 lines of design-plus-plan
    referencing itself rather than `SPEC.md`, all of it deleted, and it will do so again on every
    project unless something stops it at step 5.
  - `writing-plans` then specified a **57-test TDD suite** in pre-alpha, where `README.md:115-117`
    says the single `prove.sh` check stands in for a suite until hardening.
  - The same plan placed the `prove.sh` check at **task 9 of 9**, which would have left the Stop
    gate dormant for the entire build — against `pre-alpha/SKILL.md:12`, the Step 7 sub-guide §6,
    and the step prompt. It was rejected and rewritten to put the check first.
- **Delete when:** n/a until something is chosen.
- **Status:** waiting. **The cost is currently paid by a human noticing**, which worked in Step 7
  only because the conflict was being watched for. Weigh at Step 9 against the standing rule that
  a component enters FACTORY only with shipped-project evidence — note that three of the four
  candidates above are *prose*, not components, so the usual accretion objection is weaker here
  than it looks. Related: item 2 (delete `spec`), whose evidence now runs the other way precisely
  because `brainstorming` brings this document chain with it.
- **Step 9 decision: built in v3.3.0, as prose, in the skill that is already loaded at the moment
  the conflict happens.** This is the one item where the usual accretion objection genuinely is
  weaker, and Step 7's evidence is the strongest in the file: the cost was a human noticing, and it
  worked only because the conflict was being watched for. Two clauses in
  `skills/pre-alpha/SKILL.md`, no new component, no always-on cost beyond the words:
  - the Don't list's "SPEC.md is the only planning artifact" now says it **outranks** any other
    skill that wants a design doc or a plan file — use its questions, put the answers in SPEC.md,
    don't let the chain start — and names the operational mitigation: run `brainstorming`'s
    **architectural steps 1-5** (explore, clarifying questions, 2-3 approaches, sectioned design)
    and **stop at 5**, before step 6 writes the design doc and step 9 hands off to `writing-plans`.
  - the Do list's "write the `./prove.sh` check before the code it checks" now says what to do when
    a planning skill hands you a task list with that check late in it: **reorder it so the check is
    task 1**, because until it exists the gate is dormant and nothing is enforced for the whole
    build. That is the exact collision Step 7 caught at task 9 of 9.
- **`README.md` §3 carries the same rule for a human reader**, with the precedence stated in both
  directions: `pre-alpha` outranks Superpowers' planning skills **in pre-alpha**; at hardening the
  precedence flips and those skills are the point. A stack that says which tool wins where is a
  different thing from a stack that ships two and hopes.
- **The two candidates not taken:** a line in `template/CLAUDE.md` (always-loaded, and the conflict
  is phase-specific — the 60-line budget should not carry it), and "nothing, a human chooses each
  time" (which is what Step 7 did, at the cost of nearly losing the check-first discipline to a
  1608-line plan that was *better written* than the rule it broke).
- **The third candidate — "pin `brainstorming` to its Bounded path" — is struck, and this corrects a
  claim this file has carried since Step 7.** The `reviewer` agent caught it in the release diff, by
  reading `brainstorming/SKILL.md` instead of the record of it. The skill's classification rule is
  explicit and it is not ambiguous for our case: *"Bounded… If there is no existing flow to change,
  the task is not bounded"* (line 38), *"Architectural — new projects…"* (line 45), and in the Red
  Flags table, *"A new project has no existing flow — it is architectural"* — with *"Reaching for a
  label to skip work IS the doubt — take the heavier path"* directly above it. **Every FACTORY
  pre-alpha is a new project, so it is Architectural by rule**, and a mitigation that asks for
  Bounded asks the model to violate the skill it is invoking, at exactly the moment this item exists
  to stop two skills fighting. The mitigation that survives is to stop *inside* the path it will
  take anyway: steps 1-5 are the useful half and contain no artifact but the design in chat; steps
  6-9 are the chain.
- **So "path selection is not predictable from project state" (below, and in item 2) is withdrawn.**
  It was inferred from two runs rather than from the rule: the Step 7 run declared Architectural,
  which was **correct**, and the Step 5 run *never declared a path at all*, which is a run that
  skipped the classification step — not a run that classified Bounded. What varied was whether the
  skill's own first move was performed and announced, not what its rule says. The corrected finding
  is narrower and more useful: **the conflict is not that path selection is a coin-flip; it is that
  the path FACTORY always gets is the one that writes a design doc.** That is a fixed, predictable
  collision, which is why a fixed instruction can close it.
- **Corroboration found in Step 9's reverse pass, unlooked for:** `~/dev/coach/.claude/settings.local.json`
  contains exactly **one** granted permission for the entire project — `mkdir -p
  /home/drew/dev/coach/docs/superpowers/specs` — plus an `additionalDirectories` entry for the same
  path. The only permission dialog the project ever raised was the document chain asking for
  somewhere to put itself.
