#!/bin/bash
set -e # Bail on first error
set -x # Print out all commands
source "$(dirname "$0")/_lib.sh"

#
# Required:
#

APP_HOST=$npm_package_config_host
if [[ ! "${APP_HOST}" ]]; then echo "npm_package_config_host isn't set!"; exit -1; fi

APP_VERSION=$npm_package_version
if [[ ! "${APP_VERSION}" ]]; then echo "npm_package_version isn't set!"; exit -1; fi

APP_NAME=$npm_package_name
if [[ ! "${APP_NAME}" ]]; then echo "npm_package_name isn't set!"; exit -1; fi

APP_PORT_IDX=$npm_package_config_port_idx
if [[ ! "${APP_PORT_IDX}" ]]; then echo "npm_package_config_port_idx isn't set!"; exit -1; fi

#
# Optionals:
#

SERVICE_NAME=$npm_package_config_service_name
if [[ ! "${SERVICE_NAME}" ]]; then
    SERVICE_NAME=""
fi

APP_SERVER_MAIL_FROM=$npm_package_config_server_mail_from
if [[ ! "${APP_SERVER_MAIL_FROM}" ]]; then
    APP_SERVER_MAIL_FROM="joris.bot@gmail.com"
fi

APP_ENQUIRIES_MAIL_TO=$npm_package_config_enquiries_mail_to
if [[ ! "${APP_ENQUIRIES_MAIL_TO}" ]]; then
    APP_ENQUIRIES_MAIL_TO="jobot.software@gmail.com"
fi

APP_GA_TRACKING_ID=$npm_package_config_ga_tracking_id
if [[ ! "${APP_GA_TRACKING_ID}" ]]; then
    APP_GA_TRACKING_ID=""
fi

ENV_TYPE=$1
if [[ ! "${ENV_TYPE}" ]]; then
    ENV_TYPE="dev"
fi

ENV_TYPE_FULL=$(get_env_type_full "${ENV_TYPE}")

CURRENT_DATE_STAMP=$(get_current_date_stamp)

DIST_ZIP="$(get_dist_zip_name "${ENV_TYPE}" "${APP_NAME}" "${CURRENT_DATE_STAMP}")"
REMOTE_SCRIPT="$(get_remote_script_name "${ENV_TYPE}" "${APP_NAME}" "${CURRENT_DATE_STAMP}")"

DEPLOY_HOST="services.jobot-software.com"

EXTENSION_ZIP="${APP_NAME}-extension-latest.zip"

