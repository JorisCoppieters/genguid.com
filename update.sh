#!/bin/bash

set -e # Bail on first error

#npm install -g npm-check-updates

echo "#"
echo "# Running npm-check-updates"
echo "#"

ncu -u

echo "#"
echo "# Running install"
echo "#"

npm install

echo "#"
echo "# Running audit fix"
echo "#"

npm audit fix

echo "#"
echo "# Running serve (dev)"
echo "#"

npm run serve
