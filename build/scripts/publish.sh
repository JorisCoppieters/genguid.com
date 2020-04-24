#!/bin/bash
set -e # Bail on first error

ENV=$1
if [[ ! $ENV ]]; then
    ENV="prod"
fi

CURRENT_DATE_STAMP=`date +"%Y-%m-%d-%H%M%S"`

HOST="genguid.com"
SERVER_ADMIN="joris.coppieters@gmail.com"
DIST_ZIP="dist-$HOST-$CURRENT_DATE_STAMP.zip"
REMOTE_SCRIPT="deploy-$HOST-$CURRENT_DATE_STAMP.sh"

WEBPACK_CONFIG="prod"
if [[ $ENV == "dev" ]]; then
    WEBPACK_CONFIG="dev"
fi

function replace_vars () {
  if [[ $# -lt 1 ]]; then
    echo "Usage $0: [FILE]";
    return;
  fi
  FILE=$1
  sed -i '
    s/<HOST>/'$HOST'/g;
    s/<CURRENT_DATE_STAMP>/'$CURRENT_DATE_STAMP'/g;
    s/<SERVER_ADMIN>/'$SERVER_ADMIN'/g;
    s/<DIST_ZIP>/'$DIST_ZIP'/g;
    s/<REMOTE_SCRIPT>/'$REMOTE_SCRIPT'/g;
  ' $FILE
}

echo ""
echo "#"
echo "# Formatting files"
echo "#"
echo ""

npm run format

echo ""
echo "#"
echo "# Creating distribution"
echo "#"
echo ""

rm -rf ./dist
webpack --config build/webpack/site/webpack.$WEBPACK_CONFIG.js
cp -r \
    ./build/scripts/apache2/http.conf \
    ./build/scripts/apache2/https.conf \
    ./dist/site

replace_vars ./dist/site/http.conf
replace_vars ./dist/site/https.conf

if [[ $ENV != "dev" ]]; then

  echo ""
  echo "#"
  echo "# Zipping distribution & creating scripts"
  echo "#"
  echo ""

  cd dist/site
  zip -r $DIST_ZIP ./
  mv $DIST_ZIP ../
  cd ../

  cp -r ../build/scripts/publish-remote.sh $REMOTE_SCRIPT
  replace_vars $REMOTE_SCRIPT
  chmod +x $REMOTE_SCRIPT

  echo ""
  echo "#"
  echo "# Executing remote script"
  echo "#"
  echo ""

  scp $DIST_ZIP $REMOTE_SCRIPT jorisweb.com:downloads/
  ssh jorisweb.com chmod +x downloads/$REMOTE_SCRIPT

  cat $REMOTE_SCRIPT
  ssh jorisweb.com downloads/$REMOTE_SCRIPT

  echo ""
  echo "#"
  echo "# Cleaning up"
  echo "#"
  echo ""

  cd ../
  rm -r dist

fi