function _replace_vars () {
    if [[ $# -lt 1 ]]; then
        echo "Usage $0: [FILE]";
        return;
    fi

    local FILE=$1
    replace_vars \
        "${FILE}" \
        "${ENV_TYPE}" \
        "${APP_HOST}" \
        "${APP_VERSION}" \
        "${APP_NAME}" \
        "${APP_PORT_IDX}" \
        "${SERVICE_NAME}" \
        "${APP_SERVER_MAIL_FROM}" \
        "${APP_GA_TRACKING_ID}" \
        "${CURRENT_DATE_STAMP}"
}

set +x
echo ""
echo "#"
echo "# Cleaning up"
echo "#"
echo ""
set -x

echo "Clearing dist folder..."
rm -rf dist

set +x
echo ""
echo "#"
echo "# Creating distribution"
echo "#"
echo ""
set -x

if [[ -d "./src/extension" ]]; then
    PROP_BAK_FILE="src/extension/_env/properties.bak.json"
    PROP_ENV_FILE="src/extension/_env/properties.${ENV_TYPE}.json"
    PROP_FILE="src/extension/_env/properties.json"

    if [[ -f "${PROP_BAK_FILE}" ]]; then
        mv "${PROP_BAK_FILE}" "${PROP_FILE}"
    fi

    mv "${PROP_FILE}" "${PROP_BAK_FILE}"
    cp "${PROP_ENV_FILE}" "${PROP_FILE}"
fi

if [[ -d "./src/server" ]]; then
    yarn tsc --build "./tsconfig.json"
    mv "dist" "dist-all"
    mkdir "dist"
    mv "dist-all/server" "dist-all/shared" "dist"
    rm -rf "dist-all"

    cp "package.json" "./dist"
    cp "yarn.lock" "./dist"
    cp "./src/server/scripts/install.sh" "./dist/"
    cp "./src/server/scripts/start.sh" "./dist/"
    cp "./src/server/scripts/stop.sh" "./dist/"

    cd "dist"
    _replace_vars install.sh
    _replace_vars start.sh
    _replace_vars stop.sh
    cd "../"
fi

set_config \
    "${ENV_TYPE}" \
    "${APP_HOST}" \
    "${APP_VERSION}" \
    "${APP_NAME}" \
    "${APP_PORT_IDX}" \
    "${SERVICE_NAME}" \
    "${APP_SERVER_MAIL_FROM}" \
    "${APP_ENQUIRIES_MAIL_TO}" \
    "${APP_GA_TRACKING_ID}"

if [[ -d "./src/client/app" ]]; then
    if [[ "${ENV_TYPE}" == "prod" ]]; then
        yarn ng build --prod
    elif [[ "${ENV_TYPE}" == "test" ]]; then
        yarn ng build --prod
    else
        yarn ng build
    fi
elif [[ -d "./src/client" ]]; then
    WEBPACK_CONFIG=$(get_webpack_config "${ENV_TYPE}")
    webpack_env="${ENV_TYPE}" webpack --config "tools/webpack/client/webpack.${WEBPACK_CONFIG}.js"
    rm -f dist/client/*.js.LICENSE.txt
elif [[ -d "./src" ]]; then
    mkdir -p "dist"
    cp -r "src" "dist/client"
fi

if [[ -d "./src/extension" ]]; then
    node "tools/manifest/build.js"
    WEBPACK_CONFIG=$(get_webpack_config "${ENV_TYPE}")
    webpack_env=$ENV_TYPE webpack --config "tools/webpack/extension/webpack.$WEBPACK_CONFIG.js"

    cd "./dist/extension"
    rm -f *.js.LICENSE.txt

    zip -r "$EXTENSION_ZIP" "."
    mv "$EXTENSION_ZIP" "../../"
    cd "../../"

    rm -rf "./dist/extension"

    mv "$PROP_BAK_FILE" "$PROP_FILE"
fi

cp -r \
    "./tools/scripts/apache2/http.conf" \
    "./tools/scripts/apache2/https.conf" \
    "./dist/client"

_replace_vars "./dist/client/http.conf"
_replace_vars "./dist/client/https.conf"

if [[ -f "src/assets/scripts/sw.js" ]]; then
    cp -r "src/assets/scripts/sw.js" "./dist/client"
fi

set +x
echo ""
echo "#"
echo "# Zipping distribution & creating scripts"
echo "#"
echo ""
set -x

cd "./dist"
zip -r "${DIST_ZIP}" *
cp -r "../tools/scripts/deploy-remote.sh" "${REMOTE_SCRIPT}"
_replace_vars "${REMOTE_SCRIPT}"
chmod +x "${REMOTE_SCRIPT}"
cd ../

if [[ "${ENV_TYPE}" != "dev" ]]; then
    set +x
    echo ""
    echo "#"
    echo "# Executing remote script"
    echo "#"
    echo ""
    set -x

    scp -o ConnectTimeout=60 "dist/${DIST_ZIP}" "dist/${REMOTE_SCRIPT}" "${DEPLOY_HOST}":"downloads/"
    ssh -o ConnectTimeout=60 "${DEPLOY_HOST}" chmod +x "downloads/${REMOTE_SCRIPT}"

    cat "dist/${REMOTE_SCRIPT}"
    set +e
    ssh -o ConnectTimeout=60 "${DEPLOY_HOST}" "downloads/${REMOTE_SCRIPT}"
    set -e

    set +x
    echo ""
    echo "#"
    echo "# Check site"
    echo "#"
    echo ""
    set -x

    yarn run "check:site:${ENV_TYPE}"

    set +x
    echo ""
    echo "#"
    echo "# Cleaning up"
    echo "#"
    echo ""
    set -x

    rm -r "dist"

    set +x
    echo ""
    echo "#"
    echo "# Tag repository"
    echo "#"
    echo ""
    set -x

    tag="deploy-${APP_NAME}-${ENV_TYPE}-${CURRENT_DATE_STAMP}"
    git tag -a "$tag" -m "Deployed to ${ENV_TYPE_FULL}"
    git push origin "$tag"
fi

set +x
echo ""
echo "#"
echo "# Unzipping extension"
echo "#"
echo ""
set -x

restore_config

if [[ -f "${EXTENSION_ZIP}" ]]; then
    mkdir -p "dist/extension"
    cd "dist/extension"
    unzip "../../$EXTENSION_ZIP"
    cd "../../"

    mv "$EXTENSION_ZIP" "dist/"
fi
