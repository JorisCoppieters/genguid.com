#!/bin/bash

set -e # Bail on first error

DATE_STAMP=`date +"%Y-%m-%d-%H%M%S"`
DIST_ZIP="dist-$DATE_STAMP.zip"
DEPLOY_SCRIPT="deploy-$DATE_STAMP.sh"
BACKUP_DATE="$DATE_STAMP"
SITENAME="genguid.com"

echo "#"
echo "# Formatting files"
echo "#"

npm run format
cp src/index.html src/index.html.bak
cat src/index.html.bak | sed 's/href="\(\/.*\)"/href="\1?'$DATE_STAMP'"/g' > src/index.html;

echo "#"
echo "# Creating distribution"
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

echo "#"
echo "# Zipping distribution & creating scripts"
echo "#"

cd dist
zip -r $DIST_ZIP ./

echo "" > $DEPLOY_SCRIPT
echo "mv \"/home/ubuntu/sites/"$SITENAME"/\" \"/home/ubuntu/sites_backup/"$BACKUP_DATE"_"$SITENAME"\"" >> $DEPLOY_SCRIPT
echo "mkdir \"/home/ubuntu/sites/"$SITENAME"\"" >> $DEPLOY_SCRIPT
echo "cd \"/home/ubuntu/sites/"$SITENAME"\"" >> $DEPLOY_SCRIPT
echo "unzip \"/home/ubuntu/downloads/$DIST_ZIP\"" >> $DEPLOY_SCRIPT
echo "sudo chown -R www-data:www-data ." >> $DEPLOY_SCRIPT
echo "sudo chown www-data:ubuntu ." >> $DEPLOY_SCRIPT
echo "rm \"/home/ubuntu/downloads/$DIST_ZIP\"" >> $DEPLOY_SCRIPT
echo "rm \"/home/ubuntu/downloads/$DEPLOY_SCRIPT\"" >> $DEPLOY_SCRIPT

echo "#"
echo "# Uploading files"
echo "#"

scp $DIST_ZIP $DEPLOY_SCRIPT jorisweb.com:downloads/
ssh jorisweb.com chmod +x downloads/$DEPLOY_SCRIPT

echo "#"
echo "# Executing remote script"
echo "#"

cat $DEPLOY_SCRIPT
ssh jorisweb.com downloads/$DEPLOY_SCRIPT

echo "#"
echo "# Cleaning up"
echo "#"

cd ../
rm -r dist
mv src/index.html.bak src/index.html
