FROM mysql:8.0.26

ENV MYSQL_DATABASE=${MYSQL_DATABASE} \
    MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}

COPY ./conf.d/my.cnf /etc/mysql/conf.d/

ADD setup.sql /docker-entrypoint-initdb.d

EXPOSE 5004
