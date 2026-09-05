# M0.2.2 Persistence and upgrade qualification

M0.2.2 verifies the container's persistent `/data` contract across a real released image, the current candidate image, and rollback to the released image.

## Automated gate

`tests/upgrade-qualification.sh` runs in the normal Container workflow.

Default endpoints:

- from: `ghcr.io/ploos-as/red-discordbot:0.1.0`
- to: the locally built CI candidate image

The gate:

1. pulls the published v0.1.0 image;
2. creates a fresh named Docker volume;
3. bootstraps Red state using v0.1.0;
4. records the Red instance configuration checksum and an independent persistence marker;
5. runs the candidate image's bootstrap against the exact same `/data` volume;
6. verifies the marker and instance configuration remain intact;
7. runs v0.1.0 again against that same state as a rollback probe;
8. verifies the marker and instance configuration remain intact after rollback.

## What this qualifies

For a passing commit, the gate demonstrates that the candidate container does not require replacement of `/data` when moving from the published v0.1.0 container baseline, and that the tested bootstrap path remains rollback-compatible with v0.1.0.

## What this does not qualify

This is intentionally narrower than a full application data migration test. It does not claim:

- Discord authentication or live bot behavior;
- compatibility of every Red datastore object or third-party cog;
- compatibility across a future upstream Red schema migration that is not present in the candidate;
- backup archive creation/restoration;
- rootless Podman upgrade behavior;
- native arm64 runtime upgrade behavior.

Any future container release that changes the upstream Red version should continue to run this gate and add migration-specific fixtures if upstream introduces datastore migrations.

## Pass criterion

M0.2.2 is qualified only when the GitHub Actions Container workflow passes on the commit containing this gate. Merely adding the script is not runtime evidence.
