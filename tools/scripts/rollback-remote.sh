#!/bin/bash
source ~/.bashrc
set -e # Bail on first error

ENV_TYPE="<ENV_TYPE>"
if [[ -z $ENV_TYPE ]]; then
    echo "ENV_TYPE not set"; exit -1;
fi

ENV_SERVICE_NAME="<ENV_SERVICE_NAME>"
if [[ -z $ENV_SERVICE_NAME ]]; then
    echo "ENV_SERVICE_NAME not set"; exit -1;
fi

SERVICES_DIR="<SERVICES_DIR>"
if [[ -z $SERVICES_DIR ]]; then
    echo "SERVICES_DIR not set"; exit -1;
fi

APP_NAME="<APP_NAME>"
if [[ -z $APP_NAME ]]; then
    echo "APP_NAME not set"; exit -1;
fi

MYSQL_APP_NAME=$(echo "${APP_NAME}" | sed 's/-//g')

MARKER="$1"
if [[ -z $MARKER ]]; then
    MARKER="PREVIOUS"
fi

SERVICES_BACKUP_FOLDER="${SERVICES_DIR}_backup"
SERVICE_BACKUPS=$(ls "${SERVICES_BACKUP_FOLDER}" | grep -E "${ENV_SERVICE_NAME}$")
if [[ ! ${SERVICE_BACKUPS} ]]; then
    echo "Service \"${ENV_SERVICE_NAME}\" has no backups"
    return;
fi

SERVICE_BACKUP=$(echo "${SERVICE_BACKUPS[@]}" | tail -n 1)
if [[ $MARKER != "PREVIOUS" ]]; then
    SERVICE_BACKUPS=$(ls "${SERVICES_BACKUP_FOLDER}" | grep -E "${ENV_SERVICE_NAME}$" | grep "${MARKER}")
    if [[ ! ${SERVICE_BACKUPS} ]]; then
        echo "Service \"${ENV_SERVICE_NAME}\" has no backup containing \"${MARKER}\""
        return;
    fi
    SERVICE_BACKUP=$(echo "${SERVICE_BACKUPS[@]}" | tail -n 1)
fi

SERVICE_FOLDER="${SERVICES_DIR}/${ENV_SERVICE_NAME}"

(
  cd "${SERVICE_FOLDER}";
  set +e
  ./stop.sh
  set -e
)

echo "Restoring: ${SERVICE_BACKUP}"
DATESTAMP=`date +"%Y-%m-%d-%H%M%S"`
mv "${SERVICE_FOLDER}" "${SERVICE_FOLDER}.rollback-${DATESTAMP}"
cp -r "${SERVICES_BACKUP_FOLDER}/${SERVICE_BACKUP}" "${SERVICE_FOLDER}"

(
  cd "${SERVICE_FOLDER}";
  ./start.sh
)
