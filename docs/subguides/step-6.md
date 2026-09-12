# Step 6 sub-guide — the pin proved from GitHub, and a release rule

**Goal:** a brand-new folder gets the harness from GitHub with no manual copying except `init.sh`.

**Done when:**
1. A project you did not hand-configure shows `factory-lite@factory` enabled in `/plugin`, sourced
   from the `factory` marketplace, with no marketplace-add and no install step.
2. The question *which ref does an installing project actually get* is answered **from observation**,
   not from the docs, and written into `LESSONS.md`.
3. The five-part release rule sits at the top of `BACKLOG.md`.
4. The Superpowers-in-the-template question has an answer either way, and if the answer is yes, the
   release rule has been executed against that very change.

Everything below is either a command **I** run with my Bash tool, or a **you** action in VS Code.
Nothing here launches `claude` on its own.

**Guardrails for the whole step:**
- **Do not symlink, and do not strip the plugin keys.** Steps 4 and 5 both loaded factory-lite as
  `factory-lite@skills-dir`. That is the *testing* mechanism. The `extraKnownMarketplaces` +
  `enabledPlugins` pair in `template/.claude/settings.json` is the *shipping* mechanism, and it is
  the thing under test. Leave the settings file exactly as `init.sh` copies it.
- Add no hook, agent, rule, or plugin to FACTORY. The only scaffold edit this step may produce is
  the Superpowers pin in the template, if §6 goes that way.
- Do not delete `skills/spec/` — that is Step 7's call, on Step 7's evidence.
- No `/context` re-pricing. Step 5 settled the numbers.
- No stable/latest channels. One tag is enough until a second project exists.

---

## 0. What I already checked, so the session doesn't re-derive it

I read the scaffold and the machine's plugin state before writing this. Five facts shape the step,
and two of them correct the plan:

1. **The marketplace pin is shaped correctly.** `template/.claude/settings.json` holds
   `extraKnownMarketplaces.factory.source = {"source":"github","repo":"drewwoodruff741/factory-lite"}`
   — byte-for-byte the shape that `~/.claude/plugins/known_marketplaces.json` already uses for
   `claude-plugins-official`. Nothing looks malformed going in.
2. **The `factory` marketplace has never been fetched on this machine.** `known_marketplaces.json`
   lists only `claude-plugins-official`; the cache holds only superpowers. So §2 is a genuine
   cold-start test, not a re-run against a warm cache. Good.
3. **`main` is three commits ahead of `v3.0.1`, and both say version 3.0.1.**
   `v3.0.1` = `5581d67`, `main` = `origin/main` = `c863951`. The diff is `BACKLOG.md`,
   `LESSONS.md`, `START-HERE.md`, plus three added files: `docs/step-5-prompt.md`,
   `docs/step-6-prompt.md`, `docs/subguides/step-5.md`.
   **Correction to the step prompt:** it says to answer the ref question by checking "the installed
   copy's `plugin.json` version". That check is inert — the tag and `main` both say `3.0.1`, so the
   version number cannot tell them apart. The discriminator is **file presence**:
   `docs/step-6-prompt.md` exists on `main` and does not exist at `v3.0.1`. §3 uses that.
4. **How the two cache layers differ, from the one worked example on disk.** The *marketplace*
   checkout `~/.claude/plugins/marketplaces/claude-plugins-official/` is **not** a git repo — it is
   a GCS tarball with a `.gcs-sha` file. The *plugin* cache
   `~/.claude/plugins/cache/claude-plugins-official/superpowers/6.3.0/` **is** a git checkout, on a
   detached HEAD at `b36e082`. Do not generalise from that first half: `claude-plugins-official` is
   first-party and gets a Google-hosted mirror. A third-party GitHub marketplace like ours will
   most likely be a real `git clone`. §3 checks rather than assumes.
