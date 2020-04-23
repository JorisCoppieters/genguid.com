#!/bin/bash
set -e # Bail on first error

PORT=4070

rm -rf dist/site
node build/format/format.js
(
    sleep 15;
    chrome http://127.0.0.1:$PORT
) &
webpack-dev-server --config build/webpack/site/webpack.dev.js --inline --hot --progress --port $PORT
