#!/bin/sh
set -eu

version=$(cat VERSION)
printf '%s\n' "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' || {
    echo "VERSION must be strict X.Y.Z semver" >&2
    exit 1
}

for required in Dockerfile README.md LICENSE NOTICE VERSION compose.yaml podman/red-discordbot.container "docs/releases/v${version}.md"; do
    [ -s "$required" ] || { echo "missing required file: $required" >&2; exit 1; }
done

for file in rootfs/usr/local/bin/* scripts/*.sh tests/*.sh; do
    if head -n 1 "$file" | grep -q bash; then bash -n "$file"; else sh -n "$file"; fi
done

grep -Eq '^ARG REDBOT_VERSION=[0-9]+\.[0-9]+\.[0-9]+$' Dockerfile
grep -Fq 'ARG CONTAINER_VERSION=0.1.0' Dockerfile
grep -q '^USER 1000:1000$' Dockerfile
grep -Fq 'VOLUME ["/data"]' Dockerfile
grep -Fq 'org.opencontainers.image.version="${CONTAINER_VERSION}"' Dockerfile
grep -Fq 'io.ploos.red-discordbot.upstream.version="${REDBOT_VERSION}"' Dockerfile
grep -Fq "ghcr.io/ploos-as/red-discordbot:${version}" README.md
grep -Fq "ghcr.io/ploos-as/red-discordbot:${version}" compose.yaml
grep -Fq "Image=ghcr.io/ploos-as/red-discordbot:${version}" podman/red-discordbot.container
grep -Fq "ghcr.io/ploos-as/red-discordbot:${version}" "docs/releases/v${version}.md"
grep -Fq 'GPL-3.0-only' NOTICE
grep -Fq 'Cog-Creators/Red-DiscordBot' NOTICE
grep -Fq 'linux/amd64,linux/arm64' .github/workflows/container.yml
grep -Fq 'provenance: mode=max' .github/workflows/container.yml
grep -Fq 'sbom: true' .github/workflows/container.yml
grep -Fq 'gh release create' .github/workflows/container.yml
grep -Fq 'type=raw,value=latest' .github/workflows/container.yml
grep -Fq "startsWith(github.ref, 'refs/tags/v')" .github/workflows/container.yml

! grep -RIE '(discord(app)?[._ -]?token|TOKEN)[=:][[:space:]]*[A-Za-z0-9._-]{40,}' --exclude-dir=.git .
docker compose config --quiet

echo "static validation: PASS"
