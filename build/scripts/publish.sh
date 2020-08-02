#!/bin/bash
set -e # Bail on first error
set -x # Print out all commands

HOST=$npm_package_config_host
if [[ ! $HOST ]]; then echo "npm_package_config_host isn't set!"; exit -1; fi

VERSION=$npm_package_version
if [[ ! $VERSION ]]; then echo "npm_package_version isn't set!"; exit -1; fi

NAME=$npm_package_name
if [[ ! $NAME ]]; then echo "npm_package_name isn't set!"; exit -1; fi

PORT_IDX=$npm_package_config_port_idx
if [[ ! $PORT_IDX ]]; then echo "npm_package_config_port_idx isn't set!"; exit -1; fi

ENV_TYPE=$1
if [[ ! $ENV_TYPE ]]; then
    ENV_TYPE="prod"
fi

ENV_TYPE_FULL="Production"
if [[ $ENV_TYPE == "test" ]]; then
    ENV_TYPE_FULL="Test"
elif [[ $ENV_TYPE == "dev" ]]; then
    ENV_TYPE_FULL="Development"
fi

ENV_HOST=$HOST
if [[ $ENV_TYPE == "test" ]]; then
    ENV_HOST="test.$ENV_HOST"
elif [[ $ENV_TYPE == "dev" ]]; then
    ENV_HOST="dev.$ENV_HOST"
fi

CURRENT_DATE_STAMP=`date +"%Y-%m-%d-%H%M%S"`

SERVER_ADMIN="jobot.software@gmail.com"
DIST_ZIP="dist-$ENV_HOST-$CURRENT_DATE_STAMP.zip"
REMOTE_SCRIPT="deploy-$ENV_HOST-$CURRENT_DATE_STAMP.sh"

WEBPACK_CONFIG="prod"
if [[ $ENV_TYPE == "dev" ]]; then
    WEBPACK_CONFIG="dev"
fi

function replace_vars () {
    if [[ $# -lt 1 ]]; then
        echo "Usage $0: [FILE]";
        return;
    fi
    FILE=$1
    sed -i '
        s/<APP_VERSION>/'$VERSION'/g;
        s/<APP_NAME>/'$NAME'/g;
        s/<APP_HOST>/'$HOST'/g;
        s/<APP_PORT_IDX>/'$PORT_IDX'/g;
        s/<APP_ENV_TYPE>/'$ENV_TYPE_FULL'/g;
        s/<ENV_HOST>/'$ENV_HOST'/g;
        s/<ENV_TYPE>/'$ENV_TYPE'/g;
        s/<ENV_TYPE_FULL>/'$ENV_TYPE_FULL'/g;
        s/<CURRENT_DATE_STAMP>/'$CURRENT_DATE_STAMP'/g;
        s/<SERVER_ADMIN>/'$SERVER_ADMIN'/g;
        s/<DIST_ZIP>/'$DIST_ZIP'/g;
        s/<REMOTE_SCRIPT>/'$REMOTE_SCRIPT'/g;
        s/<SOCKET_HTTP_PORT>/'$SOCKET_HTTP_PORT'/g;
    ' $FILE
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

if [[ -d ./src/client/app ]]; then
    (
        if [[ $ENV_TYPE == "prod" ]]; then
            ng build --prod
        elif [[ $ENV_TYPE == "test" ]]; then
            mv ./src/client/environments/environment.prod.ts ./src/client/environments/environment.prod.ts.bak
            mv ./src/client/environments/environment.test.ts ./src/client/environments/environment.prod.ts
            ng build --prod
            mv ./src/client/environments/environment.prod.ts ./src/client/environments/environment.test.ts
            mv ./src/client/environments/environment.prod.ts.bak ./src/client/environments/environment.prod.ts
        else
            ng build
        fi
    )
elif [[ -d ./src/client ]]; then
    webpack_env=$ENV_TYPE webpack --config build/webpack/client/webpack.$WEBPACK_CONFIG.js
    rm -f dist/client/*.js.LICENSE.txt
fi

cp -r \
    ./build/scripts/apache2/http.conf \
    ./build/scripts/apache2/https.conf \
    ./dist/client

replace_vars ./dist/client/http.conf
replace_vars ./dist/client/https.conf

if [[ $ENV_TYPE != "dev" ]]; then

    set +x
    echo ""
    echo "#"
    echo "# Zipping distribution & creating scripts"
    echo "#"
    echo ""
    set -x

    cd ./dist/client

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

    scp -o ConnectTimeout=60 $DIST_ZIP $REMOTE_SCRIPT jorisweb.com:downloads/
    ssh -o ConnectTimeout=60 jorisweb.com chmod +x downloads/$REMOTE_SCRIPT

    cat $REMOTE_SCRIPT
    set +e
    ssh -o ConnectTimeout=60 jorisweb.com downloads/$REMOTE_SCRIPT
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
