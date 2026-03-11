---
name: commit-message
description: Analyzes git changes and generates commit messages following Angular commit conventions without scope. Runs git status and diff to understand changes, asks the user about staging preferences, produces a type-prefixed lowercase subject line with no description body, and commits after user approval. Use when the user wants to commit changes, when the user asks for a commit message, when the user runs /commit-message.
disable-model-invocation: false
user-invocable: true
allowed-tools: Bash(git status), Bash(git diff), Bash(git add), Bash(git commit), AskUserQuestion
---

# Purpose

You generate and execute git commits following Angular commit conventions without scope. You analyse staged and unstaged changes, produce a single-line commit message in the format `<type>[!]: <subject>`, and commit only after the user approves the message.

## Variables

VALID_TYPES: "feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert"
MAX_SUBJECT_LENGTH: "72"

## Instructions

- Commit messages use exactly the format `<type>[!]: <subject>` — no scope, no parentheses, no description body
- The only valid types are: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
- Select the commit type based on the primary intent of the changes:
  - `feat` — new feature or functionality
  - `fix` — bug fix
  - `docs` — documentation only
  - `style` — formatting, whitespace, semicolons — no logic change
  - `refactor` — code restructuring without changing behaviour
  - `perf` — performance improvement
  - `test` — adding or updating tests
  - `build` — build system or external dependencies
  - `ci` — CI configuration and scripts
  - `chore` — maintenance tasks, tooling, configs not covered above
  - `revert` — reverting a previous commit
- Append `!` before the colon only when the change introduces a breaking change (e.g., `feat!: remove deprecated auth endpoint`)
- The subject must start lowercase after the colon space, except for proper acronyms and abbreviations (e.g., VPN, API, HTTP, URL, CSS, HTML, JSON, REST, SQL, SSH, DNS)
- The subject must use imperative mood — write "add" not "added", "fix" not "fixed", "remove" not "removed"
- The subject must not end with a period
- The total commit message length (type prefix + colon + space + subject) must not exceed `MAX_SUBJECT_LENGTH` characters
- IMPORTANT: Never commit without explicit user approval of the commit message
- IMPORTANT: Never add a description body or footer to the commit — the message is always a single line
- When using `git commit`, always pass the message via a HEREDOC to preserve formatting:
  ```
  git commit -m "$(cat <<'EOF'
  <type>: <subject>
  EOF
  )"
  ```

## Workflow

1. **Check for changes** — run `git status` to inspect the working tree. Execute **No-Changes-Guard** from Cookbook
2. **Analyse changes** — run `git diff` and `git diff --staged` in parallel to capture both unstaged and staged changes
3. **Ask about staging** — use AskUserQuestion to ask the user whether to stage all changes or commit only what is already staged. Present two options:
    1. "Stage all changes" — stages everything with `git add -A`
    2. "Commit only staged changes" — proceeds with current staging
4. **Stage if requested** — if the user chose to stage all changes, run `git add -A`
5. **Verify staged content** — run `git diff --staged` to confirm there are staged changes to commit. If nothing is staged, inform the user that there are no staged changes and exit
6. **Generate commit message** — analyse the staged diff and select the most accurate type from `VALID_TYPES`. Compose the subject in imperative mood, lowercase, no trailing period, within `MAX_SUBJECT_LENGTH` characters. If the change is breaking, append `!` before the colon
7. **Present for approval** — output the generated commit message and use AskUserQuestion to ask the user to approve, edit, or reject:
    1. "Approve" — proceed to commit
    2. "Edit" — accept the user's revised message and proceed to commit
    3. "Reject" — abort without committing
8. **Commit** — run `git commit -m "<approved-message>"` using the HEREDOC format specified in Instructions. Output the commit result to the user

## Cookbook

### No-Changes-Guard

#### IF
- `git status` reports a clean working tree with no untracked files, no modifications, and no staged changes
#### THEN
- Output: "Nothing to commit — working tree is clean." and stop execution
#### ELSE
- Proceed to the next Workflow step

## Report

A successful execution produces a single git commit with a message matching the format `<type>[!]: <subject>` where: the type is one of the 11 valid Angular types, the subject is lowercase (except acronyms), imperative mood, no trailing period, and the total length is at most 72 characters. No description body is present. The user approved the message before the commit was executed. Failure conditions: committing without user approval, including a scope in parentheses, adding a description body, using a type not in the valid list, exceeding 72 characters, or using past tense in the subject.
