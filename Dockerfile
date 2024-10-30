FROM rclone/rclone:latest

LABEL maintainer="Original by Robin Ostlund <me@robinostlund.name>, Modified for unified solution"

# Default environment variables from original Dockerfile
ENV SYNC_OPTS=-v
ENV RCLONE_OPTS="--config /config/rclone.conf"
ENV TZ=

# Install required packages
RUN apk -U add \
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

# Create necessary directories
RUN mkdir -p /config /logs/cron /logs/rclone /logs/webui /var/cache/rclone

# Copy scripts
COPY scripts/* /scripts/

# Make scripts executable
RUN chmod +x /scripts/*.sh /scripts/*.py

# Set volumes
VOLUME ["/config", "/logs", "/var/cache/rclone"]

ENTRYPOINT ["/scripts/entrypoint.sh"]