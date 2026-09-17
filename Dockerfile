#
# Once https://github.com/metabase/metabase/issues/13119 will be resolved, please uncomment this
# section to use the official image and remove everything after it.
#
# FROM metabase/metabase-enterprise:v1.49.19
#
# ADD https://github.com/ClickHouse/metabase-clickhouse-driver/releases/download/0.9.2/clickhouse.metabase-driver.jar /plugins/
#
# RUN chmod 744 /plugins/clickhouse.metabase-driver.jar
#

FROM ubuntu:22.04

ENV FC_LANG=en-US LC_CTYPE=en_US.UTF-8

# Install dependencies
RUN apt-get update -yq && apt-get install -yq bash fonts-dejavu-core fonts-dejavu-extra fontconfig curl openjdk-11-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
    mkdir -p /app/certs && \
    curl https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem -o /app/certs/rds-combined-ca-bundle.pem  && \
    keytool -noprompt -import -trustcacerts -alias aws-rds -file /app/certs/rds-combined-ca-bundle.pem -keystore /etc/ssl/certs/java/cacerts -keypass changeit -storepass changeit && \
    curl https://cacerts.digicert.com/DigiCertGlobalRootG2.crt.pem -o /app/certs/DigiCertGlobalRootG2.crt.pem  && \
    keytool -noprompt -import -trustcacerts -alias azure-cert -file /app/certs/DigiCertGlobalRootG2.crt.pem -keystore /etc/ssl/certs/java/cacerts -keypass changeit -storepass changeit && \
    mkdir -p /plugins && chmod a+rwx /plugins && \
    useradd --shell /bin/bash metabase

WORKDIR /app

# Copy the Metabase app from the offical image
COPY --from=metabase/metabase-enterprise:v1.49.19 /app /app

# Copy the ClickHouse driver
ADD --chmod=744 https://github.com/ClickHouse/metabase-clickhouse-driver/releases/download/1.5.1/clickhouse.metabase-driver.jar /app/plugins/

# Metabase 1.49 bundles the legacy Presto JDBC driver, which cannot complete
# prepared-statement handshakes with Trino. Add the Starburst/Trino driver that
# uses io.trino.jdbc.TrinoDriver. Version 4.1.0 targets Metabase 1.47.2 and is
# compatible with the pinned 1.49.19 image.
ARG STARBURST_DRIVER_VERSION=4.1.0
ARG STARBURST_DRIVER_SHA256=238e6329d52482c4daa91a7d5855f8da7626758b6cc40fef103d3ab9b54a2869
RUN curl -fsSL \
        "https://github.com/starburstdata/metabase-driver/releases/download/${STARBURST_DRIVER_VERSION}/starburst-${STARBURST_DRIVER_VERSION}.metabase-driver.jar" \
        -o /app/plugins/starburst.metabase-driver.jar && \
    echo "${STARBURST_DRIVER_SHA256}  /app/plugins/starburst.metabase-driver.jar" | sha256sum -c - && \
    chmod 744 /app/plugins/starburst.metabase-driver.jar

RUN chown -R metabase /app

USER metabase
EXPOSE 3000

ENTRYPOINT ["/app/run_metabase.sh"]
