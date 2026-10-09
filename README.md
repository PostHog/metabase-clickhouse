# metabase-clickhouse

This repository builds Metabase OSS v0.64.1 for ARM64. It applies a pinned
patch to bundle ClickHouse JDBC 0.10.0 and retains the upstream Starburst driver.
The build clones the Metabase v0.64.1 tag and verifies its source commit before
applying the patch. To update Metabase or the ClickHouse driver, update the pins
in `scripts/build-image.sh`, the patch in `scripts/`, and the expected version
in `.github/workflows/docker.yaml`.

Build and verify the image locally:

```sh
scripts/build-image.sh metabase-clickhouse:test
scripts/smoke-test.sh metabase-clickhouse:test v0.64.1
```

Set `PLATFORM=linux/amd64` for an amd64 build. The default builds for ARM64.
CI builds and smoke-tests the image on pull requests and publishes the same
recipe to GHCR after pushes to `main` and signed `v*` release tags. Pull
requests never publish an image. The tag `v0.64.1` publishes
`ghcr.io/posthog/metabase-clickhouse:0.64.1`. In GitOps values, specify
the version tag and its registry digest in the same image reference.
Kubernetes then displays the version and pulls the immutable digest.

The older `0.64.1-rehearsal.1` tag remains available for the isolated production
rehearsal releases. Metabase migrates its metadata database on startup. Back up
the serving database before changing its image; rolling back the image alone
does not reverse a schema migration.
