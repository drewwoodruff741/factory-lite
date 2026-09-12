# Step 9 prompt — paste this whole file into a fresh session

Open `~/dev/factory-lite` in VS Code (**File → New Window → Open Folder**; bottom-left must read
`WSL: Ubuntu`), start a **new** Claude Code session, and paste everything between the rules below.
Nothing needs filling in.

**This is the last step of the plan, and it is the backlog pass.** Steps 1–8 deliberately deferred
every harness decision to here, so this session is not starting from a blank page — it is starting
from nine items and a set of named questions, listed at the bottom.

---

CONTEXT FOR THIS SESSION
FACTORY-lite is a minimal Claude Code harness. It lives at `~/dev/factory-lite`, is at **v3.2.0**,
and is published at github.com/drewwoodruff741/factory-lite. One real project has been built on it
and hardened: `~/dev/coach`, a local nutrition tracker (separate repo, no remote, local only).

Hard constraints:
- I use ONLY the Claude Code VS Code extension, on VS Code Remote-WSL (WSL2 Ubuntu). I never use
  the Claude Code terminal UI, and I don't want blocks of shell to paste either: run them yourself
  with your Bash tool (that is not the terminal UI) and hand me only what genuinely needs me — a
  sudo password, a browser login, or a VS Code UI action. Slash commands go in the extension's chat
  box; plugin, hook and permission management is under "/" → Customize. Never `claude` alone;
  `claude --version`, `claude plugin validate .`, `claude plugin list` and friends are fine because
  they print and exit.
- **Client commands must be typed by me, not relayed to you.** `/context`, `/plugin`, `/hooks`,
  `/doctor` and `/memory` are rendered by the client; no tool dispatches them. A session asked to
  "run" them reads config off disk and infers, and gets it wrong. Ask me to type them and paste back
  what I see. This bit twice: Step 5 concluded the gate "is not loaded" while that gate's message
  was printing at the end of its own turn, and Steps 7 and 8 both needed me to type `/hooks` because
  **a gate that never fires is indistinguishable from one that is not wired**.
- Environment is verified, do not re-check: git 2.53.0, bash 5.3.9, jq 1.8.1, node v22.22.1,
  gh 2.46.0, claude 2.1.269, uv 0.12.9, ruff 0.16.6, python3 3.13.15.
- **Do not re-price with `/context`.** Step 5 settled it: the empty-folder baseline is 32.3k of a
  1M window, factory-lite is ~560 tok, Superpowers ~2.1k, v2 was ~10.5k. The `/context` **Total**
  cannot be differenced because `system tools` swings ±2.8k on its own — price by summing the
  buckets you control. And the number that actually matters: **v2's damage was behavioural, not
  contextual**, so a small `/context` number is necessary but never sufficient.
- **The release rule** is at the top of `BACKLOG.md` and applies to every change. `./prove.sh` in
  this repo now enforces steps 1–3 of it (smoke test, four validate calls, both manifests agreeing
  on `version`) and the Stop gate runs it. Run it and believe it. Prose-only edits skip the version
  bump. **Projects clone `main` shallow at depth 1 and never fetch tags, so every push to `main`
  reaches `~/dev/coach` immediately** — there is no such thing as an unreleased commit on `main`.

