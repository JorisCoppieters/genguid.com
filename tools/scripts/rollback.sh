#!/bin/bash
set -e # Bail on first error
set -x # Print out all commands
source "$(dirname $0)/_lib.sh"

#
# Required:
#

APP_NAME=$npm_package_name
if [[ ! "${APP_NAME}" ]]; then echo "npm_package_name isn't set!"; exit -1; fi

#
# Optionals:
#

SERVICE_NAME=$npm_package_config_service_name
if [[ ! "${SERVICE_NAME}" ]]; then
    SERVICE_NAME=""
fi

ENV_TYPE=$1
if [[ ! "${ENV_TYPE}" ]]; then
    ENV_TYPE="dev"
fi

ENV_TYPE_FULL=$(get_env_type_full "${ENV_TYPE}")

ENV_SERVICE_NAME=$(get_env_service_name "${ENV_TYPE}" "${SERVICE_NAME}")

CURRENT_DATE_STAMP=$(get_current_date_stamp)

if [[ "${ENV_TYPE}" != "dev" ]]; then
    set +x
    echo ""
    echo "#"
    echo "# Executing remote script"
    echo "#"
    echo ""
    set -x

    set +e
    ssh -o ConnectTimeout=60 services "scripts/rollback.sh" "${ENV_SERVICE_NAME}"
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
    echo "# Tag repository"
    echo "#"
    echo ""
    set -x

    tag="rollback-${APP_NAME}-${ENV_TYPE}-${CURRENT_DATE_STAMP}"
    git tag -a "$tag" -m "Rolled back ${ENV_TYPE_FULL} to previous version"
    git push origin "$tag"
fi
