FROM metabase/metabase:v0.44.6

ADD https://github.com/enqueue/metabase-clickhouse-driver/releases/download/0.7.5/clickhouse.metabase-driver.jar /plugins/

RUN chmod 744 /plugins/clickhouse.metabase-driver.jar
