---
name: youtube-distiller
description: >
  Extracts and distills YouTube video transcripts into structured, Obsidian-optimized
  markdown summaries with key insights, timestamps, and thematic categorization.
  Use when the user wants to summarize a YouTube video, extract key points from a video,
  or learn from a video quickly.
argument-hint: <youtube-url> [--obsidian | --path <dir>]
disable-model-invocation: false
user-invocable: true
allowed-tools: Bash, Read, Write, Glob, Agent, Skill
---

# Purpose

Distills YouTube videos into structured, scannable Obsidian-optimized markdown notes. Extracts transcripts via yt-dlp, processes them in an isolated subagent to handle long-form content (up to 2 hours), and produces a summary with YAML frontmatter, thematic grouping, timestamps, and Obsidian callouts. After saving, enters follow-up Q&A mode for deeper exploration of the video content.

## Variables

ARGS: $ARGUMENTS (required — YouTube URL followed by optional save flags)
TEMP_DIR: "/tmp/yt-transcript"

## Instructions

- IMPORTANT: Abort immediately if yt-dlp is not installed — do not attempt any alternative transcript extraction method
- Parse ARGS to extract: VIDEO_URL (first positional argument), SAVE_MODE (`--obsidian` or `--path <dir>` if present, otherwise unset)
- Supported URL formats: `youtube.com/watch?v=`, `youtu.be/`, `m.youtube.com/watch?v=`, `youtube.com/shorts/`
- Prefer manual captions over auto-generated; prefer English over other languages
- All output must be in English regardless of the video's language
- Auto-generate the output filename from the video title by removing characters unsafe for file systems and preserving spaces (e.g., `How React Server Components Work.md`)
- Adaptive key point counts: 5–10 for videos under 30 minutes, 10–20 for videos 30 minutes to 2 hours
- For videos over 30 minutes, group key points by theme/topic with section headings
- For videos under 30 minutes, list key points sequentially without theme grouping
- Each key point must include an approximate timestamp in `[HH:MM:SS]` format extracted from the subtitle timecodes
- Each key point must explain why it matters and provide context in 2–4 sentences optimized for quick scanning and later keyword searching
- Use Obsidian callouts: `> [!important]` for the core takeaway, `> [!tip]` for actionable advice, `> [!warning]` for common pitfalls or caveats mentioned in the video
- IMPORTANT: When saving to Obsidian, always delegate to the `obsidian-vault-gateway` skill via the Skill tool — never write directly to the vault path

## Workflow

1. **Parse arguments** — extract VIDEO_URL as the first token from ARGS. Scan remaining tokens for `--obsidian` or `--path <dir>` and store as SAVE_MODE. If no URL is provided, output the expected usage format and stop: `/youtube-distiller <youtube-url> [--obsidian | --path <dir>]`

2. **Validate URL** — verify VIDEO_URL matches a supported YouTube URL pattern. If invalid, inform the user of accepted formats and stop

3. **Check prerequisites** — run `which yt-dlp` via the Bash tool. If the command returns a non-zero exit code, output install instructions and stop:
    > **yt-dlp is required but not installed.** Install it with:
    > - Arch Linux: `sudo pacman -S yt-dlp`
    > - pip: `pip install yt-dlp`
    > - Homebrew: `brew install yt-dlp`

4. **Extract metadata** — run the following via the Bash tool and store the three output lines as VIDEO_TITLE, VIDEO_AUTHOR, and VIDEO_DURATION:
    ```bash
    yt-dlp --print title --print channel --print duration_string --skip-download "VIDEO_URL"
    ```

5. **Extract transcript** — run the following via the Bash tool:
    ```bash
    mkdir -p /tmp/yt-transcript && yt-dlp --skip-download --write-subs --write-auto-subs --sub-lang en --convert-subs srt -o "/tmp/yt-transcript/%(id)s.%(ext)s" "VIDEO_URL"
    ```
    Use the Glob tool to find `*.srt` files in TEMP_DIR. If no `.srt` file exists, execute **No-Transcript-Gate** from Cookbook

6. **Delegate to subagent** — use the Agent tool to spawn a `general-purpose` subagent with the following prompt:
    1. Instruct the subagent to use the Read tool to load the `.srt` transcript file at the path found in step 5
    2. Provide the video metadata: VIDEO_TITLE, VIDEO_AUTHOR, VIDEO_DURATION, VIDEO_URL, and today's date as CREATED_DATE
    3. Include the complete **Output-Template** from the Cookbook as the target format
    4. Instruct the subagent to analyse the full transcript, identify the most important points, extract approximate timestamps, apply thematic categorization if VIDEO_DURATION exceeds 30 minutes, generate 3–5 topic strings for the frontmatter, and compose the completed markdown
    5. Instruct the subagent to return ONLY the finished markdown with no surrounding commentary

