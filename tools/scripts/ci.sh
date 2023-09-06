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
shift 1;

PERSIST_DATA="${1}"
shift 1;

RESPAWN="${1}"
shift 1;

CI_ARGS="$@"

ENV_HOST_PREFIX=$(get_env_host_prefix "${ENV_TYPE}")
ENV_HOST="${ENV_HOST_PREFIX}${APP_HOST}"

OS_TYPE=$(get_os_type)

install_certificates "${ENV_TYPE}" "${APP_HOST}" "INSTALL"
create_host_entries "${ENV_TYPE}" "${APP_HOST}"

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

if [[ -d "./src/ci" ]]; then
    launch_ci \
        "${PERSIST_DATA}" \
        "${RESPAWN}" \
        "${CI_ARGS}"
fi
