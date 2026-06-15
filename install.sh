#!/usr/bin/env bash
# Install the predicting-football-matches skill into a coding agent.
#
# Usage:
#   ./install.sh claude            -> ~/.claude/skills/            (Claude Code)
#   ./install.sh codex             -> ~/.agents/skills/            (OpenAI Codex CLI)
#   ./install.sh opencode          -> ~/.config/opencode/skills/   (OpenCode)
#   ./install.sh cursor            -> ./.cursor/rules/  (project-scoped, current dir)
#   ./install.sh cursor --project /path/to/project
#   ./install.sh all               -> claude + codex + opencode (global agents)
#
# Flags:
#   -f, --force        overwrite without asking
#   --project DIR      target project for the (project-scoped) cursor install
#
# Path overrides (env): CLAUDE_SKILLS_DIR, CODEX_SKILLS_DIR, OPENCODE_SKILLS_DIR
set -eo pipefail

SKILL_NAME="predicting-football-matches"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$ROOT/skills/$SKILL_NAME"
FORCE=0
CURSOR_PROJECT="$PWD"

usage() { sed -n '2,20p' "$ROOT/install.sh" | sed 's/^# \{0,1\}//'; }

_strip_cache() { find "$1" -name __pycache__ -type d -prune -exec rm -rf {} + 2>/dev/null || true; }

# copy_skill <skills-base-dir> <agent-label>
copy_skill() {
  local base="$1" label="$2" target="$1/$SKILL_NAME"
  mkdir -p "$base"
  if [ -e "$target" ] && [ "$FORCE" -ne 1 ]; then
    printf '%s exists: %s — overwrite? [y/N] ' "$label" "$target"
    read -r reply
    case "$reply" in y|Y) ;; *) echo "  skipped $label"; return 0 ;; esac
  fi
  rm -rf "$target"
  cp -R "$SRC" "$target"
  _strip_cache "$target"
  echo "  installed $label -> $target"
}

install_claude()   { copy_skill "${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}" "Claude Code"; }
install_codex()    { copy_skill "${CODEX_SKILLS_DIR:-$HOME/.agents/skills}" "Codex CLI"; }
install_opencode() { copy_skill "${OPENCODE_SKILLS_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills}" "OpenCode"; }

install_cursor() {
  local proj="$1" rules base_rel
  rules="$proj/.cursor/rules"
  base_rel=".cursor/rules/$SKILL_NAME"
  mkdir -p "$rules/$SKILL_NAME"
  cp -R "$SRC/." "$rules/$SKILL_NAME/"
  _strip_cache "$rules/$SKILL_NAME"
  python3 "$ROOT/adapters/make_cursor_rule.py" \
    --skill "$SRC/SKILL.md" --out "$rules/$SKILL_NAME.mdc" --base "$base_rel" >/dev/null
  echo "  installed Cursor rule -> $rules/$SKILL_NAME.mdc (project: $proj)"
  echo "  (Cursor rules are project-scoped; re-run per project. Global rules are UI-only.)"
}

# ---- parse args ----
targets=""
while [ $# -gt 0 ]; do
  case "$1" in
    -f|--force) FORCE=1 ;;
    --project) shift; CURSOR_PROJECT="$1" ;;
    claude|codex|opencode|cursor|all) targets="$targets $1" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown arg: $1" >&2; usage; exit 1 ;;
  esac
  shift
done

if [ -z "$targets" ]; then usage; exit 1; fi
if [ ! -d "$SRC" ]; then echo "error: skill source not found at $SRC" >&2; exit 1; fi

echo "Installing '$SKILL_NAME':"
for t in $targets; do
  case "$t" in
    claude)   install_claude ;;
    codex)    install_codex ;;
    opencode) install_opencode ;;
    cursor)   install_cursor "$CURSOR_PROJECT" ;;
    all)
      install_claude; install_codex; install_opencode
      echo "  note: 'all' = global agents. For Cursor (project-scoped) run: ./install.sh cursor"
      ;;
  esac
done
echo "Done. Restart the agent (or open a new session) to load the skill."
