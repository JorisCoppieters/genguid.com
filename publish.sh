#!/bin/bash

set -e # Bail on first error

DIST=dist-`date +"%Y-%m-%d-%H%M%S"`.zip
DEPLOY=deploy-`date +"%Y-%m-%d-%H%M%S"`.sh

echo "#"
echo "# Formatting files"
echo "#"

npm run format

echo "#"
echo "# Zipping distribution & creating scripts"
echo "#"

rm -rf dist
mkdir dist
cp -r \
    src/*.html \
    src/*.css \
    src/*.js \
    src/favicon.ico \
    src/webfonts \
    dist
cd dist
zip -r $DIST ./

cat <<EOF > $DEPLOY
rm -r "/root/websites/genguid.com/"*
cd "/root/websites/genguid.com"
unzip "/root/downloads/$DIST"
chown -R www-data:www-data .
rm "/root/downloads/$DIST"
rm "/root/downloads/$DEPLOY"
EOF

echo "#"
echo "# Uploading files"
echo "#"

scp $DIST $DEPLOY root@jorisweb.com:downloads/
ssh root@jorisweb.com chmod +x downloads/$DEPLOY

echo "#"
echo "# Executing remote script"
echo "#"

cat $DEPLOY
ssh root@jorisweb.com downloads/$DEPLOY

echo "#"
echo "# Cleaning up"
echo "#"

cd ../
rm -r dist
