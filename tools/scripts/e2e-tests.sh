#!/bin/bash
set -e # Bail on first error
set -x # Print out all commands
source "$(dirname $0)/_lib.sh"

#
# Required:
#

APP_HOST=$npm_package_config_host
if [[ ! ${APP_HOST} ]]; then echo "npm_package_config_host isn't set!"; exit -1; fi

APP_VERSION=$npm_package_version
if [[ ! ${APP_VERSION} ]]; then echo "npm_package_version isn't set!"; exit -1; fi

APP_NAME=$npm_package_name
if [[ ! ${APP_NAME} ]]; then echo "npm_package_name isn't set!"; exit -1; fi

APP_PORT_IDX=$npm_package_config_port_idx
if [[ ! ${APP_PORT_IDX} ]]; then echo "npm_package_config_port_idx isn't set!"; exit -1; fi

#
# Optionals:
#

SERVICE_NAME=$npm_package_config_service_name
if [[ ! ${SERVICE_NAME} ]]; then
    SERVICE_NAME=""
fi

APP_SERVER_MAIL_FROM=$npm_package_config_server_mail_from
if [[ ! ${APP_SERVER_MAIL_FROM} ]]; then
    APP_SERVER_MAIL_FROM="joris.bot@gmail.com"
fi

APP_ENQUIRIES_MAIL_TO=$npm_package_config_enquiries_mail_to
if [[ ! ${APP_ENQUIRIES_MAIL_TO} ]]; then
    APP_ENQUIRIES_MAIL_TO="jobot.software@gmail.com"
fi

APP_GA_TRACKING_ID=$npm_package_config_ga_tracking_id
if [[ ! ${APP_GA_TRACKING_ID} ]]; then
    APP_GA_TRACKING_ID=""
fi

MODE="${1}"

ENV_TYPE="dev"
ENV_TYPE_FULL=$(get_env_type_full ${ENV_TYPE})

SOCKET_HTTPS_PORT=$(get_socket_https_port ${ENV_TYPE} ${APP_PORT_IDX})

ENV_HOST_PREFIX=$(get_env_host_prefix ${ENV_TYPE})
ENV_HOST="${ENV_HOST_PREFIX}${APP_HOST}"

PORT=$(get_web_test_port ${ENV_TYPE} ${APP_PORT_IDX})

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

launch_server \
    "${ENV_TYPE}" \
    "${APP_HOST}" \
    "${APP_VERSION}" \
    "${APP_NAME}" \
    "${APP_PORT_IDX}" \
    "${APP_SERVER_MAIL_FROM}" \
    "${APP_GA_TRACKING_ID}" \
    ""

if [[ "${MODE}" == "ci" ]]; then
    ng e2e --protractor-config ./src/tests/e2e/protractor.ci.conf.js --port "${PORT}"
else
    ng e2e --port "${PORT}"
fi

terminate_server \
    "${ENV_TYPE}" \
    "${APP_HOST}" \
    "${APP_PORT_IDX}"

restore_config

echo "Done!"
