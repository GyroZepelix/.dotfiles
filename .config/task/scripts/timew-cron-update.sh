#!/bin/sh

TASK_SHARE="$HOME/.local/share/task"
SYNC_LOG="$TASK_SHARE/timew-cron-update.log"
LOCK_FILE="$TASK_SHARE/TIMEWSYNC.lock"

if {
    set -C
    2>/dev/null >"$LOCK_FILE"
}; then
    trap 'rm -f "$LOCK_FILE"' EXIT
    output=$(timewsync)
    echo "$(date "+%F %T") - $output" >>"$SYNC_LOG" 2>&1
fi

exit 0
