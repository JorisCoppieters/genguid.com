#!/bin/bash
set -e # Bail on first error
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

APP_KEYWORDS=$npm_package_config_keywords
if [[ ! "${APP_KEYWORDS}" ]]; then echo "npm_package_config_keywords isn't set!"; exit -1; fi

APP_GA_TRACKING_ID=$npm_package_config_ga_tracking_id
if [[ ! "${APP_GA_TRACKING_ID}" ]]; then
    APP_GA_TRACKING_ID="TODO"
fi

#
# Optionals:
#

SERVICE_NAME=$npm_package_config_service_name
if [[ ! "${SERVICE_NAME}" ]]; then SERVICE_NAME=""; fi

APP_DESCRIPTION=$npm_package_config_description
if [[ ! "${APP_DESCRIPTION}" ]]; then APP_DESCRIPTION=""; fi

APP_TITLE=$npm_package_config_title
if [[ ! "${APP_TITLE}" ]]; then APP_TITLE=""; fi

APP_SLOGAN=$npm_package_config_slogan
if [[ ! "${APP_SLOGAN}" ]]; then APP_SLOGAN=""; fi

APP_SERVER_MAIL_FROM=$npm_package_config_server_mail_from
if [[ ! "${APP_SERVER_MAIL_FROM}" ]]; then APP_SERVER_MAIL_FROM="jobot.software@gmail.com"; fi

APP_ENQUIRIES_MAIL_TO=$npm_package_config_enquiries_mail_to
if [[ ! "${APP_ENQUIRIES_MAIL_TO}" ]]; then APP_ENQUIRIES_MAIL_TO="jobot.software@gmail.com"; fi

APP_GA_TRACKING_ID=$npm_package_config_ga_tracking_id
if [[ ! "${APP_GA_TRACKING_ID}" ]]; then APP_GA_TRACKING_ID=""; fi

APP_TRELLO_BOARD_ID=$npm_package_config_trello_board_id
if [[ ! "${APP_TRELLO_BOARD_ID}" ]]; then APP_TRELLO_BOARD_ID=""; fi

CODECOV_GRAPHING_TOKEN=$npm_package_config_codecov_graphing_token
if [[ ! "${CODECOV_GRAPHING_TOKEN}" ]]; then CODECOV_GRAPHING_TOKEN=""; fi

CODECOV_UPLOAD_TOKEN=$npm_package_config_codecov_upload_token
if [[ ! "${CODECOV_UPLOAD_TOKEN}" ]]; then CODECOV_UPLOAD_TOKEN=""; fi

ENV_TYPE=$(get_env_type "${1}")

DEV_HTTPS_PORT=$(get_https_port "dev" "${APP_PORT_IDX}")

ROOT_FOLDER="$(dirname "$0")/../.."

GITHUB_FOLDER="${ROOT_FOLDER}/.github"

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

CHECKS_FOR_RELEASE_FILE="${GITHUB_FOLDER}/workflows/checks-for-release.yml"
if [[ -f "${CHECKS_FOR_RELEASE_FILE}" ]]; then
    cat $CHECKS_FOR_RELEASE_FILE \
        | sed 's/APP_HOST:.*/APP_HOST: '$APP_HOST'/g' \
        > "$CHECKS_FOR_RELEASE_FILE.tmp"
    mv "$CHECKS_FOR_RELEASE_FILE.tmp" "$CHECKS_FOR_RELEASE_FILE"
fi

CODECOV_FILE="${ROOT_FOLDER}/codecov.yml"
if [[ -f "${CODECOV_FILE}" ]]; then
    if [[ ! "${CODECOV_UPLOAD_TOKEN}" ]]; then echo "CODECOV_UPLOAD_TOKEN isn't set!"; exit -1; fi

    cat $CODECOV_FILE \
        | sed 's/token:.*/token: '$CODECOV_UPLOAD_TOKEN'/' \
        > "$CODECOV_FILE.tmp"
    mv "$CODECOV_FILE.tmp" "$CODECOV_FILE"
fi

CHECK_PROD_SITE_FILE="${ROOT_FOLDER}/src/tests/check/prod-site/protractor.conf.js"
if [[ -f "${CHECK_PROD_SITE_FILE}" ]]; then
    cat $CHECK_PROD_SITE_FILE \
        | sed "s/baseUrl:.*/baseUrl: 'https:\/\/${APP_HOST}',/" \
        > "$CHECK_PROD_SITE_FILE.tmp"
    mv "$CHECK_PROD_SITE_FILE.tmp" "$CHECK_PROD_SITE_FILE"
fi

CHECK_TEST_SITE_FILE="${ROOT_FOLDER}/src/tests/check/test-site/protractor.conf.js"
if [[ -f "${CHECK_TEST_SITE_FILE}" ]]; then
    cat $CHECK_TEST_SITE_FILE \
        | sed "s/baseUrl:.*/baseUrl: 'https:\/\/test.${APP_HOST}',/" \
        > "$CHECK_TEST_SITE_FILE.tmp"
    mv "$CHECK_TEST_SITE_FILE.tmp" "$CHECK_TEST_SITE_FILE"
