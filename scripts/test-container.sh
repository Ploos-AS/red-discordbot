#!/bin/bash
set -Eeuo pipefail
image=${IMAGE:-red-discordbot:local}
secret='M0-dummy-token-never-connect'
tmp=$(mktemp -d)
trap 'docker rm -f red-m0-test >/dev/null 2>&1 || true; rm -rf "$tmp"' EXIT
chmod 0777 "$tmp"
printf '%s\n' "$secret" > "$tmp/token"
chmod 0644 "$tmp/token"
docker run --rm -v "$tmp:/data" --entrypoint red-bootstrap "$image"
before=$(sha256sum "$tmp/.config/Red-DiscordBot/config.json")
docker run --rm -v "$tmp:/data" --entrypoint red-bootstrap "$image"
after=$(sha256sum "$tmp/.config/Red-DiscordBot/config.json")
[[ "$before" == "$after" ]]
missing_output=$(docker run --rm -v "$tmp:/data" -e TOKEN_FILE=/data/missing "$image" 2>&1 || true)
grep -q 'TOKEN_FILE is not readable' <<<"$missing_output"
! grep -F "$secret" <<<"$missing_output"
touch "$tmp/empty-token"
empty_output=$(docker run --rm -v "$tmp:/data" -e TOKEN_FILE=/data/empty-token -e TOKEN="$secret" "$image" 2>&1 || true)
grep -q 'TOKEN_FILE is empty' <<<"$empty_output"
! grep -F "$secret" <<<"$empty_output"
docker run --name red-m0-test -v "$tmp:/data" -e TOKEN_FILE=/data/token "$image" >/dev/null 2>&1 || status=$?
[[ ${status:-0} -eq 78 ]]
! docker logs red-m0-test 2>&1 | grep -F "$secret"
docker rm red-m0-test >/dev/null
docker run -d --name red-m0-test -v "$tmp:/data" "$image" bash -c \
  'echo $$ > /tmp/redbot.pid; exec -a redbot bash -c '\''trap "exit 0" TERM; while :; do sleep 1 & wait $!; done'\''' >/dev/null
for _ in {1..10}; do docker exec red-m0-test healthcheck && break; sleep 1; done
docker exec red-m0-test healthcheck
docker stop --time 20 red-m0-test >/dev/null
[[ $(docker inspect -f '{{.State.ExitCode}}' red-m0-test) -eq 0 ]]
! docker logs red-m0-test 2>&1 | grep -F "$secret"
