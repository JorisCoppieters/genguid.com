#!/bin/bash

set -e # Bail on first error

echo "#"
echo "# Formatting files"
echo "#"

npm run format

echo "#"
echo "# Running local server"
echo "#"

npm serve
