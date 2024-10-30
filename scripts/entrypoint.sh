#!/bin/sh

set -e

# Install required packages if not already installed
if ! command -v python3 >/dev/null 2>&1; then
    echo "Installing required packages..."
    apk -U add \
        ca-certificates \
        fuse \
        wget \
        dcron \
        tzdata \
        python3 \
        py3-pip \
        lsof \
        && pip3 install requests \
        && rm -rf /var/cache/apk/*
fi

# Create necessary directories
mkdir -p /config /logs/cron /logs/rclone /logs/webui /var/cache/rclone

# Set timezone if provided
if [ ! -z "$TZ" ]
then
    cp /usr/share/zoneinfo/$TZ /etc/localtime
    echo $TZ > /etc/timezone
fi

rm -f /tmp/sync.pid

# Start Rclone Web GUI in background
rclone rcd \
    --rc-web-gui \
    --rc-web-gui-no-open-browser \
    --rc-addr :5572 \
    --rc-user $RCLONE_USER \
    --rc-pass $RCLONE_PASSWORD \
    --config /config/rclone.conf \
    --log-file /logs/webui/rclone.log \
    --cache-dir /var/cache/rclone \
    --vfs-cache-mode $VFS_CACHE_MODE \
    --vfs-cache-max-size $VFS_CACHE_MAX_SIZE &

# Initialize mounts using rclone_initializer.py
if [ -f /config/mounts.json ]; then
    echo "INFO: Initializing mounts from mounts.json"
    python3 /scripts/rclone_initializer.py
fi

if [ -z "$SYNC_SRC" ] || [ -z "$SYNC_DEST" ]
then
    echo "INFO: No SYNC_SRC and SYNC_DEST found. Starting rclone config"
    rclone config $RCLONE_OPTS
    echo "INFO: Define SYNC_SRC and SYNC_DEST to start sync process."
else
    # Setup cron
    echo "Creating cron jobs..."
    crontab -r || true
    
    if [ ! -z "$SYNC_SCHEDULE" ]; then
        echo "$SYNC_SCHEDULE /scripts/sync.sh >> /logs/cron/sync.log 2>&1" >> /tmp/crontab.tmp
    fi

    if [ ! -z "$SYNC_ABORT_SCHEDULE" ]; then
        echo "$SYNC_ABORT_SCHEDULE /scripts/sync-abort.sh >> /logs/cron/abort.log 2>&1" >> /tmp/crontab.tmp
    fi

    if [ -f /tmp/crontab.tmp ]; then
        crontab /tmp/crontab.tmp
        rm /tmp/crontab.tmp
    fi

    # Start crond in background
    crond -b -L /logs/cron/crond.log

    # Perform initial sync if requested
    if [ "$INITIAL_SYNC" = "true" ]; then
        echo "Performing initial sync..."
        /scripts/sync.sh
    fi
fi

# Make scripts executable if they aren't already
chmod +x /scripts/*.sh /scripts/*.py 2>/dev/null || true

# Keep container running and follow logs
exec tail -F /logs/webui/rclone.log /logs/cron/crond.log /logs/cron/sync.log
