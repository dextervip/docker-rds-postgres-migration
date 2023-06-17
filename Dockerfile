FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND noninteractive

ENV PG_MAJOR 15
ENV PG_VERSION 15.2
ENV PG_SHA256 99a2171fc3d6b5b5f56b757a7a3cb85d509a38e4273805def23941ed2b8468c7

RUN apt-get update -y -q && apt-get install -y wget gnupg2

RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && echo 'deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main' $PG_MAJOR > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update -y -q && \
  apt-get install -y postgresql-common postgresql-client-15 python3-pip && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN pip install awscli

WORKDIR /usr/src/app

ADD migrate.sh /usr/src/app/migrate.sh
RUN chmod 0755 /usr/src/app/migrate.sh

CMD ["/usr/src/app/migrate.sh"]
