#!/bin/sh
set -eu
image=${IMAGE:-red-discordbot:local}
redbot_version=$(cat REDBOT_VERSION)
docker run --rm --entrypoint redbot "$image" --version | grep -F "$redbot_version"
docker run --rm --entrypoint sh "$image" -c 'test "$(id -u)" -ne 0 && touch /data/write-test'
docker run --rm --entrypoint sh "$image" -c 'red-bootstrap; red-bootstrap; test -s /data/.config/Red-DiscordBot/config.json'
if docker run --rm -e INSTANCE_NAME='invalid name' --entrypoint red-bootstrap "$image" 2>&1 | grep -q 'INSTANCE_NAME must'; then :; else exit 1; fi
if docker run --rm -e STORAGE_TYPE=postgres --entrypoint red-bootstrap "$image" 2>&1 | grep -q 'unsupported in M0'; then :; else exit 1; fi
