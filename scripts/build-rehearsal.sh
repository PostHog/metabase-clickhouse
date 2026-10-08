#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

source_dir="$work_dir/metabase"
git clone --depth 1 --branch v0.64.1 https://github.com/metabase/metabase.git "$source_dir"
test "$(git -C "$source_dir" rev-parse HEAD)" = 7010f2797355cb04f2bc2e82e747eaa86357a315
git -C "$source_dir" apply --unidiff-zero --check "$script_dir/clickhouse-jdbc-0.10.0.patch"
git -C "$source_dir" apply --unidiff-zero "$script_dir/clickhouse-jdbc-0.10.0.patch"

docker build --platform "${PLATFORM:-linux/arm64}" --build-arg VERSION=v0.64.1 \
    --tag "${1:-metabase-clickhouse:oss-0.64.1-chjdbc-0.10.0}" "$source_dir"
