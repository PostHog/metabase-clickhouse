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

ENV FC_LANG en-US LC_CTYPE en_US.UTF-8

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
ADD --chmod=744 https://github.com/ClickHouse/metabase-clickhouse-driver/releases/download/1.5.0/clickhouse.metabase-driver.jar /app/plugins/

RUN chown -R metabase /app

USER metabase
EXPOSE 3000

ENTRYPOINT ["/app/run_metabase.sh"]
