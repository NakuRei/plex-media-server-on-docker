# Plex Media Server on Docker

This repository provides configuration and scripts to run [Plex Media Server](https://github.com/plexinc/pms-docker) using Docker.

## Requirements

- Docker Compose v2.39.1 or later
- A Plex account

## Usage

1. Copy `.env.sample` to `.env` and set the required values.
    ```sh
    cp .env.sample .env
    # Edit .env as needed
    ```
1. Start Plex Media Server with Docker Compose:
    ```sh
    docker compose up -d
    ```
1. Access Plex Media Server at `http://<your-server-ip>:32400/web` and log in with your Plex account.
1. Enjoy your media!

## Backup

Run `backup.sh` to back up the `config/` directory.
Ensure that the directory defined in the `BACKUP_DIR` variable exists before running the script.

```sh
bash backup.sh
```

## Restore

To restore Plex configuration from a backup archive (config_YYYYmmdd_HHMMSS.tgz), follow the steps below.

1. Stop Plex container

```sh
docker compose stop plex
```

2. Replace the current `config/` directory

Backup the existing directory or remove it:

```sh
mv config config.bak_$(date +%Y%m%d_%H%M%S)
mkdir config
```

3. Extract the backup archive

Run this in the same directory as `compose.yaml`:

```sh
tar -xzvf /path/to/config_YYYYmmdd_HHMMSS.tgz
```

The archive contains a top-level config/ directory, which will be restored under the current directory.

4. Fix ownership

Match the UID/GID specified in the Compose configuration and replace the placeholders below with those numeric values (for example, from `id -u` and `id -g`):

```sh
chown -R <PLEX_UID>:<PLEX_GID> config
```

5. Start Plex

```sh
docker compose up -d
```

After startup, Plex Web UI should reflect the restored library and settings.

## Author

- [NakuRei](https://github.com/NakuRei)

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.
