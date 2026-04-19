FROM alpine:3.23.3

RUN apk update && apk upgrade && apk add --no-cache \
    mariadb \
    mariadb-client

# Alpineのデフォルト設定 (mariadb-server.cnf) には skip-networking が含まれている
RUN sed -i 's/^skip-networking/# skip-networking/' /etc/my.cnf.d/mariadb-server.cnf

COPY conf/my.cnf /etc/my.cnf.d/inception.cnf

COPY tools/init_db.sh /init_db.sh
RUN chmod +x /init_db.sh


RUN mkdir -p /var/lib/mysql && chown -R mysql:mysql /var/lib/mysql

EXPOSE 3306

ENTRYPOINT ["/init_db.sh"]

