# Ploos-AS/red-discordbot

A production-oriented, self-hosted OCI distribution of upstream
[Red-DiscordBot](https://github.com/Cog-Creators/Red-DiscordBot). Red is installed
at image build time and pinned, so one image digest always contains the same Red
version. This project does not fork Red and does not update it during startup.

The next container release candidate is **0.2.0**, packaging upstream Red-DiscordBot **3.5.24**. Container and upstream versions are intentionally independent.

This image uses immutable application files and explicit image upgrades, emphasizing reproducibility and rollback.

## Quick start

Create a token file readable by your user, then run:

```sh
docker volume create red-data
docker run -d --name red-discordbot --restart unless-stopped \
  --read-only --tmpfs /tmp:rw,noexec,nosuid,nodev,size=16m \
  --security-opt no-new-privileges:true --cap-drop ALL \
  -v red-data:/data -v "$PWD/secrets/discord_token:/run/secrets/discord_token:ro" \
  -e TOKEN_FILE=/run/secrets/discord_token \
  ghcr.io/ploos-as/red-discordbot:0.2.0
```

For Compose, create `secrets/discord_token`, then run `docker compose up -d`.
The checked-in Compose baseline targets the `0.2.0` release candidate and uses a
named volume, read-only root filesystem, constrained `/tmp` tmpfs,
`no-new-privileges`, and dropped capabilities. No ports are needed. `TOKEN_FILE`
takes precedence over `TOKEN` and its contents are never intentionally logged.

## Persistence and upgrades

Only `/data` is persistent. It contains Red's instance configuration, JSON
datastore, downloaded cog repositories, and cog data. The venv is immutable at
`/opt/redbot/venv`; logs go to container output by default. The process runs as
UID/GID 1000, so bind mounts must be writable by 1000 (named volumes are prepared
by the image). Upgrade by pulling a newer container tag and recreating the
container; back up `/data` first. Container versions and upstream Red versions
are independent.

Stable release images target `linux/amd64` and `linux/arm64`. `edge` tracks `main`;
`0.2.0`, `0.2`, and `latest` are promoted only by a successful `v0.2.0` tag build.
Release images include BuildKit SBOM and provenance attestations.

## Podman Quadlet

Create the secret with `printf '%s' "$TOKEN" | podman secret create red-discordbot-token -`,
copy `podman/red-discordbot.container` to `~/.config/containers/systemd/`, create
the referenced environment file, and run `systemctl --user daemon-reload` followed
by `systemctl --user start red-discordbot.service`. Ensure
`~/.local/share/red-discordbot` is owned by your rootless user.

See [configuration](docs/configuration.md), [architecture](docs/architecture.md),
and [migration guidance](docs/migration.md). The healthcheck is local liveness,
not proof of Discord connectivity. `tini` forwards SIGTERM for graceful shutdown.
No privileged mode, host networking, extra capabilities, or bundled third-party
cogs are used.

## Licensing

Packaging in this repository is MIT licensed. Upstream Red-DiscordBot is GPL-3.0-only; see [NOTICE](NOTICE) for attribution. This project is not affiliated with Cog Creators or Discord Inc.
