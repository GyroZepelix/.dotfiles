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

Distills YouTube videos into structured, scannable Obsidian-optimized markdown notes. Extracts transcripts via yt-dlp with a resilient browser-cookie fallback for YouTube's bot-detection wall, processes transcripts in an isolated subagent to handle long-form content (up to 2 hours), and produces a summary with YAML frontmatter, thematic grouping, timestamps, and Obsidian callouts. After saving, enters follow-up Q&A mode for deeper exploration of the video content.

## Variables

ARGS: $ARGUMENTS (required — YouTube URL followed by optional save flags)
TEMP_DIR: "/tmp/yt-transcript"
FILE_DATE: runtime — output of `date +%y%m%d` captured in step 3, used as filename prefix (e.g. `260415`)
YTDLP_BASE: runtime — the working `yt-dlp` invocation prefix derived in step 4, reused verbatim for all subsequent yt-dlp calls in steps 5 and 6

## Instructions

- IMPORTANT: Abort immediately if yt-dlp is not installed — do not attempt any alternative transcript extraction method
- IMPORTANT: Never run more than one `yt-dlp` command against the same URL in parallel — YouTube rate-limits identical bot fingerprints and parallel calls trip the bot-detection wall even when sequential calls succeed. All yt-dlp invocations in this skill run strictly sequentially
- IMPORTANT: A `"Sign in to confirm you're not a bot"` error is a COOKIE problem, never a player-client problem. Do not attempt to fix it with `--extractor-args player_client=...` or similar flags — the fix is always to supply working browser cookies via `--cookies-from-browser <browser>:<profile>`. Execute **Bot-Check-Recovery** from Cookbook instead of improvising
- IMPORTANT: Once `YTDLP_BASE` is set in step 4, every subsequent yt-dlp call in this skill MUST reuse that exact prefix verbatim. Do not re-derive it, do not drop the `--cookies-from-browser` flag, do not swap profiles
- Parse ARGS to extract: VIDEO_URL (first positional argument), SAVE_MODE (`--obsidian` or `--path <dir>` if present, otherwise unset)
- Supported URL formats: `youtube.com/watch?v=`, `youtu.be/`, `m.youtube.com/watch?v=`, `youtube.com/shorts/`
- Prefer manual captions over auto-generated; prefer English over other languages
- All output must be in English regardless of the video's language
- Auto-generate the output filename as `{FILE_DATE}-<sanitized title>.md` where the sanitized title is the video title with filesystem-unsafe characters removed and spaces preserved (e.g. `260415-How React Server Components Work.md`)
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

3. **Check prerequisites and capture date** — run the following via the Bash tool in a single sequential call, and store the outputs:
    ```bash
    which yt-dlp && date +%y%m%d
    ```
    If `which yt-dlp` returns a non-zero exit code, output the install instructions below and stop. Otherwise store the `date` output as `FILE_DATE`:
    > **yt-dlp is required but not installed.** Install it with:
    > - Arch Linux: `sudo pacman -S yt-dlp`
    > - pip: `pip install yt-dlp`
    > - Homebrew: `brew install yt-dlp`

4. **Derive working yt-dlp invocation** — execute **Bot-Check-Recovery**(url: VIDEO_URL) from Cookbook to determine the correct yt-dlp invocation prefix for this machine's environment. Store the result as `YTDLP_BASE`. From this point forward every yt-dlp call in this skill reuses `YTDLP_BASE` verbatim

5. **Extract metadata** — run the following via the Bash tool (sequential — do not parallelize with step 6) and store the three output lines as VIDEO_TITLE, VIDEO_AUTHOR, and VIDEO_DURATION:
    ```bash
    YTDLP_BASE --print title --print channel --print duration_string --skip-download "VIDEO_URL"
    ```

6. **Extract transcript** — run the following via the Bash tool (sequential — do not parallelize with step 5):
    ```bash
    mkdir -p /tmp/yt-transcript && YTDLP_BASE --skip-download --write-subs --write-auto-subs --sub-lang en --convert-subs srt -o "/tmp/yt-transcript/%(id)s.%(ext)s" "VIDEO_URL"
    ```
    Use the Glob tool to find `*.srt` files in TEMP_DIR. If no `.srt` file exists, execute **No-Transcript-Gate** from Cookbook

7. **Delegate to subagent** — use the Agent tool to spawn a `general-purpose` subagent with the following prompt:
    1. Instruct the subagent to use the Read tool to load the `.srt` transcript file at the path found in step 6
    2. Provide the video metadata: VIDEO_TITLE, VIDEO_AUTHOR, VIDEO_DURATION, VIDEO_URL, and today's date as CREATED_DATE
    3. Include the complete **Output-Template** from the Cookbook as the target format
    4. Instruct the subagent to analyse the full transcript, identify the most important points, extract approximate timestamps, apply thematic categorization if VIDEO_DURATION exceeds 30 minutes, generate 3–5 topic strings for the frontmatter, and compose the completed markdown
    5. Instruct the subagent to return ONLY the finished markdown with no surrounding commentary

8. **Present summary** — display the subagent's returned markdown to the user and ask: "Would you like any changes before saving?"
    1. If the user requests changes, apply them to the markdown and re-present
    2. Proceed to saving only after the user confirms

9. **Save output** — execute **Save-Output**(markdown: GENERATED_MARKDOWN, title: VIDEO_TITLE, date: FILE_DATE) from Cookbook

