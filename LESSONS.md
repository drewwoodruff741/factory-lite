# LESSONS (from FACTORY v2)

The only thing carried over from v2. Evidence, not code. Each line here is the reason a
component in v3 exists or the reason one will never be added. Fill it from memory in one
sitting; if you can't remember a rule, it wasn't load-bearing.

## Startup cost of v2 (for comparison)
Measured 2026-09-11 in `devFinanceBot`, the most active v2 project, fresh session, claude 2.1.269.
- `/context` total: **46.8k / 1.0M (5%)** — of which 4.0k was the conversation itself, so
  **startup ≈ 42.8k**, i.e. **~10.5k above the 32.3k empty-folder floor**.
- Where the 10.5k went: `CLAUDE.md` 5.1k · three always-on `.claude/rules/` files 4.3k
  (`finance-invariants` 2.7k, `git-safety` 943, `proof-integrity` 682) · five custom agents 1.3k
  (`doubter`, `lead`, `implementer`, `planner`, `tester`).
- **The headline finding: v2 did not bite by eating the context window.** 10.5k is cheap. It bit
  through *behaviour* — five job-title agents, three always-on rules, and a proof suite that never
  fired correctly. **Cheapness is why they survived**: nothing ever made them expensive enough to
  question. So v3 cannot declare victory on the `/context` number alone; the comparison in Steps 4
  and 5 is necessary but not sufficient.

## Empty-folder baseline (v3 measuring stick, 2026-09-11)
Fresh session in an empty git folder, no plugins, no CLAUDE.md, claude 2.1.269, opus-5 1M window.
This is the floor: anything above it is something we chose to load.
- **Total 32.3k / 1.0M (3%)** — system prompt 4.2k · system tools 25.4k · skills 2.8k
- Read it as: the harness budget is what a project adds *on top of 32.3k*, not the raw number.
- **The 15%-of-window rule in START-HERE Step 5 does not survive a 1M window** (15% = 150k, which
  no sane harness reaches). Judge startup cost in absolute tokens against this baseline instead.

## Startup cost of v3 (Step 4, 2026-09-12)
Fresh session in `~/dev/scratch-hello`, the template's four files plus factory-lite loaded as
`factory-lite@skills-dir`, claude 2.1.269, opus-5 1M window.
- `/context` total **34.7k / 1.0M (3%)**, of which Messages was 8 tokens — so **startup ≈ 34.7k**,
  i.e. **+2.4k above the 32.3k empty-folder floor**, against v2's ~10.5k. Under target.
- Where the 2.4k sits: custom agents 156 (`reviewer` 89 + `explorer` 67) · memory files 300
  (the template `CLAUDE.md`) · skills 2.8k → 2.9k (~100) · **system tools 25.4k → 27.3k (+1.9k),
  unexplained and almost certainly not ours** — no plugin here defines a tool.
- So the harness's own share is ~560 tok, not 2.4k. `claude plugin details factory-lite`
  independently projects **~377 tok always-on** for the plugin, which agrees with the 156 + ~100
  measured above; the template `CLAUDE.md`'s 300 is the rest. Even crediting the whole 2.4k to
  v3, it costs **under a quarter of v2** while shipping four skills, two agents and one hook
  against v2's five agents and three always-on rules.
- **SPEC.md does not load at startup** — only `CLAUDE.md` appears under Memory files. The spec is
  read on demand, which is why the 60-line `CLAUDE.md` budget is the one that matters.
- Restating Step 2's headline so this number is not misread: v2's damage was **behavioural, not
  contextual**. 2.4k vs 10.5k is necessary, not sufficient. The gate test in the same step is what
  actually tests behaviour.

## The gate, observed live (Step 4, 2026-09-12)
Everything below was watched in the extension, in `~/dev/scratch-hello`, at v3.0.0.
- **The gate blocks and releases as designed.** A real premature stop — tree edited to break the
  skeleton, `prove.sh` red — was blocked three times running, then the 3-strike loop guard handed
  control back with `FACTORY gate: ./prove.sh still failing after 3 attempts.` A clean tree passed
  and stopped silently. Both exits from the gate are real, and the state-hash skip kept chat-only
  turns free.
