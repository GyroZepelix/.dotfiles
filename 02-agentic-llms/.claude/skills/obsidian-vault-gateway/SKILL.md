---
name: obsidian-vault-gateway
description: >
  Route requests to the DedKat Obsidian vault at /home/dgjalic/Documents/2-Area/obsidian/DedKat.
  Discover available vault skills dynamically and delegate to specialized skills for reading,
  writing, searching, and organizing notes. Use when the user explicitly asks to interact with
  their Obsidian vault, notes, or mentions "in my vault", "add to my notes", "my obsidian".
disable-model-invocation: false
user-invocable: true
allowed-tools: Skill, Read, Grep, Glob, Bash, Edit, Write
---

# Purpose

Gateway skill that orchestrates interactions with the DedKat Obsidian vault. Discovers available vault skills at load time via dynamic context injection, implements a permission gate for vault access, and delegates operations to specialized sub-skills.

## Variables

VAULT_ROOT: "/home/dgjalic/Documents/2-Area/obsidian/DedKat"
VAULT_SKILLS_DIR: "/home/dgjalic/Documents/2-Area/obsidian/DedKat/.claude/skills"

## Available Vault Skills

!`python3 ${CLAUDE_SKILL_DIR}/scripts/discover_skill_frontmatter.py`

## Instructions

- IMPORTANT: Do not perform any vault operation (including reads) until the user has granted explicit permission in the current session
- After permission is granted, read operations (search, read, navigate) proceed without further confirmation
- Write operations (create, edit, move, delete, append) always require per-operation user confirmation, even after initial permission is granted
- Always load the **dedkat-vault** skill immediately after receiving permission — it provides essential vault structure knowledge (PARA folders, templates, naming conventions) needed for all operations
- Match user requests against the skill catalog in "Available Vault Skills" to select the appropriate skill
- When multiple skills are relevant, load them in order of specificity: vault knowledge first, then syntax skills
- Use the Skill tool to invoke vault skills — do not replicate their logic inline
- IMPORTANT: If an `obsidian` CLI command fails with a connection error, execute **CLI-Fallback** from Cookbook

## Workflow

1. **Request permission** — ask the user: "Would you like me to access your DedKat vault?" and wait for explicit consent. Do not proceed until the user confirms
2. **Load vault knowledge** — invoke the **dedkat-vault** skill via the Skill tool to load vault structure, PARA folders, templates, and conventions into context
3. **Classify the request** — determine whether the user's request is a read operation (search, read, navigate, list) or a write operation (create, edit, move, delete, append)
3. **Select skill** — match the request against the injected skill catalog:
    1. Vault navigation, templates, PARA structure → **dedkat-vault**
    2. Creating or editing markdown content → **obsidian-markdown**
    3. Working with `.base` database views → **obsidian-bases**
    4. CLI interaction with running Obsidian instance → **obsidian-cli**
    5. Working with `.canvas` files → **json-canvas**
    6. If no skill matches, use Read, Glob, and Grep for direct vault access at VAULT_ROOT
4. **Delegate to skill** — invoke the selected skill via the Skill tool with the user's request as context
5. **Confirm writes** — for write operations, present a summary of the intended change and wait for user approval before executing
6. **Execute the operation** — carry out the confirmed action. If an obsidian CLI command fails, execute **CLI-Fallback** from Cookbook
7. **Report result** — summarize the completed operation in 1-2 sentences

## Cookbook

### CLI-Fallback

#### IF
- An `obsidian` CLI command fails with a connection or timeout error
#### THEN
- Inform the user that Obsidian does not appear to be running
- Offer two options: (A) launch Obsidian via `obsidian --vault VAULT_ROOT` and retry, or (B) proceed with direct file I/O using Read, Write, Edit, Glob, and Grep tools at VAULT_ROOT
- Wait for the user's choice before proceeding
#### ELSE
- Report the CLI error to the user and suggest checking Obsidian is running

## Report

A successful execution fulfils the user's vault request via the appropriate specialized skill, with permission obtained before any access and confirmation obtained before any write. Failure conditions: performing any vault operation without explicit user permission, executing a write without per-operation confirmation, replicating sub-skill logic instead of delegating via the Skill tool, or running with `context: fork` (which prevents skill delegation).
