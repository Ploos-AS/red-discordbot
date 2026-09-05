#!/bin/bash
set -Eeuo pipefail

from_image=${FROM_IMAGE:-ghcr.io/ploos-as/red-discordbot:0.1.0}
to_image=${IMAGE:-red-discordbot:local}
volume=red-m022-data-$$

cleanup() {
  docker volume rm -f "$volume" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker pull "$from_image" >/dev/null
docker volume create "$volume" >/dev/null

config_path=/data/.config/Red-DiscordBot/config.json
marker_path=/data/m022-marker

# Establish persistent state with the released v0.1.0 image.
docker run --rm \
  -v "$volume:/data" \
  --entrypoint red-bootstrap \
  "$from_image"

docker run --rm \
  -v "$volume:/data" \
  --entrypoint sh \
  "$from_image" -c "printf '%s\n' v0.1.0 > '$marker_path'; test -s '$config_path'"

before=$(docker run --rm -v "$volume:/data" --entrypoint sh "$from_image" \
  -c "sha256sum '$config_path'")

# Upgrade: run the candidate image against exactly the same /data.
docker run --rm \
  -v "$volume:/data" \
  --entrypoint red-bootstrap \
  "$to_image"

after_upgrade=$(docker run --rm -v "$volume:/data" --entrypoint sh "$to_image" \
  -c "test \"\$(cat '$marker_path')\" = v0.1.0; sha256sum '$config_path'")
[[ "$before" == "$after_upgrade" ]]

# Rollback: the released v0.1.0 image must still accept that same persistent state.
docker run --rm \
  -v "$volume:/data" \
  --entrypoint red-bootstrap \
  "$from_image"

after_rollback=$(docker run --rm -v "$volume:/data" --entrypoint sh "$from_image" \
  -c "test \"\$(cat '$marker_path')\" = v0.1.0; sha256sum '$config_path'")
[[ "$before" == "$after_rollback" ]]

echo "M0.2.2 upgrade qualification: PASS"
