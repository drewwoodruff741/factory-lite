# Step 3 — New repo with the scaffold in it (≈ 1 hour)

**Goal:** `factory-lite` exists on GitHub, passes its own two tests, and is tagged `v3.0.0`.

**Done when:** GitHub shows the repo with a `v3.0.0` tag, and locally both
`bash scripts/harness-smoke.sh` → `harness smoke: PASS` and `claude plugin validate . --strict`
→ no errors.

**Rules for this step**
- Nothing here needs the terminal UI. `gh repo create`, the smoke test and `claude plugin validate`
  all print and exit, so **I run every command with my Bash tool**. You never paste shell.
- What genuinely needs you: **two decisions** (§0) and **one browser look** at the end (§10).
  `gh` is already logged in as `drewwoodruff741`, so there is no login prompt coming.
- **Guardrail:** I touch nothing inside `skills/`, `agents/`, or `hooks/`. If a test fails I fix the
  cause in the scaffold *and* log the fix as one line in `BACKLOG.md` — not in some other project.
- Everything below is ordered so that **the repo is proven before it is published**. Tests first,
  `gh repo create` second, tag third. A broken first push is a public first impression and a
  tag you have to move.

---

## 0. The two decisions I need from you

**Decision 1 — public or private?**
My recommendation: **public**. Reasons, in order of weight:
1. Step 6 tests that a brand-new folder can resolve the pin
   (`extraKnownMarketplaces.factory.source.repo: drewwoodruff741/factory-lite`) straight from
   GitHub. On a public repo that either works or doesn't; on a private one every failure has a
   second possible cause (credential/scope), and you'd be debugging two things at once.
2. There is nothing to protect. I checked: the repo contains no secrets, and your
   `.claude/settings.local.json` (the allowlist this session has been accumulating) is ignored
   by `~/.config/git/ignore`, so it is not tracked and will not be pushed.
3. A plugin marketplace is a thing other people install from. Public is the shape it wants.

Private is a perfectly fine answer — it works today because `gh` is authenticated — and it is
one command to flip later (`gh repo edit --visibility public`). Say the word either way.

**Decision 2 — what name goes in the two `<your name>` blanks?**
It becomes the plugin's `author.name` and the marketplace's `owner.name`, both visible in
`/plugin` and in `claude plugin details`. Your `git config user.name` is **`Drew`**.
My recommendation: **`Drew Woodruff`** if the repo is public (a bare first name in a public
author field reads like an unfilled template), plain **`Drew`** if private. Overrule me with any
string you like — a handle (`drewwoodruff741`) is also normal here.

**And one decision I have already made for you, with its reason — §2.**

---

## 1. What the three pieces actually are (one line each, as the step asks)

| Piece | What it is |
|---|---|
| `.claude-plugin/plugin.json` | The plugin's **identity card** — name, version, description, author. Claude Code reads it to know what `factory-lite` *is*; **bumping `version` here is what "releasing" means**, and it's the number pinned projects compare against. |
| `.claude-plugin/marketplace.json` | The **catalogue** — a named list (`factory`) of plugins plus where to fetch each one. Adding `drewwoodruff741/factory-lite` as a *marketplace* is how a project learns the plugin `factory-lite` exists at all; installing it is the second, separate act. |
| `source: "./"` | "**The plugin is this repo, at its root**" — the path is resolved relative to the marketplace's own clone, which is why repo = plugin = marketplace works. It only resolves when the marketplace was added **via git** (`<owner>/<repo>`), never from a raw file URL, and it must be `"./"`; plain `"."` is not accepted. |

The practical consequence, and the reason the ordering in §8–§9 matters: a project doesn't get
your plugin from your disk, it gets it from **the GitHub repo at the tag/branch it resolves**.
Until §8 has run, `factory-lite@factory` is unresolvable anywhere but this machine.

---

## 2. Rename `master` → `main` before publishing — my call, and why

**Recommendation: rename, now.** One command, zero risk today:

```
git branch -m master main
```

Why now rather than never or later:
- `gh repo create --source=. --push` pushes the branch you are on **and makes it the repo's
  default branch**. Whatever it's called at that moment is what GitHub, every future PR base,
  every clone, and every `@main` reference inherit.