5. **Superpowers is pinned by a sha that Anthropic wrote, not by anything version-resolving.** Its
   entry in the official `marketplace.json` is
   `{"source":"url","url":"https://github.com/obra/superpowers.git","sha":"b36e082…"}`. That is why
   its checkout sits at a fixed commit. **Our entry has no sha and no ref** — `"source": "./"`,
   relative to a marketplace fetched from a repo with no ref specified. So the strong prediction
   going into §3 is that **a project gets `main`, and the tag is decoration.** Predicting it is not
   proving it; §3 proves it.

One more piece of state worth naming: `~/.claude/plugins/data/` already contains
`factory-lite-skills-dir`, left by Steps 4–5. If the pin resolves, a **second** sibling should
appear — `factory-lite-factory` or similar. That is a cheap corroborating signal in §3.

---

## 1. Window layout (do this first)

Same two-window discipline as Steps 4 and 5, for the same reason: a plugin resolves at session
start, and the plugin under test lives in a different folder than the project under test.

- **Window 1 — `~/dev/factory-lite`** (this one). Scaffold, `BACKLOG.md`, `LESSONS.md`, commits, and
  every command I run. Never test from here — a slash command typed in this window returns
  `Unknown command`, because no plugin is loaded in the harness repo (Step 4 lesson).
- **Window 2 — `~/dev/scratch-pin`** (created in §2). The test subject. Never fix the harness from
  Window 2.

Open Window 2 with **File → New Window**, then **File → Open Folder… → `/home/drew/dev/scratch-pin`**.
Bottom-left must read `WSL: Ubuntu`. Don't open it before §2 finishes — the folder won't exist, and
the extension needs at least one file present before it will open a session there (Step 1 quirk).

---

## 2. Build the scratch project — I run this

One block from Window 1. Deliberately shorter than Step 5's, because four of its five actions were
symlink scaffolding that this step must **not** do:

1. `bash ~/dev/factory-lite/scripts/init.sh ~/dev/scratch-pin` — copies `CLAUDE.md`, `SPEC.md`,
   `prove.sh` (CRLF-stripped, `chmod +x`), `.claude/settings.json`.
2. `git init` and a first commit. The gate hashes git state to decide whether to re-run `prove.sh`;
   in a non-repo it re-runs on every chat turn.
3. `cat` the copied `.claude/settings.json` back to you **unmodified**, so we both see that
   `extraKnownMarketplaces` and `enabledPlugins` are present and untouched.
4. A snapshot of `known_marketplaces.json`, `installed_plugins.json` and `ls ~/.claude/plugins/data`
   **before** you open the window, saved to the scratchpad. §3 diffs against it.

No `.gitignore` for `.claude/skills/`, no `jq` surgery on the settings file, no symlink. If you see
me about to create one, stop me: that would test the mechanism we already proved twice.

**What you should see:** four `create` lines, then a settings.json printed with all three blocks
intact (`permissions`, `extraKnownMarketplaces`, `enabledPlugins`), then a short "before" snapshot.

---

## 3. The pin test — you drive, I read the disk after

### 3a. What you do

1. Open Window 2 on `~/dev/scratch-pin` (File → New Window → Open Folder).
2. Start a **new** Claude Code session in the extension's chat box. Do not continue an old one.
3. **Watch the first ten seconds.** This is the part no session can observe for you, and the step
   prompt asks for it specifically. Note, and tell me:
   - Does a **trust prompt** appear for the `factory` marketplace, or for the workspace, or both?
     Trust prompts are the most likely place for this to silently not-happen — an unanswered dialog
     behind another window looks exactly like a pin that didn't resolve.
   - Does it **fetch silently**, with no UI at all?
   - **How long** until the session is usable — instant, or a visible pause while it clones?
   - Any error or warning text, even one that scrolls past. Paste it verbatim rather than
     summarising; Step 4's "workspace not trusted" turned out to mean nothing, and we only know
     that because the exact string was kept.
4. Type **`/plugin`** in that window and paste back what you see.

**Expected:** `factory-lite@factory`, enabled, version `3.0.1`, sourced from the `factory`
marketplace. No marketplace-add, no install step, because `settings.json` asked for it.

