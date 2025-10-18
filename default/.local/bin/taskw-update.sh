#!/bin/bash

TASK_SHARE="$HOME/.local/share/task"
SYNC_LOG="$TASK_SHARE/cron-update.log"
LOCK_FILE="$TASK_SHARE/SYNC.lock"
MAX_LOG_SIZE=1048576  # 1MB

# Set timezone for consistent logging
export TZ="Europe/Zagreb"

# Use file descriptor 9 for locking
exec 9>"$LOCK_FILE"

# Try to acquire lock with timeout
if flock -n -w 5 9; then
    # Cleanup function
    cleanup() {
        flock -u 9
        exec 9>&-
    }
    trap cleanup EXIT

    # Check if Taskwarrior is already running
    if pidof task >/dev/null; then
        echo "$(date "+%F %T") - Taskwarrior process running, skipping sync" >> "$SYNC_LOG"
        exit 0
    fi

    # Perform sync with timeout
    timeout 60 task sync >> "$SYNC_LOG" 2>&1
    echo "$(date "+%F %T") - Sync completed" >> "$SYNC_LOG"

    # Rotate log if over 1MB
    if [ $(stat -c%s "$SYNC_LOG") -gt $MAX_LOG_SIZE ]; then
        mv "$SYNC_LOG" "$SYNC_LOG.old"
    fi
else
    echo "$(date "+%F %T") - Previous sync still running, skipping" >> "$SYNC_LOG"
fi

exit 0