- Right now there is no remote, no clone, no tag, no CI, and no open PR (Step 2 confirmed all
  four). The rename costs one command and breaks nothing. After §8 it costs a GitHub default-branch
  change *plus* re-pointing every clone — small, but pointless to pay for.
- Everything around this project already assumes `main`: GitHub's default for new repos, the
  Claude Code extension's own PR defaults, and the docs you'll write in Steps 6 and 9.

There is no argument for keeping `master` here except inertia, and inertia is the thing this
whole rebuild is against.

- **You should see,** after I run it: `git branch` prints `* main` and nothing else, and VS Code's
  bottom-left status bar switches from `master` to `main` (it may take a beat, or a click on the
  branch name to refresh).

---

## 3. Fill the two `<your name>` blanks

Exactly two edits, both in `.claude-plugin/`, both one word:

```
plugin.json       "author": { "name": "<your name>" }       ->  "name": "<your answer>"
marketplace.json  "owner":  { "name": "<your name>" }       ->  "name": "<your answer>"
```

- **You should see,** when I show the diff: two changed lines, both inside a `"name"` field, and
  `grep -rn '<your name>' .` returning nothing afterwards. Versions (`3.0.0` in both files) stay
  as they are — they're already correct for this tag.

---

## 4. `template/.claude/settings.json` — verify, don't edit

It already pins:

```json
"extraKnownMarketplaces": { "factory": { "source": { "source": "github", "repo": "drewwoodruff741/factory-lite" } } },
"enabledPlugins": { "factory-lite@factory": true }
```

`gh repo create --source=.` names the repo after the directory — `factory-lite` — under your
login `drewwoodruff741`. So this line is **already correct** and I change nothing.

The one thing that would break it: if you answer Decision 1 with a different *repo name*. If you
want anything other than `factory-lite`, tell me in §0 and I'll update this line in the same
commit (it's the only place the repo name is hard-coded — `grep -rn drewwoodruff741 .` confirms).

- **You should see:** me print that grep, with a single hit, in `template/.claude/settings.json`.

---

## 5. Executable bits — a check, not a change

Step 0 already ran `chmod +x` and git recorded it. In the index today:

```
100755 hooks/stop-gate.sh        100755 scripts/init.sh
100755 scripts/harness-smoke.sh  100755 template/prove.sh
```

All four of the files that must be executable already are, in git's own record (`100755`), which
is what survives a clone — a local `chmod` that git didn't record would not. So this sub-step is
**verification only**; if any of the four ever reads `100644`, the fix is
`git update-index --chmod=+x <file>`, not a bare `chmod`.

`.gitattributes` already pins `eol=lf` for `*.sh`, so the other half of the "gate never fires"
failure mode (CRLF) is covered for every future clone, including a Windows one.

- **You should see:** four `100755` lines and no command that changes anything.

---

## 6. Run both tests — **before** publishing

```
bash scripts/harness-smoke.sh          # expect the last line: harness smoke: PASS
claude plugin validate . --strict      # expect: no errors (--strict also fails on warnings)
```

What the smoke test actually exercises, so you know what a PASS is worth: it builds a throwaway
project from `template/` with `init.sh`, then drives `hooks/stop-gate.sh` through seven cases —
a failing `prove.sh` must block with exit 2; a passing one must exit 0; an unchanged tree must
**not** re-run `prove.sh` (chat-only turns stay cheap); a missing `prove.sh` must not block;
the 3-strike loop guard must hand back to you on the fourth attempt; all four JSON manifests must
parse; and `template/CLAUDE.md` must be ≤ 60 lines with frontmatter present on every skill and
agent. It needs `python3` for the JSON check — you have 3.13.15, so that's fine.

`claude plugin validate` is the other half: it reads the manifests the way Claude Code will at
load time. It prints and exits — it does not open the terminal UI.

- **If either fails:** I stop, show you the failure, fix the *cause in the scaffold*, add one line
  to `BACKLOG.md` recording what broke and why (the guardrail for this step), and re-run both from
  the top. I do not publish a red tree.
- **Optional, 10 seconds:** `claude plugin details factory-lite` prints the component inventory and
  a projected token cost. That projection is the first cheap read on "is v3 under v2's ~10.5k?" —
  Step 4's `/context` is the real measurement, but if this number already looks large, better to
  know before tagging. Say if you want it; I'll run it and note the number in LESSONS.md.

---

## 7. Commit

One commit for §2–§3 (and §4 only if the repo name changed):

```
git add -A && git commit -m "release prep: fill author/owner, rename master -> main"
```

- **You should see:** `git status` clean, and `git log --oneline -1` showing that message on `main`.

---

## 8. Publish

```
gh repo create --source=. --push --<public|private> \
  --description "FACTORY-lite: a minimal Claude Code harness (plugin + marketplace)"
```

`--source=.` means "publish *this* existing local repo" rather than creating an empty one; it
names the repo after the directory (`factory-lite`), adds `origin`, and `--push` pushes `main`
and sets it as the default branch. No interactive prompts, so no terminal UI.

- **You should see:** the new repo URL printed, then from me: `git remote -v` showing
  `origin  https://github.com/drewwoodruff741/factory-lite.git` and `git branch -vv` showing
  `main` tracking `origin/main`.

---

## 9. Tag `v3.0.0` and push the tag

```
git tag -a v3.0.0 -m "FACTORY-lite v3.0.0: proof gate, pre-alpha discipline, explorer + reviewer"
git push origin v3.0.0
```

Annotated (`-a`), not lightweight: it carries a date, an author and a message, and it's what
`git describe` and GitHub's release UI expect.

**Not used here:** `claude plugin tag`. It's a genuinely useful command — it cross-checks that
`plugin.json`'s version and the marketplace entry agree before tagging — but it writes the tag
`factory-lite--v3.0.0`, and this step's Done-when asks for the bare `v3.0.0`. The agreement it
would check (`3.0.0` in both files) I verify by eye in §3. If you ever want both tag styles, that's
a Step 9 release-rule decision, not a Step 3 one.

- **You should see:** `git tag` printing `v3.0.0`, and the push reporting
  `* [new tag] v3.0.0 -> v3.0.0`.

---

## 10. Confirm the Done-when — the one part that needs your eyes

I'll verify from my side with `gh api repos/drewwoodruff741/factory-lite/tags` (expect one entry,
`v3.0.0`) and re-run both tests on the pushed tree.

