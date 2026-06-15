#!/usr/bin/env python3
"""Generate a Cursor project rule (.mdc) from SKILL.md.

Cursor has no native skills mechanism (skills dirs are Claude Code / Codex /
OpenCode only), so we convert the skill's instructions into a `.cursor/rules`
rule. SKILL.md stays the single source of truth; helper-file paths are rewritten
to wherever the installer copies the skill (under .cursor/rules/<name>/).

Cursor .mdc frontmatter: description, globs, alwaysApply. We emit a
description + alwaysApply:false rule ("Apply Intelligently"), which mirrors how a
skill triggers on relevant requests.
"""
import argparse
import re


def split_frontmatter(text):
    """Return (frontmatter, body) splitting the leading --- ... --- block."""
    if text.startswith("---"):
        end = text.find("\n---", 3)
        if end != -1:
            return text[3:end].strip(), text[end + 4:].lstrip("\n")
    return "", text


def field(frontmatter, key):
    m = re.search(rf"^{key}:\s*(.+)$", frontmatter, re.MULTILINE)
    return m.group(1).strip() if m else ""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--skill", required=True, help="path to SKILL.md")
    ap.add_argument("--out", required=True, help="output .mdc path")
    ap.add_argument("--base", required=True,
                    help="path (from project root) where skill files are copied, "
                         "e.g. .cursor/rules/predicting-football-matches")
    a = ap.parse_args()

    with open(a.skill, encoding="utf-8") as f:
        fm, body = split_frontmatter(f.read())

    desc = field(fm, "description") or \
        "Pre-match football prediction and value-betting analysis."
    base = a.base.rstrip("/")

    # Point the helper-file references at the installed location.
    body = body.replace("scripts/match_model.py", f"{base}/scripts/match_model.py")
    body = body.replace("references/", f"{base}/references/")

    header = (
        "---\n"
        f"description: {desc}\n"
        "alwaysApply: false\n"
        "---\n\n"
        f"> Cursor rule generated from SKILL.md. The helper script and reference\n"
        f"> files live in `{base}/`. Run the model with\n"
        f"> `python3 {base}/scripts/match_model.py --help`.\n\n"
    )

    with open(a.out, "w", encoding="utf-8") as f:
        f.write(header + body)
    print(f"wrote {a.out}")


if __name__ == "__main__":
    main()
