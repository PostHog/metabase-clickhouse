# metabase-clickhouse

This repo builds the [official Metabase docker image](https://hub.docker.com/r/metabase/metabase/), with the addition of the [Clickhouse driver](https://github.com/enqueue/metabase-clickhouse-driver) and ARM64 support (see upstream [issue](https://github.com/metabase/metabase/issues/13119)).

To update the version of Metabase, update the Dockerfile and push a new tag to the repo. CI will build and push the new image!
