#!/bin/bash
set -e # Bail on first error

HOST=$npm_package_config_host
if [[ ! $HOST ]]; then echo "npm_package_config_host isn't set!"; exit -1; fi
DEV_HOST="dev.$HOST"

DEV_PORT=$npm_package_config_dev_port
if [[ ! $DEV_PORT ]]; then echo "npm_package_config_dev_port isn't set!"; exit -1; fi

CERTS_DIR="./src/_cert"
LOCALHOST_IP="127.0.0.1"

if [[ $IS_MAC ]]; then
    INSTALLED_CERT=$(security find-certificate -a -p -c "$DEV_HOST")
else
    INSTALLED_CERT="TODO"
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
        powershell ./build/scripts/install-cert.ps1 -certName:"$DEV_HOST certificate" -certPath:"$CERTS_DIR/$DEV_HOST.crt"
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

if [[ $CHROME ]]; then
    (
        sleep 15;
        if [[ $IS_MAC ]]; then
            open -a "$CHROME" https://$DEV_HOST:$DEV_PORT
        else
            "$CHROME" https://$DEV_HOST:$DEV_PORT
        fi
    ) &
fi

echo "Building code..."
if [[ -f ./src/server/server.ts ]]; then
    APP_ENV_TYPE=Development ts-node-dev --respawn --no-notify ./src/server/server.ts &
    webpack_env="dev" webpack --config ./build/webpack/site/webpack.dev.js -w

else
    webpack_env="dev" webpack-dev-server \
        --config build/webpack/site/webpack.dev.js \
        --https \
        --key ./src/_cert/$DEV_HOST.key \
        --cert ./src/_cert/$DEV_HOST.crt \
        --inline \
        --hot \
        --progress \
        --host $DEV_HOST \
        --port $DEV_PORT
fi
