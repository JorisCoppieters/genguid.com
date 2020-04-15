#!/bin/bash

set -e # Bail on first error

ROOT_DIR="/home/ubuntu"
DOWNLOADS_DIR="$ROOT_DIR/downloads"; mkdir -p $DOWNLOADS_DIR
SITES_DIR="$ROOT_DIR/sites"; mkdir -p $SITES_DIR
SITES_BACKUP_DIR="$ROOT_DIR/sites_backup"; mkdir -p $SITES_BACKUP_DIR
CONF_DIR="$ROOT_DIR/conf"; mkdir -p $CONF_DIR

if [[ -d "$SITES_DIR/<HOST>/" ]]; then
  mv "$SITES_DIR/<HOST>/" "$SITES_BACKUP_DIR/<CURRENT_DATE_STAMP>_<HOST>"
fi

mkdir "$SITES_DIR/<HOST>"
cd "$SITES_DIR/<HOST>"

unzip "$DOWNLOADS_DIR/<DIST_ZIP>"
sudo chown -R www-data:www-data .
sudo chown www-data:ubuntu .

cd "$CONF_DIR"
rm -f unlink "<HOST>.conf"
mv "$SITES_DIR/<HOST>/http.conf" "<HOST>.conf"

rm -f "<HOST>-le-ssl.conf"
mv "$SITES_DIR/<HOST>/https.conf" "<HOST>-le-ssl.conf"

sudo a2ensite "<HOST>.conf" "<HOST>-le-ssl.conf"
sudo systemctl reload apache2

rm "$DOWNLOADS_DIR/<DIST_ZIP>"
rm "$DOWNLOADS_DIR/<REMOTE_SCRIPT>"
