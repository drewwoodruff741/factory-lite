# Step 2 — Capture LESSONS.md and freeze v2 (≈ 30 min)

**Goal:** carry the *evidence* out of FACTORY v2 and nothing else, then make v2 read-only so it
can never be quietly mined for code later.

**Done when:** `LESSONS.md` has at least **five concrete v2 lines**, the v2 `/context` number is
recorded in it, and the v2 repo is archived on GitHub with a `v2-final` tag pushed.

**Rules for this step**
- Nothing here needs the terminal UI. I run the shell (git tag, push, `gh api`) with my Bash tool;
  you do the three things only you can do: **open the v2 project in VS Code**, **type `/context`
  in a fresh session there**, and **answer the interview**.
- **No code leaves v2.** Not a snippet, not a rule file, not a skill. Only sentences about what
  happened.
- **`LESSONS.md` is not empty.** Step 1 already wrote the 32.3k empty-folder baseline and two
  build-time findings into it. This step *fills the blanks around them* — nothing existing is
  rewritten, reordered, or "cleaned up".
- I do not invent lessons. Every line in the file will be your words, tightened. If you can't
  remember a rule, it wasn't load-bearing — that absence is itself the finding.
- If something you describe is really project-specific, it does **not** go in `LESSONS.md` as a
  harness lesson. It goes under "lived in the harness by mistake", which is the honest home for it.

---

## 0. The two things I need from you before we start

1. **The v2 repo:** `owner/repo` on GitHub, and where the clone lives locally (e.g.
   `~/dev/factory` or `~/projects/factory-v2`). If you're not sure of the local path, say so — I
   can find it with a search under `~`.
2. **The v2 `/context` number** — §2 walks you through getting it. **Get it before we archive**,
   while opening the project is still routine.

I'll ask for both at the start of execution; you don't need to prepare anything else.

---

## 1. Read `LESSONS.md` as it stands

I re-read the file before touching it. Its current shape:

| Section | Status going into Step 2 |
|---|---|
| `## Startup cost of v2 (for comparison)` | one placeholder line — **Step 2 fills it** (§2) |
| `## Empty-folder baseline (v3 measuring stick, 2026-09-11)` | written in Step 1 — **do not touch** |
| `## What bit us` | empty bullets — **Step 2 fills** (interview Q1–Q2) |
| `## What we kept trying to add and never used` | empty bullet — **Step 2 fills** (Q3) |
| `## Things that were actually project-specific…` | empty bullet — **Step 2 fills** (Q4) |
| `## From building v3 itself` | two Step-1 findings — **do not touch** |

- **You should see,** when I show you the diff at the end of §4: additions only inside the three
  empty sections plus the one placeholder line. Every other line unchanged. If the diff touches
  anything else, that's a bug in how I wrote it — say so and I'll redo it.
- The two "From building v3 itself" lines are real evidence, but they are **not** v2 lessons and
  **do not count** toward the five.

---

## 2. Measure v2's startup cost (do this first — archiving comes later)

This is the "before" half of the before/after comparison that Steps 4 and 5 finish. It only means
anything if the session is genuinely fresh and genuinely inside the v2 project, with whatever
`CLAUDE.md`, rules, skills, agents and plugins v2 loads.

1. In VS Code (bottom-left still reading **`WSL: Ubuntu`**): **File → Open Folder…** → the v2 repo
   path. Let it open in a new window if it offers.
