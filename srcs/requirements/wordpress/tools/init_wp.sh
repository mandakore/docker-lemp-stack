#!/bin/sh

WP_PATH="/var/www/html"

echo ">>> WordPress: 起動シーケンスを開始します..."

echo ">>> WordPress: MariaDB への接続を待機します..."

RETRY=0
MAX_RETRY=30
until mariadb -h mariadb -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" \
    "${MYSQL_DATABASE}" -e "SELECT 1" > /dev/null 2>&1; do
    RETRY=$((RETRY + 1))
    if [ "$RETRY" -ge "$MAX_RETRY" ]; then
        echo ">>> WordPress: MariaDB への接続がタイムアウトしました (${MAX_RETRY}秒)"
        exit 1
    fi
    echo ">>> WordPress: MariaDB 待機中... (${RETRY}/${MAX_RETRY})"
    sleep 2
done

echo ">>> WordPress: MariaDB への接続に成功しました！"


if [ ! -f "${WP_PATH}/wp-config.php" ]; then
    echo ">>> WordPress: 初回セットアップを開始します..."


    echo ">>> WordPress: コアファイルをダウンロードしています..."
    wp --allow-root core download \
        --path="${WP_PATH}" \
        --locale=ja


    echo ">>> WordPress: wp-config.php を作成しています..."
    wp --allow-root config create \
        --path="${WP_PATH}" \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost=mariadb \
        --skip-check


    echo ">>> WordPress: インストールを実行しています..."
    wp --allow-root core install \
        --path="${WP_PATH}" \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_LOGIN}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email


    echo ">>> WordPress: 一般ユーザーを追加しています..."
    wp --allow-root user create \
        "${WP_USER_LOGIN}" "${WP_USER_EMAIL}" \
        --role=editor \
        --user_pass="${WP_USER_PASSWORD}" \
        --path="${WP_PATH}"

    chown -R nobody:nobody "${WP_PATH}"

    echo ">>> WordPress: 初回セットアップが完了しました！"
else
    echo ">>> WordPress: wp-config.php が存在します。セットアップをスキップします。"
    chown -R nobody:nobody "${WP_PATH}"
fi

echo ">>> WordPress: php-fpm83 をフォアグラウンドで起動します..."

# exec: 現在のシェルプロセスを php-fpm83 に置き換える
# -F: フォアグラウンドで起動 (デーモン化しない)
# -R: rootで実行することを許可 (コンテナ環境での実行に必要)
exec php-fpm83 -F -R
