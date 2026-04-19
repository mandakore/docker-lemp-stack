#!/bin/sh

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# -z
if [ -z "$(ls -A /var/lib/mysql)" ]; then

    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # 一時的な起動
    mysqld --user=mysql --skip-networking &
    TEMP_PID=$!

    # 待機
    for i in $(seq 1 30); do
        if mysqladmin ping --socket=/run/mysqld/mysqld.sock --silent 2>/dev/null; then
            break
        fi
        sleep 1
    done


    mysql --socket=/run/mysqld/mysqld.sock -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'localhost';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    # 一時プロセスの終了
    mysqladmin shutdown --socket=/run/mysqld/mysqld.sock --password="${MYSQL_ROOT_PASSWORD}"
    wait $TEMP_PID
fi

exec mysqld --user=mysql