**Also expected, and not a defect:** Superpowers will **not** be there. It was installed at
*project* scope against `~/dev/scratch-super`, a folder that no longer exists. A fresh project does
not inherit it. That absence is precisely the subject of §6 — don't fix it by hand in Window 2.

5. While you have the window open, type **`/hooks`** and paste that too. Expect the harness's one
   `Stop` hook plus the three user-scope `notify.js` notifiers that live on this machine. What
   matters is that the Stop gate is listed **as coming from `factory-lite@factory`** and not from
   `@skills-dir` — that is the whole point of the step, visible in one line.

### 3b. What I do, once you've pasted

I read the disk and diff it against the "before" snapshot:

- `~/.claude/plugins/known_marketplaces.json` — did `factory` get added, and with what
  `installLocation` and `lastUpdated`?
- `~/.claude/plugins/marketplaces/factory/` — does it exist, and **is it a git checkout or a
  tarball?** If `.git` is present: `git -C … rev-parse HEAD`, `git -C … rev-parse --abbrev-ref HEAD`,
  `git -C … describe --tags`. If instead there's a `.gcs-sha`, I say so and fall back to file
  presence.
- **The discriminator, which works either way:** does
  `~/.claude/plugins/marketplaces/factory/docs/step-6-prompt.md` exist?
  - **Present → the project is tracking `main` (`c863951`).** Every push ships. The tag is
    decoration.
  - **Absent → it resolved the tag (`5581d67`).** Then the tag is load-bearing and the release rule
    is doing real work.
- `~/.claude/plugins/installed_plugins.json` — a new `factory-lite@factory` entry, its `scope`,
  `installPath`, `version`, and whether it carries a `gitCommitSha` the way superpowers does.
- `ls ~/.claude/plugins/data/` — the expected new sibling next to `factory-lite-skills-dir`.
- The cache path itself. Superpowers caches under a **version-named directory**
  (`…/superpowers/6.3.0`). If ours lands at `…/factory/factory-lite/3.0.1` *and* tracks `main`, then
  there's a third finding to record: **content can drift under a fixed version number**, and a cache
  keyed on a version that didn't change may not refresh on the next push. I'll test that by checking
  whether the cached tree matches `main`'s HEAD rather than trusting the directory name.

### 3c. The finding gets written down plainly

Whichever way it lands, one paragraph into `LESSONS.md` under the harness-interface lessons, in the
step prompt's own words if it's the `main` case: *projects track `main`, every push ships, and the
tag is decoration.* No hedging. If it tracks `main`, that is a real property of the shipping
mechanism and Step 7's first real project inherits it.

---

## 4. If the pin does not resolve

The fallback: **Customize → Plugins → add marketplace `drewwoodruff741/factory-lite` → install
`factory-lite`, project scope.**

Use it to unblock yourself, then treat it as a **defect in the pin, not a workaround to accept**.
The order matters: get the fallback working first so we learn whether the repo and marketplace
manifest are fine and only the *auto-resolution* is broken, or whether something deeper is wrong.

Likely causes, cheapest first, and each is a scaffold fix in `~/dev/factory-lite`:
- The `source` nesting in `extraKnownMarketplaces` is wrong. Compare against the live
  `known_marketplaces.json` entry for `claude-plugins-official`, which is the known-good shape.
- `"source": "./"` in `marketplace.json` doesn't resolve from a `github`-sourced marketplace. The
  README already records that `"./"` beats `"."` and that relative sources only resolve for git-added
  marketplaces; if `github` is not "git-added" for this purpose, the fix is an explicit source for
  the plugin entry.
- The marketplace resolves but the plugin doesn't auto-enable, i.e. `enabledPlugins` needs the
  plugin already installed rather than installing it on demand.

Any fix follows §5's rule against itself — smoke test, all four validate calls, both manifests
bumped, tag, push — and then §3 is **re-run from a fresh scratch folder**, because a project that
already has a warm cache is not testing a cold pin any more.

---

## 5. The release rule → top of BACKLOG.md

Pasted above `## Environment chores`, as its own section, in full. Not a shortened version —
Steps 3, 4 and 5 each found a piece a short version omits:

1. `bash scripts/harness-smoke.sh` → `harness smoke: PASS`
2. **All four validate calls.** `claude plugin validate .` here checks only the *marketplace*
   manifest — the repo root holds both manifests and the marketplace wins. The plugin manifest and
   the components need their own calls:
   `claude plugin validate .claude-plugin/plugin.json --strict`,
   `claude plugin validate skills --strict`, `claude plugin validate agents --strict`.
3. **Bump `version` in BOTH** `.claude-plugin/plugin.json` **and** `.claude-plugin/marketplace.json`
   (the latter under `metadata.version`). Bumping one leaves the two disagreeing about what the
   release is.
4. `git commit`, `git tag vX.Y.Z`, `git push && git push --tags`.
5. Projects update via **Customize → Plugins** (or `claude plugin update factory-lite@factory`).

Plus a short note underneath, written after §3 lands, recording **what the tag actually does** —
because if projects track `main`, then steps 3 and 4 protect a version number that nothing resolves,
and anyone reading the rule later deserves to know that in the same place they read the rule. It
stays a note rather than a sixth item: the five steps are the rule, and all five still apply.

---

## 6. Superpowers in the template — my recommendation, then your call

**My recommendation: yes, pin it.** Argument on both sides first.

**For pinning:**
- The stack you wrote down already says *two pinned plugins*. A template that pins one of them
  leaves the stack half-installed, and the gap is filled by remembering a UI ritual.
- The ritual is needed at exactly the worst moment. Superpowers earns its keep in **brainstorming**,
  which happens in the first ten minutes of a project — before you have any reason to think about
  plugin management, and while you are thinking hard about something else.
- Step 5's actual finding leans on it. `superpowers:brainstorming` wrote a better `SPEC.md` than
  `/factory-lite:spec`, unprompted. BACKLOG item 2 contemplates **deleting `spec` in favour of it**.
  That deletion is only safe if Superpowers is present by default — otherwise a fresh project gets
  neither the skill nor its replacement.
- The cost is settled and small: ~2.1k, about 0.2% of a 1M window, against v2's ~10.5k.
- It costs nothing to install. The plugin is already cached machine-wide at
  `…/cache/claude-plugins-official/superpowers/6.3.0`, pinned to sha `b36e082`. A template pin flips
  a per-project enable; there is no re-download.
- The third-party-dependency worry is smaller than it looks. The official marketplace pins
  superpowers to an **explicit sha** (I confirmed this on disk). A project pinned through
  `claude-plugins-official` floats on *Anthropic's* update cadence, not on `obra/superpowers` `main`.

**Against pinning:**
- Every project pays ~2.1k whether or not it ever brainstorms, and the bootstrap is re-injected on
  **every `/clear`** — so it is paid per context, not per project.
- A hardening-phase project that has long since written its SPEC gets no value from the 2.1k and
  cannot stop paying it without editing settings, which is the same UI ritual in reverse.
- "Keep the template small" is the template's stated job. Two pins is still small, but the direction
  of travel is the thing the whole rebuild exists to resist.
- Opting in is genuinely one click, and an opt-in that you skip is evidence you didn't need it.

The "against" case is real but it is a **0.2% tax on projects that don't brainstorm**, against a
**silent capability gap on projects that do**. Those aren't symmetric. Pin it.

**If you say yes, the edit is not one line — it's two**, and this is the part worth being exact
about. `enabledPlugins` alone would work *on this machine only*, because `claude-plugins-official`
already sits in `known_marketplaces.json` here. A template that only enables the plugin is a
template that silently fails on any other machine. So the template gets both:

```json
"extraKnownMarketplaces": {
  "factory":  { "source": { "source": "github", "repo": "drewwoodruff741/factory-lite" } },
  "claude-plugins-official": { "source": { "source": "github", "repo": "anthropics/claude-plugins-official" } }
},
"enabledPlugins": {
  "factory-lite@factory": true,
  "superpowers@claude-plugins-official": true
}
```

---

