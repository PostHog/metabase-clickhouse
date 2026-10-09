# metabase-clickhouse

This repo builds the [official Metabase enterprise Docker image](https://hub.docker.com/r/metabase/metabase-enterprise/) with:

- the [ClickHouse driver](https://github.com/ClickHouse/metabase-clickhouse-driver);
- the [Starburst driver](https://github.com/starburstdata/metabase-driver), which provides the Trino JDBC integration missing from Metabase 1.49; and
- ARM64 support (see the upstream [issue](https://github.com/metabase/metabase/issues/13119)).

The legacy built-in `Presto` driver is not a substitute for the Starburst/Trino
driver: its old JDBC protocol cannot complete prepared-statement handshakes
against current Trino. Select **Starburst** when configuring a Trino database.

To update Metabase or either driver, update the pinned version and checksum in
`Dockerfile`. Run the image smoke test before opening a PR:

```sh
docker build -t metabase-clickhouse:test .
scripts/smoke-test.sh metabase-clickhouse:test
```

CI runs this legacy smoke test and publishes the multi-architecture image after a
change lands on `main`.

## Metabase 0.64.1 rehearsal

The isolated rehearsal build uses Metabase OSS 0.64.1 with ClickHouse JDBC 0.10.0.
The source commit and build patch live in `scripts/`. Build and test it with:

```sh
scripts/build-rehearsal.sh metabase-clickhouse:rehearsal-test
scripts/smoke-test.sh metabase-clickhouse:rehearsal-test v0.64.1
```

Set `PLATFORM=linux/amd64` for an amd64 build. The default builds for arm64.
CI smoke-tests this image on pull requests. Pushing the tag
`v0.64.1-rehearsal.1` builds, tests, and publishes the arm64 image as
`ghcr.io/posthog/metabase-clickhouse:0.64.1-rehearsal.1`. The tag does not
publish the legacy image. Only use the GHCR registry digest in the isolated
rehearsal values. Do not use the local Docker image ID as a registry digest.
