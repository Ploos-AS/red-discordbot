# Contributing

This repository builds the container/distribution layer; it is not a fork of
Red-DiscordBot. Run `make check`, `make build`, `make smoke`, and `make test`
before opening a pull request.

Preserve immutable installation, non-root runtime, Docker/Podman compatibility,
and amd64/arm64 builds. Do not bundle arbitrary third-party cogs or silently add
Dashboard, Lavalink, PyLav, runtime updates, or other future-milestone features.
Update documentation and tests whenever behavior changes.
