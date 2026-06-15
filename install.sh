#!/usr/bin/env bash
# Install the predicting-football-matches skill into your Claude Code skills dir.
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/skills/predicting-football-matches"
DEST_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
TARGET="$DEST_DIR/predicting-football-matches"

if [ ! -d "$SRC_DIR" ]; then
  echo "error: skill source not found at $SRC_DIR" >&2
  exit 1
fi

mkdir -p "$DEST_DIR"

if [ -e "$TARGET" ]; then
  printf 'Skill already exists at %s — overwrite? [y/N] ' "$TARGET"
  read -r reply
  case "$reply" in
    y|Y) rm -rf "$TARGET" ;;
    *) echo "Aborted."; exit 0 ;;
  esac
fi

cp -R "$SRC_DIR" "$TARGET"
echo "Installed skill -> $TARGET"
echo "Restart Claude Code (or open a new session) to load it."
