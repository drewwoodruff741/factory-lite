# Step 1 — Environment ready (≈ 30 min)

**Goal:** a WSL2 Ubuntu machine where every tool in the stack exists and the Claude Code VS Code
extension talks to it.

**Done when:** every check in §7 passes and a throwaway folder's `/context` output shows a
`/home/...` path.

**Rules for this step**
- Everything happens inside VS Code: the integrated terminal (bash, WSL) or the extension's chat box.
- Shell commands are plain one-offs pasted into the integrated terminal. Never run `claude` on its
  own (that opens the terminal UI). `claude --version` and `claude --help` are fine — they print
  and exit.
- No global installs beyond: git, bash, jq, gh, Node LTS. No dotfile frameworks (no oh-my-zsh, no
  starship, no shell plugin managers).
- Anything you find broken in the scaffold gets fixed in `~/dev/factory-lite` and logged as one
  line in `BACKLOG.md` or `LESSONS.md` — never patched in a test project.

Already verified in Step 0, do not redo: jq 1.8.1 installed, global git identity set,
`scripts/harness-smoke.sh` passes, repo initialized with one commit.

---

## 1. Confirm VS Code is really on the WSL side

1. Look at the **bottom-left corner** of the VS Code window.
   - **You should see:** a green/blue remote indicator reading **`WSL: Ubuntu`** (or your distro
     name). If it is blank, or says anything else, you are in a Windows-side window — close it and
     reopen via the Command Palette (`Ctrl+Shift+P`) → **WSL: Reopen Folder in WSL**.
