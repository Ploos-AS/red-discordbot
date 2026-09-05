#!/bin/bash
set -Eeuo pipefail

image=${IMAGE:-red-discordbot:local}
name=red-m021-runtime
volume=red-m021-data-$$
secret='M0.2.1-dummy-token-never-connect'
tmp=$(mktemp -d)

cleanup() {
  docker rm -f "$name" >/dev/null 2>&1 || true
  docker volume rm -f "$volume" >/dev/null 2>&1 || true
  rm -rf "$tmp"
}
trap cleanup EXIT

printf '%s\n' "$secret" > "$tmp/token"
chmod 0644 "$tmp/token"

docker volume create "$volume" >/dev/null

# Fresh persistent state must bootstrap successfully as the image's non-root user.
docker run --rm \
  -v "$volume:/data" \
  --entrypoint red-bootstrap \
  "$image"

config_path=/data/.config/Red-DiscordBot/config.json
before=$(docker run --rm -v "$volume:/data" --entrypoint sh "$image" \
  -c "test -s '$config_path' && sha256sum '$config_path'")

# Re-running bootstrap against the same persistent state must be idempotent.
docker run --rm \
  -v "$volume:/data" \
  --entrypoint red-bootstrap \
  "$image"
after=$(docker run --rm -v "$volume:/data" --entrypoint sh "$image" \
  -c "sha256sum '$config_path'")
[[ "$before" == "$after" ]]

# A token-file startup failure must never echo the token itself.
docker run --name "$name" \
  -v "$volume:/data" \
  -v "$tmp/token:/run/secrets/discord_token:ro" \
  -e TOKEN_FILE=/run/secrets/discord_token \
  "$image" >/dev/null 2>&1 || status=$?
[[ ${status:-0} -eq 78 ]]
! docker logs "$name" 2>&1 | grep -F "$secret"
docker rm "$name" >/dev/null
unset status

# Exercise the real init/entrypoint signal chain without contacting Discord.
# Supplying a command makes entrypoint exec the helper while retaining tini as PID 1.
docker run -d --name "$name" \
  -v "$volume:/data" \
  "$image" bash -c \
  'printf "%s\n" first-boot > /data/m021-marker; echo $$ > /tmp/redbot.pid; exec -a redbot bash -c '\''trap "exit 0" TERM; while :; do sleep 1 & wait $!; done'\''' \
  >/dev/null

for _ in {1..20}; do
  if docker exec "$name" healthcheck >/dev/null 2>&1; then break; fi
  sleep 1
done
docker exec "$name" healthcheck >/dev/null

docker stop --time 20 "$name" >/dev/null
[[ $(docker inspect -f '{{.State.ExitCode}}' "$name") -eq 0 ]]

# Restart the same container and verify persistent state survived the stop/start.
docker start "$name" >/dev/null
for _ in {1..20}; do
  if docker exec "$name" healthcheck >/dev/null 2>&1; then break; fi
  sleep 1
done
docker exec "$name" healthcheck >/dev/null
docker exec "$name" sh -c 'test "$(cat /data/m021-marker)" = first-boot'

docker stop --time 20 "$name" >/dev/null
[[ $(docker inspect -f '{{.State.ExitCode}}' "$name") -eq 0 ]]
! docker logs "$name" 2>&1 | grep -F "$secret"

echo "M0.2.1 runtime qualification: PASS"
