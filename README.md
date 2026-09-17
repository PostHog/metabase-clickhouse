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

CI runs the same smoke test and publishes the multi-architecture image after a
change lands on `main`.
