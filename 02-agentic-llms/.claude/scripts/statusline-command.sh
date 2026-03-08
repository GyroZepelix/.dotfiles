#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract values
model=$(echo "$input" | jq -r '.model.display_name')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir')
cwd=$(echo "$input" | jq -r '.cwd')

# Get project name from project_dir or cwd
if [ -n "$project_dir" ]; then
  project_name=$(basename "$project_dir")
else
  project_name=$(basename "$cwd")
fi

# Get git branch (skip optional locks)
git_branch=""
if [ -d "$cwd/.git" ] || git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

# Calculate total tokens
total_tokens=$((total_input + total_output))

# Format tokens with K suffix if >= 1000
if [ $total_tokens -ge 1000 ]; then
  tokens_display="$(awk "BEGIN {printf \"%.1fK\", $total_tokens/1000}")"
else
  tokens_display="${total_tokens}"
fi

# Create progress bar (20 chars width)
progress_bar=""
if [ -n "$used_pct" ]; then
  filled=$(awk "BEGIN {printf \"%.0f\", $used_pct / 5}")
  empty=$((20 - filled))

  for ((i = 0; i < filled; i++)); do
    progress_bar+="━"
  done
  for ((i = 0; i < empty; i++)); do
    progress_bar+="─"
  done

  pct_display="${used_pct}%"
else
  progress_bar="────────────────────"
  pct_display="0%"
fi

# ANSI color codes
RESET="\033[0m"
BOLD="\033[1m"
CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[33m"
MAGENTA="\033[35m"
BLUE="\033[34m"
WHITE="\033[37m"
DIM="\033[2m"

# Color the progress bar: filled = green, empty = dim
colored_bar=""
if [ -n "$used_pct" ]; then
  filled_int=$(awk "BEGIN {printf \"%.0f\", $used_pct / 5}")
  for ((i = 0; i < filled_int; i++)); do
    colored_bar+="\033[32m━"
  done
  for ((i = filled_int; i < 20; i++)); do
    colored_bar+="\033[2;37m─"
  done
  colored_bar+="$RESET"
else
  colored_bar="${DIM}────────────────────${RESET}"
fi

# Build colorized status line
status="${BOLD}${CYAN}${model}${RESET}"
status+=" ${colored_bar}"
status+=" ${YELLOW}${pct_display}${RESET}"
status+=" ${WHITE}${tokens_display} tokens${RESET}"

if [ -n "$git_branch" ]; then
  status+=" ${MAGENTA} ${git_branch}${RESET}"
fi

status+=" ${BLUE} ${project_name}${RESET}"

printf '%b' "$status"