- **It held under pressure, which is the part that matters.** With the gate red and a human
  instruction to "leave it broken", the session had two cheap outs — revert the edit, or edit
  SPEC.md so `goodbye` became legal — and refused both, naming the second as "weakening the
  contract by the back door". It escalated instead. At hardening it mutation-tested its own gate
  (8 mutants, all caught), negative-tested every new check before trusting it, caught a real lint
  error in its own test helper and fixed it rather than silencing the rule, chose stdlib
  `unittest` over available `pytest` because SPEC.md forbids an install step, and refused to fake
  the typecheck it had no tool for. **This is the v2 failure mode not happening.** The 2.4k
  startup number proved nothing; this does.
- **Defect found and fixed (v3.0.1): the gate blocked the first turn of a fresh project.** The
  template `prove.sh` exits 1 by design, so the Stop gate fired on the `/factory-lite:spec` turn —
  whose own rule is "write no code". The session's diagnosis was exact: *"the Stop gate runs
  unconditionally, but CLAUDE.md scopes verify to 'before stopping after a code change'…
  `/factory-lite:spec` cannot terminate cleanly on a fresh project by construction."* Fix: the
  gate is **dormant** while `prove.sh` still holds the template's TODO sentinel, announcing that
  it is dormant on each stop, and arms itself the moment a real check replaces it. `harness-smoke.sh`
  test 1 had encoded the old contract (placeholder → block) and was inverted, with a new 1b
  asserting a *real* failing check still exits 2.
- **Two wording traps in `skills/harden/SKILL.md`, fixed.** Step 3 said to change `PROFILE=lite`,
  a literal string that does not exist in the template (`PROFILE="${HARNESS_PROFILE:-lite}"`); the
  model resolved it correctly anyway, but the trap was real. Step 5 demanded a typecheck
  unconditionally, forcing a choice between faking a check and deviating from the checklist on a
  machine with no type checker. It now asks only for the checks the stack actually has and says to
  record an unavailable one as deferred.
- **A slash command typed in the wrong window reads as a harness bug.** `Unknown command:
  /factory-lite:harden` came from the window open on the *harness repo*, which has no
  `.claude/skills` symlink and therefore no plugin. Check which folder the session is rooted in
  before concluding a command does not register.

## What bit us
Format: what happened → what it cost → what it taught.
- **Over-engineering by accretion.** v2 was built for one specific task, branched into a factory,
  and then had efficiencies and hardening layered on top — a sandbox, an excessive number of
  proofs, a model that hallucinated problems to solve. Each addition sounded great on paper; the
  sum was a cumbersome mess. → It cost time and tokens on **every single prompt**, and eventually
  the output could no longer be trusted. → Harness overhead is charged per prompt, not once, and
  the first thing it buys is distrust. A component that is merely defensible is not worth its
  per-prompt rent.
- **The model editorialized instead of finishing.** Every output read "I did this, and also fixed
  this because I noticed that, and I suggest this instead, and I noticed three things over here,
  so now let me pivot to those" — instead of "I did it." → Time, tokens, trust. → The same three
  every time. A turn that ends in a pivot proposal is a turn you have to audit before you can use
  it.

## What we kept trying to add and never used
- **Rules and hooks.** Added steadily across v2's life. **I could not name one of them if asked**
  — which is the whole test: a rule you cannot recall was never load-bearing, it was just resident.
- **Tests that wouldn't fire correctly.** A body of proofs existed, didn't run right, and was never
  fixed — so the harness carried the cost of having tests and none of the confidence.
- **Nothing from v2 is recitable from memory.** Asked directly at the freeze, not one rule, hook,
  or skill could be recalled unprompted. v2 was archived without excavating them on purpose: the
  only rules worth carrying to v3 are the ones that were still in my head.

