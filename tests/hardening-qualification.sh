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

# Run through the image's normal tini/entrypoint chain with the deployment
# hardening profile: read-only rootfs, tmpfs for /tmp, no added capabilities,
# and no-new-privileges. The helper avoids Discord network access.
docker run -d --name "$name" \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,nodev,size=16m \
  --cap-drop ALL \
  --security-opt no-new-privileges:true \
  -v "$volume:/data" \
  "$image" bash -c \
  'test "$(id -u)" = 1000; test "$(id -g)" = 1000; touch /data/m024-write; ! touch /usr/local/m024-write 2>/dev/null; echo $$ > /tmp/redbot.pid; exec -a redbot bash -c '\''trap "exit 0" TERM; while :; do sleep 1 & wait $!; done'\''' \
  >/dev/null

for _ in {1..20}; do
  if docker exec "$name" healthcheck >/dev/null 2>&1; then break; fi
  sleep 1
done
docker exec "$name" healthcheck >/dev/null

docker exec "$name" test -f /data/m024-write
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
