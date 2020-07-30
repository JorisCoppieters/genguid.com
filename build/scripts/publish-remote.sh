#!/bin/bash

set -e # Bail on first error

ROOT_DIR="/home/ubuntu"
DOWNLOADS_DIR="$ROOT_DIR/downloads"; mkdir -p $DOWNLOADS_DIR
SITES_DIR="$ROOT_DIR/sites"; mkdir -p $SITES_DIR
SITES_BACKUP_DIR="$ROOT_DIR/sites_backup"; mkdir -p $SITES_BACKUP_DIR
CONF_DIR="$ROOT_DIR/conf"; mkdir -p $CONF_DIR

if [[ -d "$SITES_DIR/<ENV_HOST>/" ]]; then
  mv "$SITES_DIR/<ENV_HOST>/" "$SITES_BACKUP_DIR/<CURRENT_DATE_STAMP>_<ENV_HOST>"
fi

mkdir "$SITES_DIR/<ENV_HOST>"
cd "$SITES_DIR/<ENV_HOST>"

unzip "$DOWNLOADS_DIR/<DIST_ZIP>"
sudo chown -R www-data:www-data .
sudo chown www-data:ubuntu .

cd "$CONF_DIR"
rm -f unlink "<ENV_HOST>.conf"
mv "$SITES_DIR/<ENV_HOST>/http.conf" "<ENV_HOST>.conf"

rm -f "<ENV_HOST>-le-ssl.conf"
mv "$SITES_DIR/<ENV_HOST>/https.conf" "<ENV_HOST>-le-ssl.conf"

sudo a2ensite "<ENV_HOST>.conf" "<ENV_HOST>-le-ssl.conf"
sudo systemctl reload apache2

rm "$DOWNLOADS_DIR/<DIST_ZIP>"
rm "$DOWNLOADS_DIR/<REMOTE_SCRIPT>"