2. Open the integrated terminal: `` Ctrl+` `` (backtick).
3. Confirm the terminal is bash in WSL and the project lives on the Linux filesystem:

```bash
echo "shell=$SHELL"; uname -r; pwd; echo "wsl_distro=$WSL_DISTRO_NAME"
```

- **You should see:** `shell=/bin/bash`, a kernel ending in `-microsoft-standard-WSL2`, a `pwd` of
  `/home/drew/dev/factory-lite`, and a non-empty `wsl_distro`.
- **Red flag:** a `pwd` starting with `/mnt/c`. Execute bits and line endings misbehave there; the
  scaffold must stay under `~/dev`.

---

## 2. Line-ending safety (do this before installing anything)

`hooks/stop-gate.sh` and `prove.sh` are bash. A CRLF line ending makes them fail with a confusing
`bad interpreter` error, and the README already lists this as the first thing to check when "the
gate never fires". Two belts:

**a. Git, globally, in WSL:**

```bash
git config --global core.autocrlf input
git config --global core.eol lf
git config --global --get-regexp 'core\.(autocrlf|eol)'
```

- **You should see:** `core.autocrlf input` and `core.eol lf`, one per line.
- `input` (not `true`) is the WSL-correct value: never write CRLF into the working tree, and strip
  any CRLF on commit.
- **Status: done.** Neither key was set before; both are set now. Global git identity was already
  `Drew <drewwoodruff741@gmail.com>` from Step 0.

**b. VS Code's editor, so files you create here are LF:**

Put this in the **WSL machine** settings, not User settings. On Remote-WSL your User settings live
on the *Windows* side; machine settings live in the distro and apply to every folder you open in
WSL — which is exactly the scope you want for a line-ending rule:

```bash
cat ~/.vscode-server/data/Machine/settings.json
```

```json
{
    "files.eol": "\n"
}
```

- **Status: done.** The file now contains exactly that. (Command Palette →
  **Preferences: Open Remote Settings (JSON) [WSL: Ubuntu]** opens the same file from the UI.)
- **You should see:** the bottom-right status bar read **LF** (not CRLF) when a file is open.
  Click that indicator to convert any file that shows CRLF.

**c. Check the scaffold is clean right now:**

```bash
cd ~/dev/factory-lite
file hooks/stop-gate.sh scripts/*.sh template/prove.sh
ls -l hooks/stop-gate.sh scripts/*.sh template/prove.sh | awk '{print $1, $NF}'
```

- **You should see:** `Bourne-Again shell script, ASCII text executable` with **no** mention of
  `CRLF line terminators`, and permissions beginning `-rwxr-xr-x` on all four.
- **Status: verified clean.** All four are LF and `-rwxr-xr-x`. A `.gitattributes` was added to the
  scaffold in this step so they stay that way on any machine that clones the repo, not just this
  one.
- **If any says CRLF** or is not executable, fix it in the scaffold now:
  ```bash
  sed -i 's/\r$//' hooks/stop-gate.sh scripts/*.sh template/prove.sh
  chmod +x hooks/*.sh scripts/*.sh template/prove.sh
  bash scripts/harness-smoke.sh   # expect: harness smoke: PASS
  ```
  and tell me — I will add one line to `LESSONS.md` recording that it happened, since it is
  evidence about the scaffold, not about your machine.

---

## 3. The tool checks

Paste this whole block into the integrated terminal. It prints one line per tool and never
installs anything.

```bash
for t in git bash jq gh node; do
  printf '%-6s %s\n' "$t" "$(command -v "$t" || echo 'MISSING')"
done
echo "---"
git --version
bash --version | head -1
jq --version
gh --version | head -1
node --version
```

**You should see** (versions may differ; these are the floors that matter):

| Tool | Expect | Actual on this machine | If MISSING |
|---|---|---|---|
| `git` | 2.34+ | `2.53.0` ✅ | `sudo apt update && sudo apt install -y git` |
| `bash` | 5.x | `5.3.9` ✅ | already present on Ubuntu; do not replace it |
| `jq` | 1.7+ | `jq-1.8.1` ✅ | already verified in Step 0 |
| `gh` | 2.x | *install in §4* | see §4 |
| `node` | **an LTS, even major** | `v22.22.1` ✅ | see §5 |

An **odd** major for Node (v21, v23) is not LTS — replace it per §5.

**`npm` is deliberately not on this list.** Ubuntu 26.04 packages `nodejs` with `corepack` but
without `npm`, and the stack asks for `pnpm` per-project, not npm globally. When a TypeScript
project needs it in Step 7, `corepack enable pnpm` provides it inside that project — no global
install, no guardrail broken. Do not `apt install npm`: its candidate is 9.2.0, a major version
behind what Node 22 expects.

---

## 4. `gh` installed and logged in

`gh` was MISSING. Ubuntu 26.04's own `universe` repo carries **gh 2.46.0**, which does everything
this stack needs (`gh auth login`, `gh repo create --source=. --push`, `gh api`). One package, no
third-party apt source, nothing to maintain:

```bash
sudo apt update && sudo apt install -y gh
```

- **You should see:** apt install `gh` and finish without errors, then `gh --version` reports
  `gh version 2.46.0`.

*(If a later step ever needs a `gh` feature newer than 2.46, add GitHub's own apt repo then — with
a line in `BACKLOG.md` saying which feature forced it. Not before.)*

Then log in (Step 3 needs this for `gh repo create --source=. --push`):

```bash
gh auth status || gh auth login
```

`gh auth login` is interactive: choose **GitHub.com** → **HTTPS** → **Yes**, authenticate Git with
your GitHub credentials → **Login with a web browser** → copy the one-time code, press Enter, and
finish in the browser that opens on the Windows side.

Verify:

```bash
gh auth status
gh api user --jq .login
```

- **You should see:** `✓ Logged in to github.com account <your-user>`, a token line listing scopes
  including `repo` (and `read:org`), and your username printed on its own line.
- **Note the username** — Step 3/6 needs it, and
  [template/.claude/settings.json](template/.claude/settings.json#L14) currently pins
  `drewwoodruff741/factory-lite`. If `gh api user` prints a different login, that pin is wrong and
  gets fixed in Step 3 (not now).

---

## 5. Node LTS

> **Already satisfied on this machine.** `node v22.22.1` comes from Ubuntu 26.04's `nodejs`
> package (`22.22.1+dfsg+~cs22.19.15-1ubuntu1`) — an even/LTS major, installed by apt, on the
> Linux side. **Skip this section entirely.** Do not add nvm on top; two Node managers is exactly
> the kind of drift this plan exists to prevent. The rest of §5 is kept only as the recipe for a
> future machine.

Only if §3 showed Node MISSING or a non-LTS major. Use **nvm** — it is a single script plus three
lines in `~/.bashrc`, not a dotfile framework, and it keeps Node out of `sudo`'s way:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
exec bash -l
nvm install --lts
nvm alias default 'lts/*'
node --version && npm --version
```

- **You should see:** `Now using node v22.x.x`, then the version printed twice more.
- **Then open a brand-new terminal** (`` Ctrl+Shift+` ``) and run `node --version` again —
  **you should see** the same version. If the new terminal says "command not found", the nvm block
  did not land in `~/.bashrc`; tell me before going further.

If you would rather avoid nvm, NodeSource is the one-line alternative
(`curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && sudo apt install -y nodejs`).
Pick one; do not install both.

---

## 6. Claude Code: version, and the extension talking to WSL

**a. The CLI version, from the terminal:**

```bash
command -v claude && claude --version
```

- **You should see:** a path under `/home/drew/...` and a version string like `2.x.x (Claude Code)`.
- **Actual on this machine:** `/home/drew/.local/bin/claude` → `2.1.269 (Claude Code)` ✅ — Linux
  side, user-local, not shadowed by Windows. Nothing to do.
- **If `claude` is not on PATH:** that is not a failure — the VS Code extension can ship its own
  copy. Get the version from the extension instead (step 6c, `/status`) and note in the checklist
  that the CLI is extension-managed.
- **If the path starts with `/mnt/c`:** you are picking up a Windows-side install through PATH
  interop. That will bite the hooks later. Tell me and we will fix PATH resolution before Step 4.

**b. Extension is installed on the WSL side:** open the Extensions pane (`Ctrl+Shift+X`) and find
**Claude Code**.
- **You should see:** it listed under **"WSL: Ubuntu — Installed"**, not in a "Local — Installed"
  section with an "Install in WSL: Ubuntu" button. If you see that button, click it.

**c. The throwaway-folder test (this is the "Done when"):**

```bash
mkdir -p ~/dev/scratch-step1 && cd ~/dev/scratch-step1 && git init -q && code .
```

In the new VS Code window (check the bottom-left still reads `WSL: Ubuntu`), open the Claude Code
extension and start a **fresh** session. In the chat box type:

```
/context
```

> **Corrected while running this step.** Two surprises, both now folded into `START-HERE.md`:
> 1. The extension will not open a session in a folder with **no files in it**. Create a throwaway
>    file first (`touch placeholder.md`) or the window gives you nowhere to type.
> 2. `/context` on 2.1.269 prints **only the token table — no path line**. The original Done-when
>    ("`/context` shows a `/home/...` path") cannot be satisfied as written.

- **Instead, ask in the chat box:** `what is your working directory?`
- **You should see:** `/home/drew/dev/scratch-step1`. Anything containing `\`, `C:\`, or `/mnt/c`
  means the extension is running Windows-side — stop and fix that before Step 2.
- **From `/context`, note the total.** It is the "empty baseline" for the comparisons in Steps 4
  and 5.
- **Measured on this machine:** **32.3k / 1.0M (3%)** — system prompt 4.2k, system tools 25.4k,
  skills 2.8k. Recorded in `LESSONS.md`. Note that a 1M window makes percentage comparisons
  useless; judge later steps in absolute tokens above 32.3k.

Then run:

```
/doctor
```

- **You should see:** a health report with no red/error rows. Warnings about no plugins or no
  `CLAUDE.md` are expected in a throwaway folder — this folder has neither yet.

Leave `~/dev/scratch-step1` in place until the checklist is ticked; delete it at the end (§8).

---

## 7. Default model and permission mode (extension Customize menu)

Both are set from the chat box, not the terminal.

**Model.** **Nothing to do — verified in this step.** `/` → Customize on this extension build has
no model entry, and the account default is already **Opus 5**, which is what this build wants: the
method is judgment work (spec interviews, gap review, hardening), and
[agents/reviewer.md](agents/reviewer.md) declares opus for itself regardless.

- If you ever do need to change it mid-session, type `/model` directly in the chat box rather than
  hunting the Customize menu.
- Do **not** install anything or drop to the terminal for this. There is no model setting that
  Step 1 needs to write.

**Permission mode.** `/` → **Customize** → **Permissions** (typing `/permissions` opens the same
place). The per-session mode is the selector next to the chat box.

> ⚠️ **Found and fixed in this step.** `~/.vscode-server/data/Machine/settings.json` contained:
> ```json
> "claudeCode.allowDangerouslySkipPermissions": true,
> "claudeCode.initialPermissionMode": "bypassPermissions"
> ```
> Every WSL session starts with permissions bypassed. They were removed during this step and then
> **restored — bypass mode is the standing choice on this machine.** Recorded here so later steps
> are planned against the real setup:
>
> - **Step 4 still works.** The Stop hook fires regardless of permission mode, so you will still
>   watch the gate block a premature stop and release once `./prove.sh` passes. That is the part
>   that matters.
> - **What you give up** is the approval pause around the edits *leading up to* the stop. If
>   `prove.sh` is ever silently wrong, a finished turn is the first thing you'll notice.
> - **So the gate has to be genuinely trustworthy**, since it is the only checkpoint left. That
>   raises the stakes on Step 4's "watch it block with your own eyes" — don't take it on faith, and
>   don't weaken `prove.sh` later to make a turn end.

- **Choose:** the **default ask-first** mode. Do **not** set `acceptEdits` or any
  bypass/auto-approve mode as the default. The entire point of the Stop gate is that a turn ends
  only when `./prove.sh` passes; auto-approving edits removes the pause where you would notice it
  failing. Use **plan mode** deliberately when you want design without edits (Step 7 calls for it).
- **The right way to cut prompt noise** is the per-project allowlist, not a global bypass. If
  Steps 4–8 get click-heavy, widen
  [template/.claude/settings.json](template/.claude/settings.json#L2-L11) — and note which command
  forced it, so the allowlist stays evidence-driven like everything else here.
- Per-project allowlisting is how you cut prompts instead — the scaffold already ships the
  narrow allowlist in
  [template/.claude/settings.json](template/.claude/settings.json#L2-L11) (`./prove.sh`, and read/
  write-safe git commands). Nothing to add globally today.
- **You should see:** in a project that has the template settings, `/permissions` listing those six
  `Bash(...)` rules under a project scope. In the throwaway folder you will see an empty list —
  that is correct.

**Checked on this build (claude 2.1.269):** `/` → **Customize** has **no model entry**. The model
comes from the account default (Opus 5) and `/model` in the chat box overrides it per session.
Later steps that say "set X from Customize" should be read as "look for it there, and fall back to
typing the slash command" — the menu's contents vary by release.

---

## 8. Final checklist

Paste this in the integrated terminal for the machine half:

```bash
{
  echo "== step 1 checks =="
  printf 'wsl-kernel   : %s\n' "$(uname -r)"
  printf 'git          : %s\n' "$(git --version)"
  printf 'git identity : %s <%s>\n' "$(git config --global user.name)" "$(git config --global user.email)"
  printf 'git eol      : autocrlf=%s eol=%s\n' "$(git config --global core.autocrlf)" "$(git config --global core.eol)"
  printf 'bash         : %s\n' "$(bash --version | head -1)"
  printf 'jq           : %s\n' "$(jq --version)"
  printf 'gh           : %s\n' "$(gh --version | head -1)"
  printf 'gh auth      : %s\n' "$(gh auth status >/dev/null 2>&1 && gh api user --jq .login || echo 'NOT LOGGED IN')"
  printf 'node         : %s\n' "$(node --version)"
  printf 'claude cli   : %s\n' "$(command -v claude >/dev/null && claude --version || echo 'extension-managed')"
  printf 'perm mode    : %s\n' "$(grep -q 'bypassPermissions' ~/.vscode-server/data/Machine/settings.json 2>/dev/null && echo 'BYPASS -- fix per section 7' || echo 'ask-first')"
  printf 'scaffold     : %s\n' "$(cd ~/dev/factory-lite && bash scripts/harness-smoke.sh 2>&1 | tail -1)"
}
```

Tick each by hand:

- [x] `git` 2.53.0, identity `Drew <drewwoodruff741@gmail.com>`, `core.autocrlf=input`, `core.eol=lf`
- [x] No scaffold script reports CRLF; all four are `-rwxr-xr-x`; `.gitattributes` added
- [x] `files.eol: "\n"` set at WSL machine scope
- [x] `bash` 5.3.9, `jq` 1.8.1
- [x] `node` v22.22.1 (apt, LTS major) — npm intentionally absent, corepack covers pnpm per-project
- [x] `claude` 2.1.269 at `/home/drew/.local/bin/claude` — Linux side, not `/mnt/c`
- [x] Permission mode reviewed — `bypassPermissions` is the deliberate standing choice; Step 4's
      gate demo still valid, see §7
- [x] Bottom-left of VS Code reads `WSL: Ubuntu`; Claude Code running inside WSL
- [x] `gh` installed, logged in as **`drewwoodruff741`** — matches the pin in
      `template/.claude/settings.json`, so Step 3 has nothing to change there
- [x] Default model is **Opus 5** (account default; Customize has no model entry on this build)
- [x] Throwaway folder opens a session in the extension (needed one file to exist first)
- [x] Empty-folder baseline captured: **32.3k / 1.0M** → `LESSONS.md`
- [ ] Session in `~/dev/scratch-step1` answers `/home/drew/dev/scratch-step1` to
      "what is your working directory?" ← **the Done-when**
- [ ] `/doctor` clean apart from expected "no plugins / no CLAUDE.md" notes

Then clean up and close out:

```bash
rm -rf ~/dev/scratch-step1
cd ~/dev/factory-lite && git add -A && git commit -m "step 1 done"
```

Tick Step 1's box in `START-HERE.md`, close the session, and start Step 2 fresh.

---

## If something goes wrong

| Symptom | First thing to check |
|---|---|
| `/context` shows a `C:\` or `/mnt/c` path | VS Code window is Windows-side, or the extension is installed Local instead of WSL (§6b) |
| `claude` resolves under `/mnt/c` | Windows PATH interop is shadowing the Linux install (§6a) — report it, do not "fix" it with an alias |
| `node` works in one terminal, not a new one | the nvm block is missing from `~/.bashrc` (§5) |
| `gh auth login` browser never opens | finish it with `gh auth login --web` and paste the code into a Windows browser manually, or use a PAT via `gh auth login --with-token` |
| A scaffold script says "bad interpreter" | CRLF (§2c) — fix in the scaffold, re-run the smoke test, and log one line in `LESSONS.md` |
| The Customize menu has different labels | note them and tell me; the wording gets corrected here, not worked around |

## Guardrails honoured by this step

Installs are limited to `gh` and Node LTS (both in the stack). No hook, agent, rule, skill, or
plugin is added — Step 1 touches no file in `hooks/`, `skills/`, `agents/`, or `template/`. The
only persistent changes to your machine are two git config values, a VS Code `files.eol` setting,
and the two tools above.
