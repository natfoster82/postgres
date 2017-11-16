FROM postgres:9.6

RUN apt-get update
RUN apt-get install s3cmd ca-certificates nano -y

ENV PG_MAX_WAL_SENDERS 8
ENV PG_WAL_KEEP_SEGMENTS 8
COPY setup-replication.sh /docker-entrypoint-initdb.d/
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint-initdb.d/setup-replication.sh /docker-entrypoint.sh

ADD ./scripts/backup.sh /scripts/backup.sh
ADD ./scripts/restore.sh /scripts/restore.sh
ADD ./.s3cfg /root/.s3cfg
