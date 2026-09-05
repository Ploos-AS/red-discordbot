# M0.2.3 — Upstream version management

## Goal

Make the packaged Red-DiscordBot version explicit, single-sourced, reviewable, and testable without coupling it to the container's own release version.

## Authoritative pin

`REDBOT_VERSION` is the only repository source of truth for the upstream Red-DiscordBot version.

The container version remains independent in `VERSION` and release tags.

## Build contract

`Dockerfile` requires `REDBOT_VERSION` as a build argument and does not carry a default upstream version. CI reads the value from `REDBOT_VERSION` and passes it to both test and multi-architecture publish builds.

This prevents a Dockerfile default from silently drifting away from the repository pin.

Example local build:

```sh
redbot_version=$(cat REDBOT_VERSION)
docker build --build-arg "REDBOT_VERSION=$redbot_version" -t red-discordbot:local .
```

## Runtime qualification

`scripts/smoke-test.sh` reads `REDBOT_VERSION` and requires `redbot --version` in the built image to report that version.

`tests/static.sh` requires:

- strict `X.Y.Z` syntax in `REDBOT_VERSION`;
- a required, default-free `ARG REDBOT_VERSION` in the Dockerfile;
- CI wiring from the authoritative pin into Docker build arguments.

The existing runtime, persistence, upgrade, rollback, amd64, arm64, SBOM, and provenance gates remain applicable after a pin change.

## Controlled bump procedure

Run:

```sh
bash scripts/update-red-version.sh X.Y.Z
```

The helper validates strict semantic version syntax and changes only `REDBOT_VERSION`.

A version bump is not qualified merely because the pin changed. Before accepting it:

1. Review upstream Red-DiscordBot release notes and compatibility considerations.
2. Run static validation.
3. Build the candidate with the new pin.
4. Run the full container qualification suite.
5. Require the normal `Container` workflow to pass before publishing or releasing a stable container version.

## M0.2.3 qualification result

M0.2.3 is complete when the normal `Container` workflow passes with this mechanism in place while the current upstream pin remains unchanged at `3.5.24`.