## Things that were actually project-specific and lived in the harness by mistake
- **The harness itself.** v2 was project-specific *by origin* — built for one task, then branched
  into a general factory without ever re-examining what should have stayed behind with the
  original job. No individual piece can be named as the culprit, because the boundary was never
  drawn. → In v3, a component enters FACTORY only with evidence from a shipped project, and
  anything that smells like one project's need lives in that project.

## From building v3 itself
Findings from the build steps, not from v2. Kept here because they are evidence the later steps
depend on.
- **Step 1:** the WSL machine settings (`~/.vscode-server/data/Machine/settings.json`) had
  `claudeCode.initialPermissionMode: bypassPermissions` — every session started with permissions
  bypassed. Removed. It taught: check the *machine* settings, not just project settings, before
  trusting what Step 4 shows you about the Stop gate.
- **Step 1:** the step-1 sub-guide initially asked for `npm`, which is not in the stack. Ubuntu
  26.04 ships `nodejs` without it, and `pnpm` is per-project via corepack. It taught: the drift the
  Context block blocks also arrives inside the sub-guides, not only from the sessions that use them.
- **Step 3:** `claude plugin validate .` on this repo validates **only the marketplace manifest**,
  because the root holds both manifests and the marketplace wins. The plugin manifest and the
  components need their own calls: `claude plugin validate .claude-plugin/plugin.json --strict`,
  `... validate skills --strict`, `... validate agents --strict`. It taught: one green "Validation
  passed" is not proof that everything in a dual-role repo was checked — read *which* file it
  names on the first line.
- **Step 3:** `claude plugin details <name>` works only on an **installed** plugin. Its own error
  message suggests `--plugin-dir <path>`, but that option does not exist on the `details`
  subcommand (`error: unknown option '--plugin-dir'`). **Superseded in Step 4:** it works fine on a
  skills-dir plugin, so a pre-`/context` token read does exist — see the trust finding below.
- **Step 4:** the **CLI and the extension keep separate trust records.** Extension sessions ran
  freely in `~/dev/factory-lite` and `~/dev/scratch-hello` with no dialog while `~/.claude.json`
  had no `.projects` entry for either. Until the folder is trusted on the CLI side, every
  `claude plugin …` call there prints "skipped because this workspace was not trusted when plugins
  were scanned" — a statement about the CLI's own store, not about what the session loaded. It
  taught: **do not infer a capability is missing from a CLI error raised in an untrusted folder.**
  Both "skills-dir plugins never enter the registry" and "`details` doesn't work here" were
  concluded from that state and both were wrong; once trusted, `plugin list` reports
  `Status: ✔ loaded` and `plugin details` prints the full inventory and token projection.
- **Step 4:** permissions are disarmed machine-wide by **two** mechanisms in
  `~/.claude/settings.json`: `permissions.defaultMode: "auto"`, and a `PreToolUse` hook
  (`~/.claude/hooks/auto-accept-hook.sh`, matcher `""` = all tools, flagged
  `_autoAcceptManaged: true`) whose script does no filtering at all — it ignores its input and
  returns `permissionDecision: allow` for every call. Found via `/hooks` in the scratch project,
  which listed 5 hooks: that one, three `notify.js` notifier hooks, and factory-lite's Stop gate.
  Two consequences. First, **the permissions block in `template/.claude/settings.json` is
  decorative on this machine** — every project init.sh creates ships an allowlist that can never be
  consulted. Second, **no permission configuration anywhere can be observed or tested while this is
  on**, which is why the question of whether a parent directory's `.claude/settings.local.json`
  reaches a child project could not be answered in Step 4. It is the same class of finding as
  Step 1's `bypassPermissions`, by a different route: **the environment silently disarms the safety
  the harness assumes, and re-disarms it after you fix it once.**
- **Step 4:** `claude <unrecognized-subcommand>` is **treated as a prompt**, not rejected —
  `claude config list` (no such subcommand in 2.1.269) started a headless session and answered the
  words as a question. Only verified subcommands print and exit. Do not guess at them.