## 7. If §6 is yes: the release rule's first live test

This is the nice part of the step — the rule gets exercised on a real change, immediately, by the
same session that wrote it. In order, all of it, no skipping the parts that feel redundant:

1. Edit `template/.claude/settings.json` as above.
2. `bash scripts/harness-smoke.sh` → `harness smoke: PASS`. Note that smoke check 6 validates that
   file as JSON, so a malformed edit fails here rather than in a project.
3. All four validate calls.
4. **Bump both manifests to `3.1.0`** — minor, not patch: new projects get a capability they didn't
   get before, and that is a behaviour change, not a fix.
5. Commit, `git tag v3.1.0`, `git push && git push --tags`.
6. **Re-test from a second fresh folder** (`~/dev/scratch-pin2`), because that is the only way to see
   whether a project picks up `3.1.0` — and, given §3's finding, whether it picks it up from the tag
   or from `main`. You type `/plugin` again; expect both plugins enabled, factory-lite at `3.1.0`.
   If the cache serves a stale `3.0.1`, that is the version-named-cache-directory problem from §3b,
   and it goes in `LESSONS.md` as a property of the shipping mechanism.

If §6 is no: no version bump at all this step, per the guardrail. The step still finishes — the pin
is proved, the ref question is answered, the rule is written, and "opt in per project" is recorded
in `BACKLOG.md` as a deliberate decision with its date, so Step 7 doesn't reopen it.

---

## 8. Close out

1. **Delete the scratch projects** — `~/dev/scratch-pin`, and `~/dev/scratch-pin2` if §7 created it.
   Close Window 2 first, so the extension isn't holding a session on a folder that's going away.
2. Note that `installed_plugins.json` will now carry a `projectPath` to each deleted folder, the way
   it already does for `scratch-super`. Harmless, same as before, and worth one line in `LESSONS.md`
   only if it accumulates into something that misleads a later reading of that file.
3. `LESSONS.md` gets the §3 finding (which ref ships, and how the two cache layers behave) and, if
   §7 ran, whether a project actually picked up `3.1.0`.
4. `BACKLOG.md` gets the release rule at the top, plus the §6 decision recorded either way.
5. `START-HERE.md`: tick Step 6, and if §3 found that projects track `main`, add that one sentence
   to Step 7's "bring to the session" note — Step 7 is the first real project and should know that
   every push to the harness reaches it.
6. Commit from Window 1. Nothing in this step is committed from Window 2.

**What this step must not leave behind:** a scratch folder, a symlink, a hand-edited
`.claude/settings.json` in a test project, or a version bump that wasn't earned by a scaffold change.

---

## What actually happened (appended after execution, 2026-09-12)

§3's prediction was right and §4 was the path taken.

- **The pin did not resolve.** Marketplace registered, repo cloned, plugin cached, in-use marker
  written — and no install record, so no plugin and no gate. A second fresh session did not help.
  `enabledPlugins` enables an already-installed plugin; it does not install one.
- **The CLI doesn't read the settings file either.** `claude plugin marketplace update factory`
  failed with "not found" while the key sat in the project's `settings.json`, so the fix needed
  `marketplace add --scope project` *and* `install --scope project`, both from `init.sh`.
- **The ref question is answered: projects get `main`.** Shallow depth-1 clone of the default
  branch; tags never fetched. Four confirmations, recorded in `LESSONS.md` and in the release rule.
- **The Superpowers decision was yes**, and the defect changed its implementation: a settings key
  alone would have failed the same silent way, so `init.sh` installs it too.
- **The release rule caught a bug on its first execution.** Making `init.sh` install plugins made
  `harness-smoke.sh` — which runs `init.sh` against a `$TMPDIR` project — write install records for
  a directory it then deleted. `FACTORY_SKIP_PLUGIN_INSTALL=1` now guards it and the smoke test
  asserts the guard. Found because the rule says run the smoke test *before* committing.

Released as **v3.1.0**. Scratch projects `scratch-pin`, `scratch-pin2`, `scratch-pin3` deleted.
