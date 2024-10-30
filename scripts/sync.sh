#!/bin/sh

set -e

echo "INFO: Starting sync.sh pid $$ $(date)"

if [ `lsof | grep $0 | wc -l | tr -d ' '` -gt 1 ]
then
  echo "WARNING: A previous sync is still running. Skipping new sync command."
else

echo $$ > /tmp/sync.pid

if test "$(rclone ls $SYNC_SRC $RCLONE_OPTS)"; then
  # the source directory is not empty
  # it can be synced without clear data loss
  echo "INFO: Starting rclone sync $SYNC_SRC $SYNC_DEST $RCLONE_OPTS $SYNC_OPTS"
  rclone sync $SYNC_SRC $SYNC_DEST $RCLONE_OPTS $SYNC_OPTS \
    --config /config/rclone.conf \
    --log-file /logs/rclone/sync.log \
    --log-level INFO

  if [ -z "$HEALTH_CHECK_URL" ]
  then
    echo "INFO: Define HEALTH_CHECK_URL with https://healthchecks.io to monitor sync job"
  else
    python3 /scripts/health_check.py
  fi
else
  echo "WARNING: Source directory is empty. Skipping sync command."
fi

rm -f /tmp/sync.pid

fi