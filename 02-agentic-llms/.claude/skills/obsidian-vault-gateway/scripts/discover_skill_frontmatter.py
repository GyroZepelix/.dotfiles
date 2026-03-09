#!/usr/bin/env python3
"""Scan DedKat vault skills directory and output name + description for each skill."""

import glob
import re

VAULT_SKILLS_PATTERN = "/home/dgjalic/Documents/2-Area/obsidian/DedKat/.claude/skills/*/SKILL.md"


def extract_frontmatter(filepath):
    """Extract name and description from YAML frontmatter between --- delimiters."""
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
    except OSError:
        return None

    match = re.match(r"^---\s*\n(.*?)\n---", content, re.DOTALL)
    if not match:
        return None

    fm = match.group(1)
    lines = fm.splitlines()

    name = None
    description_parts = []
    in_description = False

    for line in lines:
        top_key_match = re.match(r"^(\w[\w-]*):\s*(.*)", line)

        if top_key_match:
            key = top_key_match.group(1)
            value = top_key_match.group(2).strip().strip("\"'")

            if key == "name":
                name = value
                in_description = False
            elif key == "description":
                in_description = True
                if value and value not in (">", "|", ">-", "|-"):
                    description_parts.append(value)
            else:
                in_description = False
        elif in_description and line.startswith((" ", "\t")):
            description_parts.append(line.strip())

    if not name:
        return None

    description = " ".join(description_parts).strip()
    return {"name": name, "description": description}


def main():
    skills = sorted(glob.glob(VAULT_SKILLS_PATTERN))

    if not skills:
        print("No vault skills found at expected path.")
        return

    for filepath in skills:
        data = extract_frontmatter(filepath)
        if data:
            print(f"- **{data['name']}** (skill): {data['description']}")


if __name__ == "__main__":
    main()
