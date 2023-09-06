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

MODE="${1}"

ENV_TYPE="dev"
PERSIST_DATA="false"
RESPAWN="false"

TEST_HTTPS_PORT=$(get_test_https_port "${ENV_TYPE}" "${APP_PORT_IDX}")

install_certificates "${ENV_TYPE}" "${APP_HOST}" ""

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

sleep 3

launch_server \
    "${ENV_TYPE}" \
    "${APP_HOST}" \
    "${APP_PORT_IDX}" \
    "${PERSIST_DATA}" \
    "${RESPAWN}"

function _run_tests() {
    if [[ "${MODE}" == "ci" ]]; then
        ng e2e --webdriver-update=false --protractor-config "./src/tests/e2e/protractor.ci.conf.js" --port "${TEST_HTTPS_PORT}"
    else
        ng e2e --webdriver-update=false --port "${TEST_HTTPS_PORT}"
    fi
}

set +e

_run_tests

if [[ $? == 1 ]]; then
    alert_user "${APP_NAME}" "E2E tests failed for: ${ENV_TYPE}"
    echo -n "Press enter to try again..."; read
    _run_tests
fi

if [[ $? == 1 ]]; then
    set -e
    alert_user "${APP_NAME}" "E2E tests failed for: ${ENV_TYPE}"
    echo -n "Press enter to try again..."; read
    _run_tests
fi

set +e #Ignore errors

terminate_server \
    "${ENV_TYPE}" \
    "${APP_HOST}" \
    "${APP_PORT_IDX}"

set -e

restore_config

echo "Done!"