10. **Clean up** — run `rm -rf /tmp/yt-transcript/` via the Bash tool

11. **Enter Q&A mode** — output:
    > **Summary saved.** You can now ask follow-up questions about this video. I will reference the saved summary to answer. If you need deeper detail on a specific point, I can re-extract the original transcript.

    For each follow-up question, use the Read tool to load the saved summary file and answer from its content. If the user requests detail not present in the summary, re-run steps 5–6 targeting the specific topic the user asked about

## Cookbook

### Bot-Check-Recovery(url)

- Step A — attempt the cheapest invocation first. Run via the Bash tool:
    ```bash
    yt-dlp --print title --skip-download "url" 2>&1
    ```
  - If the command succeeds (exit code 0 and a title is printed), return `yt-dlp` as the working `YTDLP_BASE` and stop
  - If the output contains `"Sign in to confirm you're not a bot"` or any `ERROR:` line, proceed to Step B
- Step B — enumerate installed browsers that likely hold a YouTube session. Run via the Bash tool:
    ```bash
    ls -d ~/.config/BraveSoftware/Brave-Browser 2>/dev/null; \
    ls -d ~/.config/google-chrome 2>/dev/null; \
    ls -d ~/.config/chromium 2>/dev/null; \
    ls -d ~/.mozilla/firefox 2>/dev/null
    ```
  - Build an ordered candidate list from the directories that exist, using this priority: `brave`, `chrome`, `chromium`, `firefox`
  - If no browser directory exists, inform the user: "No local browser with cookie storage was found. Please log into YouTube in Brave, Chrome, Chromium, or Firefox and retry." and stop
- Step C — for each candidate browser in order, determine the profile name:
  - For `brave`: `ls ~/.config/BraveSoftware/Brave-Browser/` and pick `Default` if present, otherwise the first profile directory
  - For `chrome`: `ls ~/.config/google-chrome/` and pick `Default` if present, otherwise the first profile directory
  - For `chromium`: `ls ~/.config/chromium/` and pick `Default` if present, otherwise the first profile directory
  - For `firefox`: `ls ~/.mozilla/firefox/` and pick the first directory ending in `.default-release`, otherwise the first directory ending in `.default`
- Step D — for each candidate, test the invocation. Run via the Bash tool (one at a time, sequentially):
    ```bash
    yt-dlp --cookies-from-browser "<browser>:<profile>" --print title --skip-download "url" 2>&1
    ```
  - If the command succeeds and prints a title, return `yt-dlp --cookies-from-browser "<browser>:<profile>"` as the working `YTDLP_BASE` and stop
  - If the command fails with the bot-check error, continue to the next candidate
  - If the command fails with any other error (e.g. `Unsupported URL`, `Video unavailable`), report that error to the user and stop — do not continue trying other browsers
- Step E — if all candidates fail the bot check, inform the user: "All installed browsers failed the YouTube bot check. Please log into YouTube in one of: brave, chrome, chromium, firefox — then retry. If you are already logged in, your cookies may have expired." and stop

### No-Transcript-Gate

- Inform the user: "No transcript or captions found for this video."
- Present two options:
  - **[A] Abort** — stop the skill entirely
  - **[B] Attempt fallback** — extract the video description using `YTDLP_BASE --print description --skip-download "VIDEO_URL"` via the Bash tool, then continue to step 7 using the description text as the source material instead of a transcript
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

### Save-Output(markdown, title, date)

- Compute the target filename as `{date}-{sanitized title}.md`, where the sanitized title replaces filesystem-unsafe characters (`/`, `\`, `:`, `*`, `?`, `"`, `<`, `>`, `|`) with nothing and preserves spaces
#### IF
- SAVE_MODE is `--obsidian`
#### THEN
- Invoke the `obsidian-vault-gateway` skill via the Skill tool, passing the markdown content and requesting it be saved with the computed filename (including the `{date}-` prefix)
#### ELSE
- #### IF
  - SAVE_MODE is `--path <dir>`
  #### THEN
  - Run `mkdir -p <dir>` via the Bash tool
  - Write the markdown to `<dir>/{date}-{sanitized title}.md` using the Write tool
  #### ELSE
  - Ask the user to choose:
    - **[O] Obsidian vault** — delegate to `obsidian-vault-gateway` via the Skill tool
    - **[P] Custom path** — prompt for a directory path, then create it and write the file
    - **[D] Display only** — output the markdown without saving to disk
  - Wait for the user's choice before proceeding

## Report

A successful execution produces an Obsidian-optimized markdown file named `YYMMDD-<sanitized title>.md` containing: YAML frontmatter with title, author, source, created date, tags (`[video]`), and topic (3–5 strings); a TL;DR section; a core takeaway callout; timestamped key points grouped by theme (for videos over 30 minutes) or listed sequentially (for shorter videos); optional glossary; action items as checkboxes; and further exploration links. The file is saved to the user-chosen location and the skill enters Q&A mode. Failure conditions: proceeding without yt-dlp installed, running yt-dlp calls in parallel against the same URL, attempting to fix a bot-check error with player-client flags instead of Bot-Check-Recovery, skipping the no-transcript gate when no subtitles are found, writing directly to the Obsidian vault instead of delegating to obsidian-vault-gateway, producing a summary without timestamps, omitting the `YYMMDD-` date prefix from the output filename, or exiting without offering Q&A mode.
