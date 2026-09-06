#!/bin/bash
set -Eeuo pipefail

image=${IMAGE:-red-discordbot:local}
version=$(cat VERSION)
redbot_version=$(cat REDBOT_VERSION)
notes="docs/releases/v${version}.md"

[[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
[[ $redbot_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
[[ -s $notes ]]
grep -Fq "## [${version}]" CHANGELOG.md
grep -Fq "ghcr.io/ploos-as/red-discordbot:${version}" "$notes"

image_version=$(docker image inspect -f '{{ index .Config.Labels "org.opencontainers.image.version" }}' "$image")
upstream_version=$(docker image inspect -f '{{ index .Config.Labels "io.ploos.red-discordbot.upstream.version" }}' "$image")
image_user=$(docker image inspect -f '{{ .Config.User }}' "$image")

[[ $image_version == "$version" ]]
[[ $upstream_version == "$redbot_version" ]]
[[ $image_user == "1000:1000" ]]
docker image inspect -f '{{ json .Config.Volumes }}' "$image" | grep -Fq '"/data"'
docker image inspect -f '{{ json .Config.Healthcheck }}' "$image" | grep -Fq 'healthcheck'

if [[ ${GITHUB_REF:-} == refs/tags/* ]]; then
  [[ ${GITHUB_REF#refs/tags/} == "v${version}" ]] || {
    echo "error: release tag ${GITHUB_REF#refs/tags/} does not match VERSION v${version}" >&2
    exit 1
  }
fi

grep -Fq 'type=semver,pattern={{version}}' .github/workflows/container.yml
grep -Fq 'type=semver,pattern={{major}}.{{minor}}' .github/workflows/container.yml
grep -Fq 'type=raw,value=latest' .github/workflows/container.yml
grep -Fq 'provenance: mode=max' .github/workflows/container.yml
grep -Fq 'sbom: true' .github/workflows/container.yml
grep -Fq 'gh release create' .github/workflows/container.yml

echo "M0.2.5 release qualification: PASS"
