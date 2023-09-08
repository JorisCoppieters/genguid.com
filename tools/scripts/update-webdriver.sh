#!/bin/bash

version="115.0.5790.170"

platform="linux64"
if [[ $OS == "Windows_NT" ]]; then
    platform="win64"
fi

zip_name="chromedriver-${platform}"

curl -s "https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/${version}/${platform}/${zip_name}.zip" > "${zip_name}.zip"
unzip "${zip_name}.zip"
(
    cd "${zip_name}"
    zip ../chromedriver_${version}.zip *
)
rm -rf "${zip_name}" "${zip_name}.zip"
mkdir -p "node_modules/webdriver-manager/selenium/"
mv "chromedriver_${version}.zip" "node_modules/webdriver-manager/selenium/chromedriver_${version}.zip"
npx webdriver-manager update --versions.chrome=${version} -- --gecko=false