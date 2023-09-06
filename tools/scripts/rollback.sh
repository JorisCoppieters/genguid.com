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

DIST_TYPE="rollback-app"
DIST_FOLDER="rollback-app"
REMOTE_SCRIPT="$(get_remote_script_name "${DIST_TYPE}" "${ENV_TYPE}" "${APP_NAME}" "${CURRENT_DATESTAMP}")"
DEPLOY_HOST="$(get_deloy_host "${ENV_TYPE}" "${APP_NAME}")"

DATA_DIR=$(get_script_data_dir "${ENV_TYPE}")
SERVICE_DATA_DIR="${DATA_DIR}/${SERVICE_NAME}"

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

alert_user "${APP_NAME}" "Starting rollback on ${ENV_TYPE_FULL} now..."

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

# set +x
echo ""
echo "#"
echo "# Zipping distribution & creating scripts"
echo "#"
echo ""
# set -x

cd "${DIST_FOLDER}"
cp -r "../tools/scripts/rollback-remote.sh" "${REMOTE_SCRIPT}"
_replace_vars "${REMOTE_SCRIPT}"
chmod +x "${REMOTE_SCRIPT}"
cd ../

if [[ "${ENV_TYPE}" != "dev" ]]; then
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

    scp -o ConnectTimeout=60 "${DIST_FOLDER}/${REMOTE_SCRIPT}" "${DEPLOY_HOST}":"downloads/"
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

    tag="rollback-${APP_NAME}-${ENV_TYPE}-${CURRENT_DATESTAMP}"
    git tag -a "$tag" -m "Rolled back ${ENV_TYPE_FULL} to previous version"
    git push origin "$tag"
fi

restore_config

alert_user "${APP_NAME}" "Rollback on ${ENV_TYPE_FULL} complete!"
