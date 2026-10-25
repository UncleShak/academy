#!/usr/bin/env bash
# Installs the Academy agents into the current project, or into ~/.claude with --global.
# Re-run to update. Safe to run more than once.
set -euo pipefail

REPO="${ACADEMY_REPO:-YOUR-USER/academy}"
REF="${ACADEMY_REF:-main}"
AGENTS="aristotle diogenes thales socrates"

if [ "${1:-}" = "--global" ]; then
  scope=global; base="$HOME/.claude"; memory="$base/CLAUDE.md"; import="@~/.claude/academy.md"
else
  scope=project; base=".claude"; memory="CLAUDE.md"; import="@.claude/academy.md"
fi

# Copy from a local clone if run from one, otherwise download from GitHub.
src_dir=""
script="${BASH_SOURCE[0]:-}"
if [ -n "$script" ] && [ -f "$script" ] && [ -f "$(dirname "$script")/academy.md" ]; then
  src_dir="$(cd "$(dirname "$script")" && pwd)"
fi
fetch() {
  if [ -n "$src_dir" ]; then cp "$src_dir/$1" "$2"
  else curl -fsSL "https://raw.githubusercontent.com/$REPO/$REF/$1" -o "$2"; fi
}
add_line_once() { # file, line
  touch "$1"
  grep -qxF "$2" "$1" && return 0
  if [ -s "$1" ] && [ -n "$(tail -c1 "$1")" ]; then printf '\n' >> "$1"; fi
  printf '%s\n' "$2" >> "$1"
}

mkdir -p "$base/agents"
for a in $AGENTS; do fetch "agents/$a.md" "$base/agents/$a.md"; done
fetch academy.md "$base/academy.md"

# Claude Code reads CLAUDE.md, not AGENTS.md; import both.
if [ "$scope" = project ] && [ ! -f "$memory" ] && [ -f AGENTS.md ]; then add_line_once "$memory" "@AGENTS.md"; fi
add_line_once "$memory" "$import"

# Keep the noticeboard out of git.
if [ "$scope" = project ] && { [ -d .git ] || [ -f .gitignore ]; }; then add_line_once .gitignore ".claude/agora.md"; fi

echo "Academy installed ($scope): $AGENTS"
echo "Start Claude Code as Plato with: claude --model opus"
