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
Please ensure the directory specified in the `BACKUP_DIR` variable `backup.sh` before running the script.

```sh
bash backup.sh
```

## Author

- [NakuRei](https://github.com/NakuRei)

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.
