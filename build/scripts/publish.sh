#!/bin/bash
set -e # Bail on first error
set -x # Print out all commands

HOST=$npm_package_config_host
if [[ ! $HOST ]]; then echo "npm_package_config_host isn't set!"; exit -1; fi

ENV=$1
if [[ ! $ENV ]]; then
    ENV="prod"
fi

if [[ $ENV == "test" ]]; then
  HOST="test.$HOST"
fi

CURRENT_DATE_STAMP=`date +"%Y-%m-%d-%H%M%S"`

SERVER_ADMIN="jobot.software@gmail.com"
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
  REPLACES='
    s/<ENV>/'$ENV'/g;
    s/<HOST>/'$HOST'/g;
    s/<CURRENT_DATE_STAMP>/'$CURRENT_DATE_STAMP'/g;
    s/<SERVER_ADMIN>/'$SERVER_ADMIN'/g;
    s/<DIST_ZIP>/'$DIST_ZIP'/g;
    s/<REMOTE_SCRIPT>/'$REMOTE_SCRIPT'/g;
  '

  if [[ $IS_MAC ]]; then
    cat $FILE | sed "$REPLACES" > $FILE.tmp
    mv $FILE.tmp $FILE
  else
    sed -i "$REPLACES" $FILE
  fi
}

set +x
echo ""
echo "#"
echo "# Cleaning up"
echo "#"
echo ""
set -x

rm -rf dist
npm run format

set +x
echo ""
echo "#"
echo "# Creating distribution"
echo "#"
echo ""
set -x

webpack_env=$ENV webpack --config build/webpack/site/webpack.$WEBPACK_CONFIG.js
cp -r \
    ./build/scripts/apache2/http.conf \
    ./build/scripts/apache2/https.conf \
    ./dist/site

replace_vars ./dist/site/http.conf
replace_vars ./dist/site/https.conf

if [[ $ENV != "dev" ]]; then

  set +x
  echo ""
  echo "#"
  echo "# Zipping distribution & creating scripts"
  echo "#"
  echo ""
  set -x

  cd ./dist/site

  zip -r $DIST_ZIP ./

  mv $DIST_ZIP ../
  cd ../

  cp -r ../build/scripts/publish-remote.sh $REMOTE_SCRIPT
  replace_vars $REMOTE_SCRIPT
  chmod +x $REMOTE_SCRIPT

  set +x
  echo ""
  echo "#"
  echo "# Executing remote script"
  echo "#"
  echo ""
  set -x

  scp $DIST_ZIP $REMOTE_SCRIPT jorisweb.com:downloads/
  ssh jorisweb.com chmod +x downloads/$REMOTE_SCRIPT

  cat $REMOTE_SCRIPT
  set +e
  ssh jorisweb.com downloads/$REMOTE_SCRIPT
  set -e

  set +x
  echo ""
  echo "#"
  echo "# Cleaning up"
  echo "#"
  echo ""
  set -x

  cd ../
  rm -r dist
fi