**Your part:** open <https://github.com/drewwoodruff741/factory-lite> in a browser and confirm:
- the file list looks like the scaffold (`.claude-plugin/`, `hooks/`, `skills/`, `agents/`,
  `template/`, `scripts/`, the four markdown files),
- the branch selector says **main**,
- the tag count next to it reads **1 tag**, and clicking it shows `v3.0.0`,
- `.claude/settings.local.json` is **not** there (it's git-ignored; this is the one-second check
  that your local allowlist didn't go public).

Final checklist:

| Done-when | Evidence |
|---|---|
| Repo on GitHub | `gh repo view` + your browser look |
| Tagged `v3.0.0` | `gh api .../tags` shows it; browser shows 1 tag |
| Smoke test passes | `harness smoke: PASS` |
| Plugin validates | `claude plugin validate . --strict`, no errors |
| No blanks left | `grep -rn '<your name>' .` → nothing |

---

## 11. Close out the step

With your go, at the end I will:
1. Tick `[x] Step 3` in `START-HERE.md`.
2. Fold anything surprising into `LESSONS.md` (a build finding) or `BACKLOG.md` (a harness wish),
   one line each, and into the Step 4 brief — the same pattern as Steps 1 and 2.
3. Commit `step 3 done: ...` and push.

---

## Appendix — one scaffold nit I found reading README.md (your call, not part of the step)

`README.md` § "Known edges" says the marketplace is added as `/plugin marketplace add <owner>/factory`.
The repo is **`factory-lite`**; `factory` is the *marketplace name inside* `marketplace.json`, not
the repo. The correct instruction is `<owner>/factory-lite` — which is what `START-HERE.md`'s
troubleshooting table and `template/.claude/settings.json` already say, so README is the lone
outlier. It's a one-word doc fix, outside `skills/`/`agents/`/`hooks/`, and it would mislead you in
Step 6 precisely when the pin fails and you reach for the manual fallback.

Options: **(a)** fix the word in the same commit as §7, **(b)** log it in `BACKLOG.md` and leave
README alone this step. I lean (a) — a wrong command in the troubleshooting section is exactly the
kind of thing that costs an hour later. I won't touch it without your yes either way.
