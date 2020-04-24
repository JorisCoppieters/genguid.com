#!/bin/bash
set -e # Bail on first error

HOST="dev.genguid.com"
PORT=4070

rm -rf dist/site
node build/format/format.js
(
    sleep 15;
    chrome https://$HOST:$PORT
) &
webpack-dev-server \
    --config build/webpack/site/webpack.dev.js \
    --https \
    --key ./src/_cert/dev.genguid.com.key \
    --cert ./src/_cert/dev.genguid.com.crt \
    --inline \
    --hot \
    --progress \
    --host $HOST \
    --port $PORT
