# Rclone Docker with WebUI, AutoMount, and Sync

A unified Docker solution for running Rclone with Web GUI access, automated mounting, cron-based synchronization, and health monitoring. This project combines the best features of multiple Rclone Docker implementations into a single, easy-to-use container solution.

## Features

- 🌐 Web GUI for easy management
- 🔄 Automated remote mounting
- ⏰ Scheduled sync operations
- 🏥 Health check monitoring
- 📁 VFS caching support
- 🔒 Secure configuration
- 🕒 Timezone support

## Requirements

- [Docker](https://docs.docker.com/engine/install/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- FUSE support on the host system:
  ```bash
  sudo apt update && sudo apt install fuse3 -y  # For Debian/Ubuntu
  ```

## Quick Start

1. Create required directories:
```bash
mkdir -p config logs
```

2. Create your rclone.conf file in the config directory. You can either:
   - Copy an existing configuration
   - Create a new one using `rclone config`
   - Use the Web GUI (note: OAuth2 configuration might require CLI setup)

3. Configure mounts (optional):
   Edit `mounts.json` to define your remote mounts:
```json
[
  {
    "fs": "OneDrive:",
    "mountPoint": "/hostfs/onedrive/onedrive_0",
    "mountOpt": {
      "AllowOther": true
    },
    "vfsOpt": {
      "CacheMode": "full"
    }
  }
]
```

4. Create a `.env` file with your settings:
```env
TZ=UTC
RCLONE_USER=admin
RCLONE_PASSWORD=your_secure_password
SYNC_SCHEDULE=0 * * * *
SYNC_ABORT_SCHEDULE=30 * * * *
SYNC_SRC=remote1:path
SYNC_DEST=remote2:path
HEALTH_CHECK_URL=https://hc-ping.com/your-uuid
INITIAL_SYNC=true
VFS_CACHE_MODE=full
VFS_CACHE_MAX_SIZE=100G
```

5. Start the container:
```bash
docker compose up -d
```

## Configuration

### Environment Variables

#### Core Settings
- `TZ`: Timezone (default: UTC)
- `RCLONE_USER`: WebUI username (default: admin)
- `RCLONE_PASSWORD`: WebUI password (default: password)
- `RCLONE_OPTS`: Additional rclone options

#### Sync Settings
- `SYNC_SRC`: Source location for sync
- `SYNC_DEST`: Destination location for sync
- `SYNC_OPTS`: Additional sync options (default: -v)
- `SYNC_SCHEDULE`: Cron schedule for sync (default: 0 * * * *)
- `SYNC_ABORT_SCHEDULE`: Cron schedule for aborting long-running syncs
- `INITIAL_SYNC`: Perform sync on startup (default: false)
- `HEALTH_CHECK_URL`: URL for health check pings

#### VFS Cache Settings
- `VFS_CACHE_MODE`: Cache mode (default: full)
- `VFS_CACHE_MAX_SIZE`: Maximum cache size (default: 100G)

### Web GUI

Access the Web GUI at `http://localhost:5572` with your configured credentials.

### Mount Points

Remote mounts are configured through `mounts.json`. The mount points will be accessible under the specified paths in the container and on the host system through the shared volume mount.

### Health Checks

The container supports integration with services like healthchecks.io. Set the `HEALTH_CHECK_URL` to receive notifications after successful sync operations.

## Limitations

1. OAuth2 configuration through the Web GUI may not work for some providers. Use the CLI for initial setup in these cases.
2. Mounts added through the Web GUI won't persist after container restart - use mounts.json for permanent mount configurations.

## Volumes

- `/config`: Rclone configuration
- `/logs`: Log files
- `/var/cache/rclone`: VFS cache
- `/hostfs`: Mount point for remote filesystems

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

This project combines and builds upon the work of:
- [rclone](https://github.com/rclone/rclone)
- Original automount implementation by [coanghel](https://github.com/coanghel)
- Original sync implementation by [bcardiff](https://github.com/bcardiff)
