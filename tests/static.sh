#!/bin/sh
set -eu

version=$(cat VERSION)
printf '%s\n' "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' || {
    echo "VERSION must be strict X.Y.Z semver" >&2
    exit 1
}

redbot_version=$(cat REDBOT_VERSION)
printf '%s\n' "$redbot_version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' || {
    echo "REDBOT_VERSION must be strict X.Y.Z semver" >&2
    exit 1
}

for required in Dockerfile README.md LICENSE NOTICE VERSION REDBOT_VERSION CHANGELOG.md compose.yaml podman/red-discordbot.container "docs/releases/v${version}.md" docs/M0_2_5_RELEASE_QUALIFICATION.md docs/M0_3_DISTRIBUTION.md tests/release-qualification.sh; do
    [ -s "$required" ] || { echo "missing required file: $required" >&2; exit 1; }
done

for file in rootfs/usr/local/bin/* scripts/*.sh tests/*.sh; do
    if head -n 1 "$file" | grep -q bash; then bash -n "$file"; else sh -n "$file"; fi
done

grep -Eq '^ARG REDBOT_VERSION$' Dockerfile
grep -Fq "ARG CONTAINER_VERSION=${version}" Dockerfile
grep -q '^USER 1000:1000$' Dockerfile
grep -Fq 'VOLUME ["/data"]' Dockerfile
grep -Fq 'org.opencontainers.image.version="${CONTAINER_VERSION}"' Dockerfile
grep -Fq 'io.ploos.red-discordbot.upstream.version="${REDBOT_VERSION}"' Dockerfile
grep -Fq 'build-args:' .github/workflows/container.yml
grep -Fq 'REDBOT_VERSION=${{ steps.versions.outputs.redbot }}' .github/workflows/container.yml
grep -Fq 'tests/hardening-qualification.sh' .github/workflows/container.yml
grep -Fq 'tests/release-qualification.sh' .github/workflows/container.yml
grep -Fq 'Log in to Docker Hub' .github/workflows/container.yml
grep -Fq 'registry: docker.io' .github/workflows/container.yml
grep -Fq 'username: ${{ secrets.DOCKERHUB_USERNAME }}' .github/workflows/container.yml
grep -Fq 'password: ${{ secrets.DOCKERHUB_TOKEN }}' .github/workflows/container.yml
grep -Fq '${{ secrets.DOCKERHUB_USERNAME }}/red-discordbot' .github/workflows/container.yml
grep -Fq "ghcr.io/ploos-as/red-discordbot:${version}" README.md
grep -Fq "ghcr.io/ploos-as/red-discordbot:${version}" compose.yaml
grep -Fq 'read_only: true' compose.yaml
grep -Fq '/tmp:rw,noexec,nosuid,nodev,size=16m' compose.yaml
grep -Fq 'no-new-privileges:true' compose.yaml
grep -Fq -- '- ALL' compose.yaml
grep -Fq "Image=ghcr.io/ploos-as/red-discordbot:${version}" podman/red-discordbot.container
grep -Fq 'ReadOnly=true' podman/red-discordbot.container
grep -Fq 'Tmpfs=/tmp:rw,noexec,nosuid,nodev,size=16m' podman/red-discordbot.container
grep -Fq 'DropCapability=all' podman/red-discordbot.container
grep -Fq 'NoNewPrivileges=true' podman/red-discordbot.container
grep -Fq "ghcr.io/ploos-as/red-discordbot:${version}" "docs/releases/v${version}.md"
grep -Fq "## [${version}]" CHANGELOG.md
grep -Fq 'GPL-3.0-only' NOTICE
grep -Fq 'Cog-Creators/Red-DiscordBot' NOTICE
grep -Fq 'linux/amd64,linux/arm64' .github/workflows/container.yml
grep -Fq 'provenance: mode=max' .github/workflows/container.yml
grep -Fq 'sbom: true' .github/workflows/container.yml
grep -Fq 'gh release create' .github/workflows/container.yml
grep -Fq 'type=raw,value=latest' .github/workflows/container.yml
grep -Fq "startsWith(github.ref, 'refs/tags/v')" .github/workflows/container.yml
grep -Fq 'dual-registry' docs/M0_3_DISTRIBUTION.md

! grep -RIE '(discord(app)?[._ -]?token|TOKEN)[=:][[:space:]]*[A-Za-z0-9._-]{40,}' --exclude-dir=.git .
docker compose config --quiet

echo "static validation: PASS"