Read before deciding anything: `README.md` (design and every component's delete-when), `BACKLOG.md`
(nine items, all `waiting`), `LESSONS.md` (the evidence, including everything Steps 7 and 8 found).

STEP 9: The maintenance loop

Goal: FACTORY improves without growing back into v2.

The session produces:

1. **The review procedure for `BACKLOG.md`, written down** so it can be re-run after every project
   and every model release. Per item: assumption, evidence, delete-when. No evidence → it waits, and
   that is a result, not a failure. Evidence → build it here, in this repo, with the
   assumption/evidence/delete-when header convention, under the release rule.
2. **That procedure run once, against all nine items.** Every item gets a status.
3. **The reverse pass**, which is the half that keeps the harness small: open each component, read
   its delete-when line, and delete what has expired. `README.md` §1 has the table. This pass is why
   the step exists — an improvement loop that only adds is how v2 happened.

Done when: `BACKLOG.md` has a status on every item, and FACTORY has **the same number of components
as it had after Step 3, or fewer**.

Guardrails:
- **The only way a component enters FACTORY is with evidence from a shipped project.** One project's
  observation is one observation; deletions get the same bar as additions.
- **Prefer deleting.** If an item has been waiting through two projects with no evidence, that is
  evidence — about the item.
- Anything that touches `hooks/`, `skills/`, `agents/`, the manifests, `template/` or `scripts/`
  ships to `~/dev/coach` the moment it is pushed. Full release rule or it does not get pushed.
- Do not touch `~/dev/coach`. It is mid-backlog — item 4, the `/measure` SVG chart, is next there
  and untouched.

---

## The deferred agenda — everything Steps 1–8 left for here

Nothing below is an open question in someone's memory; each has an item or a recorded finding.
**Three of these were deliberately deferred more than once, so resist deferring them again.**

### Already settled by evidence — just execute
- **Item 7's "a hand-tally is cheap enough" candidate is falsified. Strike it.** Step 8 asked for
  "stops where the gate RAN and passed" and could not produce it *even counting live*, because a
  pass and an unchanged-tree skip are both a silent exit 0. The candidate rests on an assumption
  that has been tested and is false.

### The central question of this step
- **Item 7: the Stop gate's delete-when is unanswerable as written** (">95% of stops where the gate
  ran"). Two projects, two findings: the denominator collapses as sessions get longer (coach's whole
  skeleton was built in one run, tally ~1 stop), and **deterrence and absence produce identical
  tallies** — both sessions ran `prove.sh` by hand *because* the gate exists. Step 8's reframing is
  the better question: **"does anything else run `prove.sh` if the gate doesn't?"** Decide the
  delete-when, or decide the gate cannot have a numeric one. Cheapest surviving candidate: a
  one-line `systemMessage` on PASS.
- **The uncomfortable evidence to weigh honestly:** two projects in, the components that produced
  findings you can point at are the **`reviewer` agent**, the **check-written-first rule**, and the
  **phase discipline**. The always-on Stop gate has blocked twice in the whole build and both were
  defects induced on purpose to test it. That is not a case for deleting it — see deterrence above —
  but if anything gets trimmed the evidence points the opposite way from the intuition that a hook
  is rigorous and an agent is soft.

### Items with evidence pointing at "do nothing"
- **Item 6** (project data dirties the gate's state hash): two projects, both solved it locally with
  two `.gitignore` lines, neither wanted the harness involved. The "do nothing" candidate has the
  only evidence either way.
- **Item 8** (nothing guards `SPEC.md`): one project lost three sections including `## Constraints`
  to a scripted edit, with `prove.sh` green throughout — and fixed it unaided in the same session.
  Item 6's shape exactly.

### Items tangled together — resolve as one decision, not three
- **Item 2** (delete `spec`): evidence now runs *against* deletion. `brainstorming` writes an
  excellent `SPEC.md` **and** brings a document chain `pre-alpha` forbids.
- **Item 1** (`spec` should fill `CLAUDE.md`'s title): dies if item 2 fires. Still one sighting for
  `spec`; two for `brainstorming`.
- **Item 3** (trim `verify` item 2): to be done in the same release as item 2, if it fires.
- **Item 9** (nothing arbitrates between Superpowers and FACTORY): the reason item 2's evidence
  reversed. Three of its four candidates are prose, not components.

### Deliberately untouched since Step 6
- **Item 4** (a project cannot tell whether the harness loaded) — widened by Step 7: the real
  requirement may be "tell that the gate is *working*", which a missing install and a
  never-triggered install both fail.
- **Item 5** (`main` is production, nothing marks the difference) — the interim discipline is a
  habit, not a mechanism. It has held for two projects.

### Environment, not a component
- **Auto-accept was removed in Step 7** (owner: `tjcg.auto-accept-claude-code`, one extension
  writing four config paths on every startup; backups in
  `~/backups/factory-lite-chore1-2026-09-12`). But **coach's sessions ran in Claude Code's `auto`
  permission mode**, so the template's permissions block still has not been exercised end to end by
  a real project. Worth one check, not a project.

### Known-good, do not "fix"
The sub-guide-written-to-disk-before-execution pattern (survived a session restart that killed the
session that wrote it); pre-registered observations (stopped scoring-to-taste three times, though
two criteria were themselves defective — see item 2); the three-session timebox (came in under);
`prove.sh` asserting on a **remainder** rather than a total, which is the only reason a
one-character mutation was caught.

---
