#!/bin/bash
set -e # Bail on first error
# set -x # Print out all commands
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

APP_TITLE=$npm_package_config_title
if [[ ! "${APP_TITLE}" ]]; then echo "npm_package_config_title isn't set!"; exit -1; fi

APP_SLOGAN=$npm_package_config_slogan
if [[ ! "${APP_SLOGAN}" ]]; then echo "npm_package_config_slogan isn't set!"; exit -1; fi

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
    APP_SERVER_MAIL_FROM="jobot.software@gmail.com"
fi

APP_ENQUIRIES_MAIL_TO=$npm_package_config_enquiries_mail_to
if [[ ! "${APP_ENQUIRIES_MAIL_TO}" ]]; then
    APP_ENQUIRIES_MAIL_TO="jobot.software@gmail.com"
fi

APP_GA_TRACKING_ID=$npm_package_config_ga_tracking_id
if [[ ! "${APP_GA_TRACKING_ID}" ]]; then
    APP_GA_TRACKING_ID=""
fi

APP_TRELLO_BOARD_ID=$npm_package_config_trello_board_id
if [[ ! "${APP_TRELLO_BOARD_ID}" ]]; then
    APP_TRELLO_BOARD_ID=""
fi

ENV_TYPE=$(get_env_type "${1}")
ENV_TYPE_FULL=$(get_env_type_full "${ENV_TYPE}")

CURRENT_DATESTAMP=$(get_current_date_stamp)

DIST_TYPE="deploy-app"
DIST_FOLDER="dist-app"
DIST_ZIP="$(get_dist_zip_name "${DIST_TYPE}" "${ENV_TYPE}" "${APP_NAME}" "${CURRENT_DATESTAMP}")"
REMOTE_SCRIPT="$(get_remote_script_name "${DIST_TYPE}" "${ENV_TYPE}" "${APP_NAME}" "${CURRENT_DATESTAMP}")"
DEPLOY_HOST="$(get_deloy_host "${ENV_TYPE}" "${APP_NAME}")"

DATA_DIR=$(get_script_data_dir "${ENV_TYPE}")
SERVICE_DATA_DIR="${DATA_DIR}/${SERVICE_NAME}"

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
        "${APP_NAME}" \
        "${APP_PORT_IDX}" \
        "${SERVICE_NAME}" \
        "${CURRENT_DATESTAMP}" \
        "${DIST_TYPE}"
}

alert_user "${APP_NAME}" "Starting deploy to ${ENV_TYPE_FULL} now..."

# set +x
echo ""
echo "#"
echo "# Cleaning up"
echo "#"
echo ""
# set -x

echo "Clearing dist folder..."
rm -rf "${DIST_FOLDER}"

# set +x
echo ""
echo "#"
echo "# Creating distribution"
echo "#"
echo ""
# set -x

set_config \
    "${ENV_TYPE}" \
    "${APP_HOST}" \
    "${APP_VERSION}" \
    "${APP_TITLE}" \
    "${APP_SLOGAN}" \
    "${APP_PORT_IDX}" \
    "${SERVICE_NAME}" \
    "${APP_SERVER_MAIL_FROM}" \
    "${APP_ENQUIRIES_MAIL_TO}" \
    "${APP_GA_TRACKING_ID}" \
    "${APP_TRELLO_BOARD_ID}"

mkdir -p "${DIST_FOLDER}"

if [[ -d "./src/server" ]]; then
    npx tsc --build "./tsconfig.json"
    mv "${DIST_FOLDER}" "dist-all"
    mkdir "${DIST_FOLDER}"
    mv "dist-all/server" "dist-all/ci" "dist-all/shared" "${DIST_FOLDER}"
    rm -rf "dist-all"

    cp "package.json" "${DIST_FOLDER}"
    cp "package-lock.json" "${DIST_FOLDER}"
    cp -r "./src/server/scripts/"* "${DIST_FOLDER}/"

    cd "${DIST_FOLDER}"
    for f in *.sh; do
        _replace_vars $f
    done

    if [[ -d "migration" ]]; then
        cd "migration"
        for f in *.sh; do
            _replace_vars $f
        done
        cd "../"
    fi

    cd "../"
fi

if [[ -d "./src/client/app" ]]; then
    if [[ "${ENV_TYPE}" == "prod" ]]; then
        npx ng build --configuration production
    elif [[ "${ENV_TYPE}" == "test" ]]; then
        npx ng build --configuration production
    else
        npx ng build --configuration development
    fi
elif [[ -d "./src/client" ]]; then
    WEBPACK_CONFIG=$(get_webpack_config "${ENV_TYPE}")
    webpack_env="${ENV_TYPE}" webpack --config "tools/webpack/client/webpack.${WEBPACK_CONFIG}.js"
    rm -f "${DIST_FOLDER}/client/"*.js.LICENSE.txt
elif [[ -d "./src" ]]; then
    mkdir -p "${DIST_FOLDER}"
    cp -r "src" "${DIST_FOLDER}/client"
fi