7. **Present summary** — display the subagent's returned markdown to the user and ask: "Would you like any changes before saving?"
    1. If the user requests changes, apply them to the markdown and re-present
    2. Proceed to saving only after the user confirms

8. **Save output** — execute **Save-Output**(markdown: GENERATED_MARKDOWN, title: VIDEO_TITLE) from Cookbook

9. **Clean up** — run `rm -rf /tmp/yt-transcript/` via the Bash tool

10. **Enter Q&A mode** — output:
    > **Summary saved.** You can now ask follow-up questions about this video. I will reference the saved summary to answer. If you need deeper detail on a specific point, I can re-extract the original transcript.

    For each follow-up question, use the Read tool to load the saved summary file and answer from its content. If the user requests detail not present in the summary, re-run steps 5–6 targeting the specific topic the user asked about

## Cookbook

### No-Transcript-Gate

- Inform the user: "No transcript or captions found for this video."
- Present two options:
  - **[A] Abort** — stop the skill entirely
  - **[B] Attempt fallback** — extract the video description using `yt-dlp --print description --skip-download "VIDEO_URL"` via the Bash tool, then continue to step 6 using the description text as the source material instead of a transcript
- IMPORTANT: Do not proceed until the user explicitly chooses an option

### Output-Template

The subagent must produce markdown matching this structure:

```
---
title: "<VIDEO_TITLE>"
author: "<VIDEO_AUTHOR>"
source: "<VIDEO_URL>"
created: <CREATED_DATE>
tags:
  - video
topic:
  - <topic string 1>
  - <topic string 2>
  - <topic string 3 to 5>
---

# <VIDEO_TITLE>

> [!info] Video Metadata
> **Author:** <VIDEO_AUTHOR> | **Duration:** <VIDEO_DURATION> | **Source:** [YouTube](<VIDEO_URL>)

## TL;DR

<2–3 sentence summary of the video's core message and value>

## Key Insights

> [!important] Core Takeaway
> <The single most important insight from the entire video in 2–3 sentences>

---

<FOR VIDEOS OVER 30 MINUTES — group points under theme headings:>

### <Theme Name>

#### <Point title> `[HH:MM:SS]`

<2–4 sentence explanation: what the point is, why it matters, and practical context>

> [!tip] <Actionable advice callout — include only when the point has a concrete action>
> <Brief actionable note>

<Repeat for each point in this theme>

---

<FOR VIDEOS UNDER 30 MINUTES — list points directly without theme headings:>

#### <Point title> `[HH:MM:SS]`

<2–4 sentence explanation>

---

## Glossary

| Term | Definition |
|------|-----------|
| <term> | <brief definition> |

<Include ONLY if the video introduces specialized terminology. Omit this entire section otherwise.>

## Action Items

- [ ] <Practical takeaway 1>
- [ ] <Practical takeaway 2>
- [ ] <Practical takeaway 3>

## Further Exploration

- <Related topic or resource mentioned in the video>
- <Suggested search term or concept for deeper learning>
```

### Save-Output(markdown, title)

#### IF
- SAVE_MODE is `--obsidian`
#### THEN
- Invoke the `obsidian-vault-gateway` skill via the Skill tool, passing the markdown content and requesting it be saved with the sanitized title as the filename
#### ELSE
- #### IF
  - SAVE_MODE is `--path <dir>`
  #### THEN
  - Run `mkdir -p <dir>` via the Bash tool
  - Write the markdown to `<dir>/<sanitized title>.md` using the Write tool
  #### ELSE
  - Ask the user to choose:
    - **[O] Obsidian vault** — delegate to `obsidian-vault-gateway` via the Skill tool
    - **[P] Custom path** — prompt for a directory path, then create it and write the file
    - **[D] Display only** — output the markdown without saving to disk
  - Wait for the user's choice before proceeding

## Report

A successful execution produces an Obsidian-optimized markdown file containing: YAML frontmatter with title, author, source, created date, tags (`[video]`), and topic (3–5 strings); a TL;DR section; a core takeaway callout; timestamped key points grouped by theme (for videos over 30 minutes) or listed sequentially (for shorter videos); optional glossary; action items as checkboxes; and further exploration links. The file is saved to the user-chosen location and the skill enters Q&A mode. Failure conditions: proceeding without yt-dlp installed, skipping the no-transcript gate when no subtitles are found, writing directly to the Obsidian vault instead of delegating to obsidian-vault-gateway, producing a summary without timestamps, or exiting without offering Q&A mode.
