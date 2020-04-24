#!/bin/bash
set -e # Bail on first error

HOST=$npm_package_config_host
if [[ ! $HOST ]]; then echo "npm_package_config_host isn't set!"; exit -1; fi
DEV_HOST="dev.$HOST"

DEV_PORT=$npm_package_config_dev_port
if [[ ! $DEV_PORT ]]; then echo "npm_package_config_dev_port isn't set!"; exit -1; fi

HOSTS_FILE="C:/Windows/System32/drivers/etc/hosts"
CERTS_DIR="./src/_cert"
LOCALHOST_IP="127.0.0.1"

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

    echo "Installing certificate..."
    powershell ./build/scripts/install-cert.ps1 -certName:"$DEV_HOST certificate" -certPath:"$CERTS_DIR/$DEV_HOST.crt"
fi

set +e
CUR_IP=$(cat "$HOSTS_FILE" 2>/dev/null | grep " $DEV_HOST")
set -e
if [[ $CUR_IP != "$LOCALHOST_IP $DEV_HOST" ]]; then
    echo "Correcting host file entry..."
    sed -i 's/^[0-9.]\+\s\+'$DEV_HOST'\s*$//g' "$HOSTS_FILE"
    echo "$LOCALHOST_IP $DEV_HOST" >> "$HOSTS_FILE"

elif [[ ! $CUR_IP ]]; then
    echo "Adding host file entry..."
    echo "$LOCALHOST_IP $DEV_HOST" >> "$HOSTS_FILE"

fi

echo "Clearing dist folder..."
rm -rf dist

echo "Formatting code..."
node build/format/format.js

(
    sleep 15;
    chrome https://$DEV_HOST:$DEV_PORT
) &

echo "Building code..."
if [[ -f ./src/server/server.ts ]]; then
    APP_ENV_TYPE=Development ts-node-dev --respawn --no-notify ./src/server/server.ts &
    sleep 2
    webpack --config ./build/webpack/site/webpack.dev.js -w &

else
    webpack-dev-server \
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
