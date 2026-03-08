---
allowed-tools: Bash(git status:*)
description: Create a git commit message
model: claude-haiku-4-5-20251001
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

Based on the above changes, create a single commit message. Only output the commit message and no other boilerplate
