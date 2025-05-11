#!/bin/bash

DATA_SHARE_BASE="$HOME/.local/share/task"
SYNC_LOG="$DATA_SHARE_BASE/timew-cron-update.log"
LOCK_FILE="$DATA_SHARE_BASE/TIMEWSYNC.lock" # Unique lock file name for Timewarrior
MAX_LOG_SIZE=1048576  # 1MB (1 * 1024 * 1024 bytes)

export TZ="Europe/Zagreb"

# --- Script Body ---
# Use file descriptor 9 for locking to ensure it's released even if the script exits unexpectedly.
exec 9>"$LOCK_FILE"

if flock -n -w 5 9; then
    # Lock acquired
    # Setup trap to ensure lock file is released on exit (normal, error, or signal)
    cleanup() {
        echo "$(date "+%F %T") - Cleanup: Releasing lock." >> "$SYNC_LOG"
        flock -u 9  # Release the lock
        exec 9>&-   # Close the file descriptor
    }
    trap cleanup EXIT SIGINT SIGTERM

    echo "$(date "+%F %T") - Lock acquired. Starting Timewarrior sync." >> "$SYNC_LOG"

    # Perform sync with timeout and retry logic
    # The original script retried once on failure: output=$(timewsync 2>&1 || timewsync 2>&1)
    # We'll replicate that with timeouts for each attempt.

    sync_output=""
    sync_success=false

    # First attempt
    echo "$(date "+%F %T") - Attempting timewsync (1st try)..." >> "$SYNC_LOG"
    if output_attempt1=$(timeout 60 timewsync 2>&1); then
        sync_output="$output_attempt1"
        sync_success=true
        echo "$(date "+%F %T") - Timewarrior sync successful on first attempt." >> "$SYNC_LOG"
    else
        # First attempt failed (could be timeout or other error)
        rc1=$?
        echo "$(date "+%F %T") - Timewarrior sync first attempt failed (exit code: $rc1). Output: $output_attempt1. Retrying..." >> "$SYNC_LOG"

        # Second attempt
        echo "$(date "+%F %T") - Attempting timewsync (2nd try)..." >> "$SYNC_LOG"
        if output_attempt2=$(timeout 60 timewsync 2>&1); then
            sync_output="$output_attempt2"
            sync_success=true
            echo "$(date "+%F %T") - Timewarrior sync successful on second attempt." >> "$SYNC_LOG"
        else
            rc2=$?
            sync_output="$output_attempt2" # Capture output of the failed second attempt
            echo "$(date "+%F %T") - Timewarrior sync FAILED after second attempt (exit code: $rc2)." >> "$SYNC_LOG"
        fi
    fi

    # Log the final relevant output from sync attempts
    if [ -n "$sync_output" ]; then
        echo "Final sync output/error details:" >> "$SYNC_LOG"
        echo "$sync_output" >> "$SYNC_LOG"
    fi

    # Rotate log if it's over MAX_LOG_SIZE
    if [ -f "$SYNC_LOG" ] && [ $(stat -c%s "$SYNC_LOG") -gt $MAX_LOG_SIZE ]; then
        echo "$(date "+%F %T") - Rotating log file." >> "$SYNC_LOG"
        mv "$SYNC_LOG" "$SYNC_LOG.old" && touch "$SYNC_LOG"
        echo "$(date "+%F %T") - Log rotation complete. Previous log: $SYNC_LOG.old" >> "$SYNC_LOG"
    fi

    echo "$(date "+%F %T") - Timewarrior sync process finished." >> "$SYNC_LOG"
    # Lock will be released by the trap

else
    # Could not acquire lock
    echo "$(date "+%F %T") - Could not acquire lock for Timewarrior sync. Previous sync still running or lock stale ($LOCK_FILE exists)." >> "$SYNC_LOG"
    exit 1 # Indicate failure to acquire lock
fi

exit 0
