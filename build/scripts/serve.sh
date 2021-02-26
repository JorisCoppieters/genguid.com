#!/bin/bash
set -e # Bail on first error
set -x

#
# Required:
#

HOST=$npm_package_config_host
if [[ ! $HOST ]]; then echo "npm_package_config_host isn't set!"; exit -1; fi

VERSION=$npm_package_version
if [[ ! $VERSION ]]; then echo "npm_package_version isn't set!"; exit -1; fi

NAME=$npm_package_name
if [[ ! $NAME ]]; then echo "npm_package_name isn't set!"; exit -1; fi

PORT_IDX=$npm_package_config_port_idx
if [[ ! $PORT_IDX ]]; then echo "npm_package_config_port_idx isn't set!"; exit -1; fi

#
# Optionals:
#

APP_SERVER_MAIL_FROM=$npm_package_config_server_mail_from
if [[ ! $APP_SERVER_MAIL_FROM ]]; then
    APP_SERVER_MAIL_FROM="joris.bot@gmail.com"
fi

APP_GA_TRACKING_ID=$npm_package_config_ga_tracking_id
if [[ ! $APP_GA_TRACKING_ID ]]; then
    APP_GA_TRACKING_ID=""
fi

ENV_TYPE_FULL="Development"
DEV_HOST="dev.$HOST"
DEV_HTTPS_PORT=$(( 9000 + $PORT_IDX * 10 + 1 ))

ROOT_DIR=$(pwd | sed 's/^\/cygdrive\/c/C:/; s/^\/c/C:/')
CERTS_DIR="$ROOT_DIR/src/_cert"
LOCALHOST_IP="127.0.0.1"

if [[ $IS_MAC ]]; then
    INSTALLED_CERT=$(security find-certificate -a -p -c "$DEV_HOST")
else
    INSTALLED_CERT=$(powershell -f $ROOT_DIR/build/scripts/find-cert.ps1 -certName:"$DEV_HOST certificate" -certPath:"$CERTS_DIR/$DEV_HOST.crt")
fi

if [[ ! -f "src/_cert/$DEV_HOST.crt" ]]; then
    echo "Creating certificate..."
    mkdir -p $CERTS_DIR
    rm -f "$CERTS_DIR/$DEV_HOST.key" "$CERTS_DIR/$DEV_HOST.crt"

    #TODO improve this
    cat > "$CERTS_DIR/$DEV_HOST.conf" <<EOF
[req]
x509_extensions = v3_req
distinguished_name = dn
[dn]
countryName                 = New Zealand
countryName_default         = NZ
stateOrProvinceName         = Wellington
stateOrProvinceName_default = WEL
localityName                = Business
localityName_default        = Jobot Software
commonName                  = Common Name
commonName_default          = $DEV_HOST
[v3_req]
subjectAltName = @alt_names
[alt_names]
DNS.1 = localhost
DNS.2 = *.localhost
DNS.3 = $DEV_HOST
DNS.4 = *.$DEV_HOST
EOF

    openssl req \
        -new \
        -x509 \
        -sha256 \
        -newkey rsa:2048 \
        -nodes \
        -keyout "$CERTS_DIR/$DEV_HOST.key" \
        -days 3650 \
        -out "$CERTS_DIR/$DEV_HOST.crt" \
        -config "$CERTS_DIR/$DEV_HOST.conf"

    rm -f "$CERTS_DIR/$DEV_HOST.conf"

    INSTALLED_CERT=""
fi

if [[ ! $INSTALLED_CERT ]]; then
    echo "Installing certificate..."
    if [[ $IS_MAC ]]; then
        FOUND_CERT=$(security find-certificate -a -p -c "$DEV_HOST")
        if [[ $FOUND_CERT ]]; then
            sudo security delete-certificate -c "$DEV_HOST"
        fi
        sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$CERTS_DIR/$DEV_HOST.crt"
    else
        powershell -f $ROOT_DIR/build/scripts/install-cert.ps1 -certName:"$DEV_HOST certificate" -certPath:"$CERTS_DIR/$DEV_HOST.crt"
    fi
fi

if [[ -f $HOSTS_FILE ]]; then
    set +e
    CUR_IP=$(cat "$HOSTS_FILE" 2>/dev/null | grep " $DEV_HOST")
    set -e

    if [[ ! $CUR_IP ]]; then
        if [[ $IS_MAC ]]; then
            sudo chmod g+w "$HOSTS_FILE"
        fi

        echo "Adding host file entry..."
        echo "$LOCALHOST_IP $DEV_HOST" >> "$HOSTS_FILE"

    elif [[ $CUR_IP != "$LOCALHOST_IP $DEV_HOST" ]]; then
        if [[ $IS_MAC ]]; then
            sudo chmod g+w "$HOSTS_FILE"
        fi

        echo "Correcting host file entry..."
        sed -i 's/^[0-9.]\+\s\+'$DEV_HOST'\s*$//g' "$HOSTS_FILE"
        echo "$LOCALHOST_IP $DEV_HOST" >> "$HOSTS_FILE"
    fi
fi

echo "Clearing dist folder..."
rm -rf dist

echo "Formatting code..."
node build/format/format.js

if [[ -d ./src/client/app ]]; then
    echo "Launching angular client..."
    ng serve &
elif [[ -d ./src/client ]]; then
    echo "Launching client..."
    webpack_env="dev" yarn webpack-dev-server \
        --config build/webpack/client/webpack.dev.js \
        --https \
        --key ./src/_cert/$DEV_HOST.key \
        --cert ./src/_cert/$DEV_HOST.crt \
        --inline \
        --hot \
        --progress \
        --host $DEV_HOST \
        --port $DEV_HTTPS_PORT &
fi

if [[ $CHROME ]]; then
    if [[ $IS_MAC ]]; then
        open -a "$CHROME" https://$DEV_HOST:$DEV_HTTPS_PORT
    else
        "$CHROME" https://$DEV_HOST:$DEV_HTTPS_PORT
    fi
fi

if [[ -d ./src/server ]]; then
    echo "Launching server..."
    APP_VERSION=$VERSION \
    APP_NAME=$NAME \
    APP_HOST=$HOST \
    APP_PORT_IDX=$PORT_IDX \
    APP_ENV_TYPE=$ENV_TYPE_FULL \
    APP_SERVER_MAIL_FROM=$APP_SERVER_MAIL_FROM \
    APP_GA_TRACKING_ID=$APP_GA_TRACKING_ID \
    ts-node-dev --respawn --no-notify ./src/server/server.ts &
fi

if [[ -d ./src/extension ]]; then
    echo "Launching extension..."
    node build/manifest/build.js
    webpack_env="dev" webpack --config ./build/webpack/extension/webpack.dev.js -w &
fi

echo "Done!"
