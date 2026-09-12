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

So **every push to `main` ships to every project**, immediately, with no tag and no release.
Steps 3 and 4 above remain worth doing — the version number is what `plugin list`, the cache path
and the install record report, so a stale one makes every diagnostic lie — but understand what they
are: bookkeeping and a human-readable marker, not a mechanism that controls what anyone receives.
The only thing that controls that is what is on `main`. Two consequences to hold onto:
- **There is no such thing as an unreleased commit on `main`.** Don't push work-in-progress to it.
- The cache directory is named for the version (`cache/factory/factory-lite/3.0.1`) while holding
  whatever `main` said at install time, so **content drifts under a fixed version number**. A
  project that installed at 3.0.1 and one that installs later at 3.0.1 can hold different code.

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

## Items

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
  steps, "no plan document") and still produces a correct `SPEC.md`. If that holds, the wish is not
  "delete `spec`" but "invoke brainstorming in a way that cannot start a document chain", which is a
  different and cheaper change. The finding nobody predicted stands behind all of it: **two
  identical starting conditions — fresh factory-lite template, no code, placeholder `SPEC.md` — were
  classified onto different paths.**
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
  during those six stops the `reviewer` agent found a P0 (`food_id=10**30` returning a 500 with a
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
- **Delete when:** n/a until something is chosen.
- **Status:** waiting, on two projects' observations, and deliberately **not** decided in Step 7 —
  the step's guardrail forbids changing the harness mid-project, and every candidate above is a
  change to gate behaviour. Note the circularity this item sits on: the gate's delete-when is the
  main reason to collect the number, so a gate that cannot report it is a gate that cannot be
  retired on evidence. That is an argument for fixing the measurement, **not** an argument that the
  gate has earned permanence.
