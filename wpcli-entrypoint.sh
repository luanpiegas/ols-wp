#!/bin/sh
set -eu

WP_PATH="${WP_PATH:-/var/www/html}"
WP_URL="${WP_HOME:-http://${DOMAIN:-localhost}}"
WP_TITLE="${WP_SITE_TITLE:-WordPress}"
DB_WAIT_RETRIES="${DB_WAIT_RETRIES:-20}"

: "${WORDPRESS_DB_HOST:?WORDPRESS_DB_HOST is required}"
: "${WORDPRESS_DB_NAME:?WORDPRESS_DB_NAME is required}"
: "${WORDPRESS_DB_USER:?WORDPRESS_DB_USER is required}"
: "${WORDPRESS_DB_PASSWORD:?WORDPRESS_DB_PASSWORD is required}"
: "${WP_ADMIN_USER:?WP_ADMIN_USER is required}"
: "${WP_ADMIN_PASSWORD:?WP_ADMIN_PASSWORD is required}"
: "${WP_ADMIN_EMAIL:?WP_ADMIN_EMAIL is required}"

mkdir -p "${WP_PATH}"
cd "${WP_PATH}"

if [ ! -f wp-includes/version.php ]; then
  echo "Downloading WordPress core..."
  wp core download --allow-root
fi

if [ ! -f wp-config.php ]; then
  echo "Creating wp-config.php..."
  wp config create \
    --dbname="${WORDPRESS_DB_NAME}" \
    --dbuser="${WORDPRESS_DB_USER}" \
    --dbpass="${WORDPRESS_DB_PASSWORD}" \
    --dbhost="${WORDPRESS_DB_HOST}" \
    --skip-check \
    --allow-root
fi

echo "Syncing wp-config.php database settings..."
wp config set DB_NAME "${WORDPRESS_DB_NAME}" --type=constant --allow-root
wp config set DB_USER "${WORDPRESS_DB_USER}" --type=constant --allow-root
wp config set DB_PASSWORD "${WORDPRESS_DB_PASSWORD}" --type=constant --allow-root
wp config set DB_HOST "${WORDPRESS_DB_HOST}" --type=constant --allow-root

echo "Waiting for database..."
i=0
until wp db check --allow-root >/dev/null 2>&1; do
  i=$((i + 1))
  if [ "${i}" -ge "${DB_WAIT_RETRIES}" ]; then
    echo "Database check failed after ${DB_WAIT_RETRIES} attempts."
    wp db check --allow-root
    exit 1
  fi
  sleep 3
done

if ! wp core is-installed --allow-root >/dev/null 2>&1; then
  echo "Installing WordPress..."
  wp core install \
    --url="${WP_URL}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root
else
  echo "WordPress is already installed."
fi

wp option update home "${WP_URL}" --allow-root >/dev/null
wp option update siteurl "${WP_URL}" --allow-root >/dev/null

echo "WordPress bootstrap complete."
exec "$@"
