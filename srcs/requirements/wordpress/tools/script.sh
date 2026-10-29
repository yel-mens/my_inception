#!/bin/sh

set -e

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

chmod +x wp-cli.phar

tries=0

until mariadb-admin ping \
    -h mariadb \
    -u"$DB_USER" \
    -p"$DB_PASSWORD" \
    --silent
do
    tries=$((tries + 1))

    if [ "$tries" -ge 30 ]; then
        echo "MariaDB unavailable"
        exit 1
    fi

    sleep 1
done

if [ ! -f wp-includes/version.php ]; then
    ./wp-cli.phar core download --allow-root
fi
if [ ! -f wp-config.php ]; then
    ./wp-cli.phar config create \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost=mariadb \
        --allow-root
fi
if ! ./wp-cli.phar core is-installed --allow-root; then
    ./wp-cli.phar core install \
        --url="https://yel-mens.42.fr" \
        --title="Inception" \
        --admin_user="$WP_USER" \
        --admin_password="$WP_PASS" \
        --admin_email="$WP_MAIL" \
        --allow-root
fi
if ! ./wp-cli.phar user get "$WP_USER2" --allow-root >/dev/null 2>&1; then
    ./wp-cli.phar user create \
        "$WP_USER2" \
        "$WP_MAIL2" \
        --role=editor \
        --user_pass="$WP_PASS2" \
        --allow-root
fi

exec "$@"
