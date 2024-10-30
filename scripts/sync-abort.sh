#!/bin/bash
set -e

if [ -f /var/run/sync.pid ]; then
    PID=$(cat /var/run/sync.pid)
    if kill -0 $PID 2>/dev/null; then
        echo "Aborting sync process (PID: $PID)"
        kill $PID
        rm -f /var/run/sync.pid
    fi
fi 