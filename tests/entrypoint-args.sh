#!/bin/bash
set -Eeuo pipefail
image=${IMAGE:-red-discordbot:local}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
chmod 0777 "$tmp"
mkdir "$tmp/bin"
cat > "$tmp/bin/redbot" <<'EOF'
#!/bin/sh
printf '%s\n' "$@" > /data/argv
EOF
chmod 0755 "$tmp/bin/redbot"

run_case() {
    extra=$1
    docker run --rm -v "$tmp:/data" -v "$tmp/bin:/test-bin:ro" \
        -e PATH=/test-bin:/opt/redbot/venv/bin:/usr/local/bin:/usr/bin:/bin \
        -e TOKEN=dummy -e EXTRA_ARGS="$extra" "$image" >/dev/null
}

run_case '--dry-run'
tail -n 1 "$tmp/argv" | grep -Fx -- '--dry-run'
printf '%s\n' file-token > "$tmp/precedence-token"
docker run --rm -v "$tmp:/data" -v "$tmp/bin:/test-bin:ro" \
    -e PATH=/test-bin:/opt/redbot/venv/bin:/usr/local/bin:/usr/bin:/bin \
    -e TOKEN=environment-token -e TOKEN_FILE=/data/precedence-token "$image" >/dev/null
awk '/^--token$/{getline; print; exit}' "$tmp/argv" | grep -Fx file-token
! grep -Fx environment-token "$tmp/argv"
run_case '--some-option "value with spaces"'
tail -n 2 "$tmp/argv" | diff -u - <(printf '%s\n' '--some-option' 'value with spaces')
run_case '--one alpha --two "beta gamma"'
tail -n 4 "$tmp/argv" | diff -u - <(printf '%s\n' '--one' alpha '--two' 'beta gamma')

sentinel="$tmp/metacharacter-executed"
run_case "--one '; touch $sentinel'"
[[ ! -e "$sentinel" ]]
tail -n 2 "$tmp/argv" | diff -u - <(printf '%s\n' '--one' "; touch $sentinel")

if output=$(docker run --rm -v "$tmp:/data" -v "$tmp/bin:/test-bin:ro" \
    -e PATH=/test-bin:/opt/redbot/venv/bin:/usr/local/bin:/usr/bin:/bin \
    -e TOKEN=dummy -e EXTRA_ARGS='--one "unterminated' "$image" 2>&1); then
    status=0
else
    status=$?
fi
[[ $status -eq 64 ]]
grep -q 'invalid EXTRA_ARGS quoting' <<<"$output"