2. Open the Claude Code extension there and start a **new session** — not a resumed one. (A
   continued session's number includes the old conversation and is useless here.)
3. First thing in the chat box, before any other message:

   ```
   /context
   ```

4. Then, because `/context` on 2.1.269 prints no path line (Step 1 finding), confirm the session
   is actually where you think it is by typing:

   ```
   what is your working directory?
   ```

- **You should see:** a token table whose **Total** line is well above the 32.3k empty-folder
  baseline, with named rows for `CLAUDE.md` / memory files, skills, agents, MCP tools — that gap
  *is* the v2 harness. And a working directory under `/home/...` matching the v2 repo.
- **Report back to me:** the Total (e.g. `78.4k / 1.0M (8%)`) and, if it's interesting, the two or
  three biggest rows. The row breakdown is worth a sentence in `LESSONS.md` when one component
  dominates — "the rules files alone cost N" is exactly the kind of line that justifies v3's
  shape.
- **If v2 won't load** (missing plugin, broken marketplace pin, errors on session start): that is
  a lesson, not a blocker. Tell me what it said, we record it, and the "Startup cost" line reads
  `could not start — <reason>` instead of a number.
- **If there is no v2 project left to open**, say so; we record `not measured` and the comparison
  in Steps 4–5 becomes absolute-tokens-against-32.3k only.

---

## 3. The interview

I ask **one question at a time and wait**. No questionnaire, no multi-part questions, no
suggestions of what you might have meant. If an answer is thin, I ask one follow-up for the
missing field — never more than one.

Every "what bit us" line wants three fields:

> **what happened** → **what it cost** → **what it taught**

The third field is the one that matters; it's the reason a v3 component exists or the reason one
will never be added. A line with only the first field is a war story, not evidence.

**The order:**

- **Q1** — The worst one first: what in v2 actually bit you? (Then, if needed, one follow-up for
  cost or lesson.)
- **Q2** — Next one. Repeated until you run dry, roughly three or four rounds. "That's all I've
  got" ends it immediately; I won't fish.
- **Q3** — What did you keep adding to the harness and never actually use? (Agents, rules, hooks,
  skills, memory machinery — the things that existed and never fired.)
- **Q4** — What was genuinely project-specific but lived in the harness anyway? (The test: would a
  *different* project ever have needed it?)
- **Q5** — Which v2 rules can you still recite without looking? Anything you can't recall was not
  load-bearing, and that's the finding — it goes in the file as one line, not as a guess at what
  the rule was.

**Guardrails I hold during the interview**
- If you start describing *how* something was implemented, I stop taking notes on the mechanism
  and ask what it cost you. Mechanism is code; code stays in v2.
- If an answer is really about one project, I say so and file it under Q4's section.
- I won't turn one lesson into three lines to hit five.

**If we end up under five concrete lines,** I'll say so plainly and we stop there: the Done-when
isn't met, and the options are (a) sleep on it and finish the interview in a second pass, or
(b) record the shortfall itself as a line — *"a harness whose rules I can no longer recall was not
load-bearing"* — which is honest and, arguably, the single most useful thing v2 taught. I will not
pad the file to make a checkbox go green.

---

## 4. I write `LESSONS.md`

After the interview I write all the answers in one edit, then show you the file.

- Additions go **only** into the three empty sections and the one placeholder line (§1's table).
- Each line is compressed to one or two sentences in your own vocabulary. Format for "What bit
  us": `**<short handle>:** what happened → cost → what it taught.`
- **You should see:** a `git diff` where every `+` line sits inside those four places, and a total
  of five or more concrete v2 lines.
- **Correct me freely at this point** — wording, emphasis, anything I got wrong. This is the whole
  inheritance from v2; it's worth one careful read.

---

## 5. Freeze v2 — order matters

**Archiving makes a GitHub repo read-only.** Tags cannot be pushed to an archived repo. So:
**tag → push tags → archive**, never the other way round. (Archiving is reversible from the same
settings page, so this is not a one-way door — but the ordering still is, in practice.)

**a. I inspect the local v2 repo first** (read-only): current branch, remote URL, whether the tree
is clean, whether a `v2-final` tag already exists.

- **You should see me report:** the remote matches the `owner/repo` you gave me, and either "tree
  clean" or a list of uncommitted files. If there are uncommitted changes, you decide: commit them
  into the freeze, or tag the last clean commit and leave them behind. I won't pick for you.

**b. Tag it.** An annotated tag, so the freeze carries a date and a reason:

```
git tag -a v2-final -m "FACTORY v2, frozen. Lessons carried to factory-lite (v3); no code migrated."
git push origin v2-final
```

- I run these after you say go. **You should see:** the tag listed by `git tag -l 'v2*'` and, after
  the push, on GitHub under Tags.
- **If the local repo has no remote** (never pushed): nothing to push or archive — we record that
  in `LESSONS.md` and the "archived" half of the Done-when becomes "tagged locally; no remote
  existed".

**c. Archive on GitHub.** Two routes; pick one and tell me:

- **The UI (what the plan assumes):** GitHub → the v2 repo → **Settings** → scroll to the bottom
  (**Danger Zone**) → **Archive this repository** → type the repo name to confirm. **You should
  see:** a grey "This repository has been archived by the owner. It is now read-only." banner at
  the top of the repo page.
- **Or I do it** with a print-and-exit call, no browser: `gh api -X PATCH repos/<owner>/<repo> -f
  archived=true`. **I will ask for an explicit go on this specific command** before running it —
  it's an outward-facing change to a repo, and I'd rather you say the word than infer it from
  "go".

Either way I verify afterwards with `gh api repos/<owner>/<repo> --jq .archived` → **`true`**.

**d. What we do *not* do:** no `git clone` of v2 into the v3 tree, no copying rule files "just to
look at them", no `git log` archaeology to reconstruct a rule you couldn't remember in §3. The
interview is the transfer mechanism. That's the design.

---

## 6. Close out

1. I write the v2 `/context` number into the `## Startup cost of v2` line with today's date
   (2026-09-11), replacing the `<tokens> on <date>` placeholder.
2. **If Step 2 turned up anything about the *scaffold* itself** (a wrong line in `README.md`, a
   section heading in `LESSONS.md` that doesn't fit what you actually had to say), I fix it in
   `~/dev/factory-lite` and add one line to `BACKLOG.md` or `LESSONS.md` — never a workaround
   elsewhere.
3. Commit: `git add -A && git commit -m "step 2 done: LESSONS.md filled from v2, v2 archived"`.
4. Tick Step 2's box in `START-HERE.md` (I'll do it in the same commit).
5. Close this session. Step 3 starts fresh.

---

## 7. Final checklist

- [ ] v2 `/context` total captured and written into `LESSONS.md` (or an honest "not measured")
- [ ] Interview run one question at a time; no line in the file is mine rather than yours
- [ ] **Five or more concrete v2 lines** across the three v2 sections
- [ ] Step 1's baseline and "From building v3 itself" sections untouched (verify in the diff)
- [ ] No code, config, or rule text copied out of v2
- [ ] `v2-final` tag exists locally and on GitHub
- [ ] `gh api repos/<owner>/<repo> --jq .archived` prints `true`
- [ ] Any scaffold defect found today is fixed in the scaffold and logged in `BACKLOG.md`
- [ ] `step 2 done` committed; Step 2 ticked in `START-HERE.md`

---

## If something goes wrong

| Symptom | First thing to check |
|---|---|
| `/context` in v2 errors on session start | Note the error verbatim — it's a lesson. Don't repair v2; it's being frozen. |
| The number looks *lower* than expected | Was the session fresh, and actually in the v2 folder? Ask "what is your working directory?" |
| `git push origin v2-final` is rejected | Already archived (read-only) — unarchive in Settings, push, re-archive. Or the remote isn't the repo you named. |
| `gh api ... archived=true` returns 403 | You're not the repo owner/admin, or the token lacks `repo` scope (`gh auth status`). Use the UI route. |
| The interview stalls at three lines | Say so. We take option (b) in §3 and record the shortfall honestly rather than padding. |
| You remember a rule but not why | It stays out. "Why" is the load-bearing half; a rule without it is the exact thing v3 exists to not carry. |

---

## Guardrails honoured by this step

No hook, agent, skill, rule, or plugin is added or proposed. The only files touched in
`~/dev/factory-lite` are `LESSONS.md`, `START-HERE.md` (one checkbox), `docs/subguides/step-2.md`,
and — only if today turns one up — `BACKLOG.md`. Nothing is written into the v2 repo except one
annotated tag. Zero lines of v2 code enter v3.
