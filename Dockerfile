FROM debian:jessie

RUN apt-get update && apt-get install -y wget cron

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
	wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
	apt-get update && apt-get install -y postgresql-client barman

#RUN apt-get purge -y wget && apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/*

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true

ENV TMPDIR=/tmp \
	BARMAN_LOG_FILE=/var/log/barman.log \
	BARMAN_BARMAN_HOME=/var/lib/barman \
	BARMAN_CONFIGURATION_FILES_DIRECTORY=/etc/barman.d

VOLUME /etc/barman.d/
VOLUME /var/lib/barman/

COPY docker-entrypoint.sh /

WORKDIR $BARMAN_BARMAN_HOME

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["barman"]