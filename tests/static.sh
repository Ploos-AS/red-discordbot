#!/bin/sh
set -eu
for file in rootfs/usr/local/bin/* scripts/*.sh tests/*.sh; do
    if head -n 1 "$file" | grep -q bash; then bash -n "$file"; else sh -n "$file"; fi
done
grep -Eq '^ARG REDBOT_VERSION=[0-9]+\.[0-9]+\.[0-9]+$' Dockerfile
grep -q '^USER 1000:1000$' Dockerfile
! grep -RIE '(discord(app)?[._ -]?token|TOKEN)[=:][[:space:]]*[A-Za-z0-9._-]{40,}' --exclude-dir=.git .
docker compose config --quiet
