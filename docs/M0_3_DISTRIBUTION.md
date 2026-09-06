# M0.3 Distribution qualification

M0.3 expands the container distribution path from GHCR-only publishing to dual-registry publishing.

## Scope

The authoritative container workflow publishes qualified multi-architecture images to:

- `ghcr.io/ploos-as/red-discordbot`
- Docker Hub as `${DOCKERHUB_USERNAME}/red-discordbot`

The Docker Hub credentials are supplied through GitHub Actions organization or repository secrets:

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

The same `docker/metadata-action` output feeds both registries, so tag semantics are shared across GHCR and Docker Hub. Stable releases target `linux/amd64` and `linux/arm64`, include BuildKit provenance and SBOM attestations, and are published only after the test job succeeds.

## Qualification evidence

GitHub Actions run #51 (`34017293531`) on commit `6bda42eb1a8b919441b62badd997cacecea92542` completed successfully.

Observed gates:

- static validation passed
- container tests passed
- GHCR login passed
- Docker Hub login passed
- metadata generation passed
- multi-architecture build and push passed

This demonstrates that the configured Docker Hub secrets are available to this repository and that dual-registry publication from `main` works.

## Release semantics

`edge` tracks `main` in both registries.

For version tags, the workflow emits the full semver tag, major/minor tag, and `latest` in both registries. A tag build must still pass the full qualification workflow before release publication occurs.

## Canonical-source note

The project distribution standard remains:

- source: Forgejo canonical, mirrored to GitHub and Codeberg
- OCI: GHCR and Docker Hub, with optional self-hosted Harbor later

The GitHub Actions workflow is currently the OCI build/publish execution point. Synchronizing the canonical Forgejo repository and configuring Codeberg mirroring are separate source-distribution tasks.
