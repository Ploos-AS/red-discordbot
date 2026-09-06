# Changelog

## Unreleased

Future post-release fixes and maintenance go here.

## [0.2.0] - 2026-09-06

- Added qualified runtime, persistence/upgrade, upstream-version, and hardening gates.
- Added controlled `REDBOT_VERSION` source-of-truth and bump helper while retaining Red-DiscordBot 3.5.24.
- Hardened Compose and Podman Quadlet defaults with read-only root filesystem and constrained `/tmp` tmpfs.
- Qualified dropped capabilities, `no-new-privileges`, non-root UID/GID 1000, writable `/data`, healthcheck, and clean stop lifecycle.
- Retained v0.1.0 as the explicit upgrade/rollback baseline.
- Added release-candidate consistency checks before stable tag promotion.

## [0.1.0] - 2026-09-03

- Immutable Red-DiscordBot 3.5.24 image with application files outside `/data`.
- Fixed non-root UID/GID 1000 runtime with persistent Red state under `/data`.
- Noninteractive, idempotent JSON bootstrap and preferred `TOKEN_FILE` secrets.
- Local healthcheck and graceful SIGTERM handling through `tini`.
- Docker Compose and rootless Podman Quadlet deployment definitions.
- Qualified `linux/amd64` and `linux/arm64` GHCR edge/stable publication.
- SBOM, maximum-mode provenance, and tagged-build attestation.
