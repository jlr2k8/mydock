FROM mysql:8.0.16

ARG PROJECT_NAME
COPY db.sql.gz /docker-entrypoint-initdb.d/
COPY my.cnf /etc/mysql/conf.d

VOLUME /var/lib/mysql