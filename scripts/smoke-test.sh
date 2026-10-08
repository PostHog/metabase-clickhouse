#!/usr/bin/env bash
set -euo pipefail

image=${1:?usage: scripts/smoke-test.sh IMAGE [EXPECTED_VERSION]}
expected_version=${2:-}
container="metabase-driver-smoke-${RANDOM}-${RANDOM}"

cleanup() {
    docker rm -f "$container" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker run -d --name "$container" -p 127.0.0.1::3000 "$image" >/dev/null
port=$(docker port "$container" 3000/tcp | awk -F: 'NR == 1 { print $NF }')

for _ in $(seq 1 90); do
    status=$(curl --max-time 5 -sS -o /tmp/metabase-driver-smoke.json -w '%{http_code}' \
        "http://127.0.0.1:${port}/api/session/properties" 2>/dev/null || true)
    if [[ "$status" == "200" ]]; then
        break
    fi
    sleep 2
done

if [[ ${status:-} != "200" ]]; then
    docker logs "$container"
    echo "Metabase did not become ready" >&2
    exit 1
fi

jq -e --arg version "$expected_version" '
    .engines.clickhouse != null and
    .engines.starburst != null and
    ($version == "" or .version.tag == $version)
' /tmp/metabase-driver-smoke.json >/dev/null

jq '{version, drivers: (.engines | with_entries(select(.key == "clickhouse" or .key == "starburst")) | keys)}' \
    /tmp/metabase-driver-smoke.json
