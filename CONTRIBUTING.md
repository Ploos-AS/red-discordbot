# Contributing

Build with `make build`, run static checks with `make check`, and run the full
container suite with `make test`. Changes should preserve immutable installation,
non-root runtime, Docker/Podman compatibility, and amd64/arm64 builds. Keep M0
focused: do not bundle arbitrary third-party cogs, Dashboard, Lavalink, PyLav, or
runtime update mechanisms. Update documentation and tests with behavior changes.
