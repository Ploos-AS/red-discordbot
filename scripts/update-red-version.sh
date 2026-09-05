#!/bin/sh
set -eu

usage() {
    echo "usage: $0 X.Y.Z" >&2
    exit 64
}

[ "$#" -eq 1 ] || usage
new_version=$1
printf '%s\n' "$new_version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' || {
    echo "error: version must be strict X.Y.Z semver" >&2
    exit 64
}

current=$(cat REDBOT_VERSION)
if [ "$current" = "$new_version" ]; then
    echo "Red-DiscordBot is already pinned to $new_version"
    exit 0
fi

printf '%s\n' "$new_version" > REDBOT_VERSION

echo "Updated Red-DiscordBot pin: $current -> $new_version"
echo "Next: review upstream release notes, run tests/static.sh, build with REDBOT_VERSION=$new_version, then run the full qualification suite."
