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

cat <<EOF

Next:
  cd $dest && claude
  /factory-lite:spec <one-line idea>      # interview -> SPEC.md, no code
  (new session)                           # implement the walking skeleton until ./prove.sh passes
  /factory-lite:harden                    # graduate; deliberate engineering starts here
EOF
