#!/bin/bash
set -Eeuo pipefail

image=${IMAGE:-red-discordbot:local}
name=red-m024-hardening
volume=red-m024-data-$$

cleanup() {
  docker rm -f "$name" >/dev/null 2>&1 || true
  docker volume rm -f "$volume" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker volume create "$volume" >/dev/null

common=(
  --read-only
  --tmpfs /tmp:rw,noexec,nosuid,nodev,size=16m
  --cap-drop ALL
  --security-opt no-new-privileges:true
  -v "$volume:/data"
)

# Bootstrap the Red instance first under the exact same hardening profile that
# will be used for the lifecycle/healthcheck probe. This creates the expected
# /data/.config/Red-DiscordBot/config.json without contacting Discord.
docker run --rm \
  "${common[@]}" \
  "$image" red-bootstrap >/dev/null

# Run through the image's normal tini/entrypoint chain with the deployment
# hardening profile. The helper avoids Discord network access while still
# presenting a redbot-named process for the healthcheck contract.
docker run -d --name "$name" \
  "${common[@]}" \
  "$image" bash -c \
  'test "$(id -u)" = 1000; test "$(id -g)" = 1000; touch /data/m024-write; ! touch /usr/local/m024-write 2>/dev/null; echo $$ > /tmp/redbot.pid; exec -a redbot bash -c '\''trap "exit 0" TERM; while :; do sleep 1 & wait $!; done'\''' \
  >/dev/null

for _ in {1..20}; do
  if docker exec "$name" healthcheck >/dev/null 2>&1; then break; fi
  sleep 1
done
docker exec "$name" healthcheck >/dev/null

docker exec "$name" test -f /data/m024-write
docker exec "$name" test -f /data/.config/Red-DiscordBot/config.json
docker exec "$name" sh -c 'test -w /data && test ! -w /usr/local'

inspect=$(docker inspect "$name")
printf '%s' "$inspect" | grep -q '"ReadonlyRootfs": true'
printf '%s' "$inspect" | grep -q '"no-new-privileges:true"'
printf '%s' "$inspect" | grep -q '"CapDrop": \['
printf '%s' "$inspect" | grep -q '"ALL"'
printf '%s' "$inspect" | grep -q '"Destination": "/data"'

docker stop --time 20 "$name" >/dev/null
[[ $(docker inspect -f '{{.State.ExitCode}}' "$name") -eq 0 ]]

echo "M0.2.4 hardening qualification: PASS"
