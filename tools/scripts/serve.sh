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

ENV_TYPE=$1
if [[ ! ${ENV_TYPE} ]]; then
    ENV_TYPE="dev"
fi

ENV_TYPE_FULL=$(get_env_type_full ${ENV_TYPE})

SOCKET_HTTPS_PORT=$(get_socket_https_port ${ENV_TYPE} ${APP_PORT_IDX})
WEB_HTTPS_PORT=$(get_web_https_port ${ENV_TYPE} ${APP_PORT_IDX})

ENV_HOST_PREFIX=$(get_env_host_prefix ${ENV_TYPE})
ENV_HOST="${ENV_HOST_PREFIX}${APP_HOST}"

OS_TYPE=$(get_os_type)

install_certificates ${ENV_TYPE} ${APP_HOST} "INSTALL"
create_host_entries ${ENV_TYPE} ${APP_HOST}

echo "Clearing dist folder..."
rm -rf dist

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

if [[ -d ./src/client/app ]]; then
    echo "Launching angular client..."
    yarn ng serve &
elif [[ -d ./src/client ]]; then
    echo "Launching client..."
    webpack_env="dev" yarn webpack-dev-server \
        --config tools/webpack/client/webpack.dev.js \
        --inline \
        --hot \
        --progress \
        --https \
        --key ./src/cert/${ENV_HOST}.key \
        --cert ./src/cert/${ENV_HOST}.crt \
        --host ${ENV_HOST} \
        --port ${WEB_HTTPS_PORT} &
elif [[ -d ./src ]]; then
    if [[ ${OS_TYPE} == "mac" ]]; then
        open -a "${CHROME}" ./src
    else
        "${CHROME}" ./src
    fi
fi

if [[ ${CHROME} ]]; then
    if [[ ${OS_TYPE} == "mac" ]]; then
        open -a "${CHROME}" https://${ENV_HOST}:${WEB_HTTPS_PORT}
    else
        "${CHROME}" https://${ENV_HOST}:${WEB_HTTPS_PORT}
    fi
fi

launch_server \
    "${ENV_TYPE}" \
    "${APP_HOST}" \
    "${APP_VERSION}" \
    "${APP_NAME}" \
    "${APP_PORT_IDX}" \
    "${APP_SERVER_MAIL_FROM}" \
    "${APP_GA_TRACKING_ID}" \
    "RESPAWN"

if [[ -d ./src/extension ]]; then
    echo "Launching extension..."
    node build/manifest/build.js
    webpack_env="dev" webpack --config ./tools/webpack/extension/webpack.dev.js -w &
fi

restore_config

echo "Done!"
