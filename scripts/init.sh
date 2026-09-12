#!/usr/bin/env bash
# Bootstrap a new project from FACTORY-lite.
# Copies only the per-project files a plugin can't ship: CLAUDE.md, SPEC.md, prove.sh, .claude/settings.json.
# Usage: /path/to/factory/scripts/init.sh [target-dir]   (default: current directory)
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dest="${1:-.}"
mkdir -p "$dest/.claude"

copy() {  # $1 = relative path
  if [ -e "$dest/$1" ]; then echo "skip   $1 (exists)"; return; fi
  mkdir -p "$(dirname "$dest/$1")"
  cp "$here/template/$1" "$dest/$1"
  echo "create $1"
}
copy CLAUDE.md
copy SPEC.md
copy prove.sh
copy .claude/settings.json

sed -i.bak 's/\r$//' "$dest/prove.sh" && rm -f "$dest/prove.sh.bak"   # CRLF safety for Windows checkouts
chmod +x "$dest/prove.sh"

# The pin in template/.claude/settings.json ENABLES these plugins but does not INSTALL them.
# Step 6: enabledPlugins is an enable flag for an already-installed plugin, and
# extraKnownMarketplaces only registers and caches the marketplace -- three of the four things a
# session needs. The CLI does not read extraKnownMarketplaces out of the settings file at all, so
# each marketplace also needs an explicit add. Without these calls a project gets no plugin and no
# Stop gate, silently, on every session. They print and exit; none opens the terminal UI.
# --scope project re-declares the keys the template already carries, leaving user settings clean.
# Delete when: a Claude Code release installs plugins named in enabledPlugins on its own.
# FACTORY_SKIP_PLUGIN_INSTALL=1 suppresses all of it. harness-smoke.sh sets it: the smoke test
# builds a throwaway project in $TMPDIR, and without the guard every run writes install records
# pointing at a temp dir that is deleted seconds later.
if [ -n "${FACTORY_SKIP_PLUGIN_INSTALL:-}" ]; then
  echo "skip   plugin install (FACTORY_SKIP_PLUGIN_INSTALL set)"
elif command -v claude >/dev/null 2>&1; then
  (
    cd "$dest"
    claude plugin marketplace add drewwoodruff741/factory-lite --scope project \
      && claude plugin install factory-lite@factory --scope project \
      || echo "warn: factory-lite install failed; add it from Customize -> Plugins (marketplace drewwoodruff741/factory-lite)." >&2
    # Superpowers is the other half of the stack: brainstorming, TDD, systematic debugging.
    # Non-fatal on purpose -- a project without it still has the gate, and the gate is the part
    # that must not be optional.
    claude plugin marketplace add anthropics/claude-plugins-official --scope project \
      && claude plugin install superpowers@claude-plugins-official --scope project \
      || echo "warn: superpowers install failed; add it from Customize -> Plugins." >&2
  )
else
  echo "warn: 'claude' not on PATH; install factory-lite@factory and superpowers@claude-plugins-official from Customize -> Plugins." >&2
fi

cat <<EOF

Next:
  open $dest in VS Code and start a session   # never 'claude' on its own
  /factory-lite:spec <one-line idea>      # interview -> SPEC.md, no code
  (new session)                           # implement the walking skeleton until ./prove.sh passes
  /factory-lite:harden                    # graduate; deliberate engineering starts here
EOF
