#!/usr/bin/env sh
set -e

echo "Fixing /var/run/php and /var/log permissions..."
mkdir -p /var/run/php /var/log
chown -R www-data:www-data /var/run/php /var/log
chmod -R 777 /var/run/php /var/log

echo "Fixing permissions..."
chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache
chmod -R 777 /var/www/storage /var/www/bootstrap/cache

if [ ! -z "$WWWUSER" ] && [ ! -z "$WWWGROUP" ]; then
    echo "Updating www-data UID/GID to $WWWUSER:$WWWGROUP..."
    apk add --no-cache shadow
    usermod -u "$WWWUSER" www-data
    groupmod -g "$WWWGROUP" www-data
fi

echo "Configuring Git safe directory..."
git config --global --add safe.directory /var/www

echo "Switching to www-data user..."
if command -v gosu > /dev/null; then
    exec gosu www-data "$@"
elif command -v su-exec > /dev/null; then
    exec su-exec www-data "$@"
else
    su - www-data -c "$@"
fi
