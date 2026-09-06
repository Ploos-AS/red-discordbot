# M0.2.5 Release qualification

M0.2.5 qualifies a container release candidate before a stable Git tag is allowed to promote it.

## Candidate

- Container version: `0.2.0`
- Upstream Red-DiscordBot: `3.5.24`
- Upgrade/rollback baseline: `ghcr.io/ploos-as/red-discordbot:0.1.0`

Container and upstream versions remain independent.

## Automated gate

`tests/release-qualification.sh` verifies that:

- `VERSION` and `REDBOT_VERSION` are strict `X.Y.Z` values;
- release notes for `v$VERSION` exist and reference the expected image;
- the changelog contains the candidate version;
- the built image OCI container-version label equals `VERSION`;
- the built image upstream-version label equals `REDBOT_VERSION`;
- the image remains non-root (`1000:1000`), declares `/data`, and has a healthcheck;
- the workflow retains semver stable/minor tags, `latest`, SBOM, provenance, and GitHub release creation;
- on a tag build, the Git tag must equal `v$VERSION` exactly.

The gate runs after the runtime, persistence/upgrade, and hardening qualification suites.

## Promotion rule

A stable release is not created from `main`. Stable tags are produced only by pushing an exact `v$VERSION` Git tag after the full Container workflow is green on the candidate commit. The tag build must itself pass the same qualification gates before image publication and GitHub release creation.

## Out of scope

M0.2.5 does not itself create the Git tag or GitHub release. Those are separate promotion actions after the release candidate is green.