fi

README_FILE="${ROOT_FOLDER}/README.md"
if [[ -f "${README_FILE}" ]]; then
    if [[ ! "${APP_TRELLO_BOARD_ID}" ]]; then echo "APP_TRELLO_BOARD_ID isn't set!"; exit -1; fi
    if [[ ! "${CODECOV_GRAPHING_TOKEN}" ]]; then echo "CODECOV_GRAPHING_TOKEN isn't set!"; exit -1; fi
    if [[ ! "${CODECOV_UPLOAD_TOKEN}" ]]; then echo "CODECOV_UPLOAD_TOKEN isn't set!"; exit -1; fi

    REPOSITORY_URL="https://github.com/JorisCoppieters/${APP_NAME}"
    CODECOV_URL="https://codecov.io/gh/JorisCoppieters/${APP_NAME}"

    PIPELINE_BADGE="[![Pipeline](${REPOSITORY_URL}/workflows/Checks%20for%20release/badge.svg)](${REPOSITORY_URL}/actions?query=workflow%3A%22Checks+for+release%22)"
    PIPELINE_BADGE=$(echo "${PIPELINE_BADGE}" | sed 's/\//\\\//g')

    CODECOV_BADGE="[![codecov](${CODECOV_URL}/branch/release/graph/badge.svg?token=${CODECOV_GRAPHING_TOKEN})](${CODECOV_URL}/)"
    CODECOV_BADGE=$(echo "${CODECOV_BADGE}" | sed 's/\//\\\//g')

    TRELLO_LINK="https://trello.com/b/${APP_TRELLO_BOARD_ID}"
    TRELLO_LINK=$(echo "${TRELLO_LINK}" | sed 's/\//\\\//g')

    cat $README_FILE \
        | sed 's/<NAME>/'$APP_NAME'/g' \
        | sed 's/\[!\[Pipeline\].*/'$PIPELINE_BADGE'/g' \
        | sed 's/\[!\[codecov\].*/'$CODECOV_BADGE'/g' \
        | sed 's/https:\/\/trello\.com\/b\/.*/'$TRELLO_LINK'/g' \
        > "$README_FILE.tmp"
    mv "$README_FILE.tmp" "$README_FILE"
fi

INDEX_HTML_FILE="${ROOT_FOLDER}/src/client/index.html"
if [[ -f "${INDEX_HTML_FILE}" ]]; then
    if [[ ! "${APP_TITLE}" ]]; then echo "APP_TITLE isn't set!"; exit -1; fi
    if [[ ! "${APP_SLOGAN}" ]]; then echo "APP_SLOGAN isn't set!"; exit -1; fi
    if [[ ! "${APP_DESCRIPTION}" ]]; then echo "APP_DESCRIPTION isn't set!"; exit -1; fi

    APP_TITLE_AND_SLOGAN="$APP_SLOGAN | $APP_TITLE"

    I="            "
    cat $INDEX_HTML_FILE \
        | sed "s/gtag\/js[?]id=.*\"/gtag\/js?id=${APP_GA_TRACKING_ID}\"/" \
        | sed "s/gtag('config',.*);/gtag('config', '${APP_GA_TRACKING_ID}');/" \
        | sed "s/<title>.*<\/title>/<title>${APP_TITLE_AND_SLOGAN}<\/title>/g" \
        | sed -z "s/<meta\s*content=\"[^\"]*\"\s*name=\"description\">/<meta\n${I}content=\"${APP_DESCRIPTION}\"\n${I}name=\"description\">/" \
        | sed -z "s/<meta\s*content=\"[^\"]*\"\s*name=\"keywords\">/<meta\n${I}content=\"${APP_KEYWORDS}\"\n${I}name=\"keywords\">/" \
        > "$INDEX_HTML_FILE.tmp"
    mv "$INDEX_HTML_FILE.tmp" "$INDEX_HTML_FILE"
fi

ANGULAR_FILE="${ROOT_FOLDER}/angular.json"
if [[ -f "${ANGULAR_FILE}" ]]; then
    cat ${ANGULAR_FILE} \
        | jq -r '
            .projects.client.architect.serve.options=(
                .projects.client.architect.serve.options
                    | .host="dev.'${APP_HOST}'"
                    | .port='${DEV_HTTPS_PORT}'
                    | .sslCert="src/cert/dev.'${APP_HOST}'.crt"
                    | .sslKey="src/cert/dev.'${APP_HOST}'.key"
            )' \
        > "$ANGULAR_FILE.tmp"
    mv "$ANGULAR_FILE.tmp" "$ANGULAR_FILE"
fi

rm -f "$ROOT_FOLDER/npm-error.log"

echo "Done!"