if [[ -d "./src/extension" ]]; then
    node "tools/manifest/build.js"
    WEBPACK_CONFIG=$(get_webpack_config "${ENV_TYPE}")
    webpack_env=$ENV_TYPE webpack --config "tools/webpack/extension/webpack.$WEBPACK_CONFIG.js"

    cd "${DIST_FOLDER}/extension"
    rm -f *.js.LICENSE.txt

    zip -r "$EXTENSION_ZIP" "."
    mv "$EXTENSION_ZIP" "../../"
    cd "../../"

    rm -rf "${DIST_FOLDER}/extension"
fi

cp -r \
    "./tools/scripts/apache2/http.conf" \
    "./tools/scripts/apache2/https.conf" \
    "${DIST_FOLDER}/client"

_replace_vars "${DIST_FOLDER}/client/http.conf"
_replace_vars "${DIST_FOLDER}/client/https.conf"

if [[ -f "src/assets/scripts/sw.js" ]]; then
    cp -r "src/assets/scripts/sw.js" "${DIST_FOLDER}/client"
fi

# sed -i '1s/^/<!DOCTYPE html>/' "${DIST_FOLDER}/client/index.html"
if [[ -d "src/assets" ]]; then
    mkdir -p "${DIST_FOLDER}/client/assets"
    cp -r "src/assets/"* "${DIST_FOLDER}/client/assets"
fi
if [[ -d "src/client/css" ]]; then
    mkdir -p "${DIST_FOLDER}/client/css"
    cp -r "src/client/css/"* "${DIST_FOLDER}/client/css"
fi

if [[ "${ENV_TYPE}" != "dev" ]]; then
    # set +x
    echo ""
    echo "#"
    echo "# Zipping distribution & creating scripts"
    echo "#"
    echo ""
    # set -x

    cd "${DIST_FOLDER}"
    zip -r "${DIST_ZIP}" *
    cp -r "../tools/scripts/deploy-remote.sh" "${REMOTE_SCRIPT}"
    _replace_vars "${REMOTE_SCRIPT}"
    chmod +x "${REMOTE_SCRIPT}"
    cd ../

    # set +x
    echo ""
    echo "#"
    echo "# Checking connection"
    echo "#"
    echo ""
    # set -x

    set +e

    ping -n 1 -w 1000 "${DEPLOY_HOST}" &> /dev/null

    if [[ $? == 1 ]]; then
        alert_user "${APP_NAME}" "Cannot connect to: ${DEPLOY_HOST}"
        echo -n "Press enter to continue..."; read
        ping -n 1 -w 1000 "${DEPLOY_HOST}" &> /dev/null
    fi

    if [[ $? == 1 ]]; then
        alert_user "${APP_NAME}" "Cannot connect to: ${DEPLOY_HOST}"
        echo -n "Press enter to continue..."; read
        ping -n 1 -w 1000 "${DEPLOY_HOST}" &> /dev/null
    fi

    if [[ $? == 1 ]]; then
        set -e
        alert_user "${APP_NAME}" "Cannot connect to: ${DEPLOY_HOST}"
        echo -n "Press enter to continue..."; read
        ping -n 1 -w 1000 "${DEPLOY_HOST}" &> /dev/null
    fi

    # set +x
    echo ""
    echo "#"
    echo "# Executing remote script"
    echo "#"
    echo ""
    # set -x

    scp -o ConnectTimeout=60 "${DIST_FOLDER}/${DIST_ZIP}" "${DIST_FOLDER}/${REMOTE_SCRIPT}" "${DEPLOY_HOST}":"downloads/"
    ssh -o ConnectTimeout=60 "${DEPLOY_HOST}" chmod +x "downloads/${REMOTE_SCRIPT}"

    cat "${DIST_FOLDER}/${REMOTE_SCRIPT}"
    set +e
    ssh -o ConnectTimeout=60 "${DEPLOY_HOST}" "downloads/${REMOTE_SCRIPT}"
    set -e

    # set +x
    echo ""
    echo "#"
    echo "# Check site"
    echo "#"
    echo ""
    # set -x

    if [[ "${ENV_TYPE}" == "prod" ]]; then
        sleep 30
    else
        sleep 5
    fi

    npm run "check:site" "${ENV_TYPE}"

    # set +x
    echo ""
    echo "#"
    echo "# Cleaning up"
    echo "#"
    echo ""
    # set -x

    rm -r "${DIST_FOLDER}"

    # set +x
    echo ""
    echo "#"
    echo "# Tag repository"
    echo "#"
    echo ""
    # set -x

    tag="deploy-${APP_NAME}-${ENV_TYPE}-${CURRENT_DATESTAMP}"
    git tag -a "$tag" -m "Deployed to ${ENV_TYPE_FULL}"
    git push origin "$tag"
fi

restore_config

# set +x
echo ""
echo "#"
echo "# Unzipping extension"
echo "#"
echo ""
# set -x

if [[ -f "${EXTENSION_ZIP}" ]]; then
    mkdir -p "${DIST_FOLDER}/extension"
    cd "${DIST_FOLDER}/extension"
    unzip "../../$EXTENSION_ZIP"
    cd "../../"

    mv "$EXTENSION_ZIP" "${DIST_FOLDER}/"
fi

alert_user "${APP_NAME}" "Deploy to ${ENV_TYPE_FULL} complete!"
