#!/bin/sh

set -e

WP_PATH="/var/www/html"

export WP_CLI_PHP_ARGS="-d memory_limit=256M"

echo ">>> WordPress: 起動シーケンスを開始します..."

echo ">>> WordPress: MariaDB への接続を待機します..."

RETRY=0
MAX_RETRY=30
until mariadb -h mariadb -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" \
    "${MYSQL_DATABASE}" -e "SELECT 1" > /dev/null 2>&1; do
    RETRY=$((RETRY + 1))
    if [ "$RETRY" -ge "$MAX_RETRY" ]; then
        echo ">>> WordPress: エラー: MariaDB への接続がタイムアウトしました（${MAX_RETRY}回）"
        exit 1
    fi
    echo ">>> WordPress: MariaDB 待機中... (${RETRY}/${MAX_RETRY})"
    sleep 2
done

echo ">>> WordPress: MariaDB への接続に成功しました！"


if [ ! -f "${WP_PATH}/wp-includes/version.php" ]; then
    echo ">>> WordPress: コアファイルをダウンロードしています..."

    # --allow-root: rootユーザーとしての実行を許可
    # --locale=ja: 日本語版をダウンロード
    # --path: WordPressのインストール先ディレクトリ
    wp --allow-root core download \
        --path="${WP_PATH}" \
        --locale=ja

    echo ">>> WordPress: コアファイルのダウンロードが完了しました！"
else
    echo ">>> WordPress: コアファイルは既にダウンロード済みです。スキップします。"
fi

if [ ! -f "${WP_PATH}/wp-config.php" ]; then
    echo ">>> WordPress: wp-config.php を作成しています..."

    # --dbhost=mariadb: DockerネットワークのサービスであるMariaDBにコンテナ名で接続
    # --skip-check: この時点でまだWPのテーブルが存在しないためチェックをスキップ
    wp --allow-root config create \
        --path="${WP_PATH}" \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost=mariadb \
        --skip-check

    echo ">>> WordPress: wp-config.php の作成が完了しました！"
else
    echo ">>> WordPress: wp-config.php は既に存在します。スキップします。"
fi


if ! wp --allow-root core is-installed --path="${WP_PATH}" 2>/dev/null; then
    echo ">>> WordPress: インストールを実行しています..."

    # --url: サイトURL（HTTPS固定。nginxがSSLを終端するため）
    # --title: サイトのタイトル
    # --admin_user: 管理者ログイン名（"admin" および "Admin" は課題で禁止）
    # --skip-email: インストール完了メールを送信しない
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

    echo ">>> WordPress: インストールが完了しました！"
else
    echo ">>> WordPress: WordPress は既にインストール済みです。スキップします。"
fi


chown -R nobody:nobody "${WP_PATH}"

echo ">>> WordPress: php-fpm83 をフォアグラウンドで起動します..."

# exec: 現在のシェルプロセスを php-fpm83 に置き換える
# PID 1 が php-fpm83 になることで Docker の SIGTERM が正しく処理される
# -F: フォアグラウンドで実行（デーモン化しない）
# -R: root で実行することを許可（コンテナ環境での実行に必要）
exec php-fpm83 -F -R
