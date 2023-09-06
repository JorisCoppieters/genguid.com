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

DATA_DIR="<DATA_DIR>"
if [[ -z $DATA_DIR ]]; then
    echo "DATA_DIR not set"; exit -1;
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

FILTER="${ENV_SERVICE_NAME}$"
if [[ $ENV_TYPE == "prod" ]]; then
    FILTER="${ENV_SERVICE_NAME}.sql.gz$"
fi

DATA_BACKUP_FOLDER="${DATA_DIR}_backup"
set +e
DATA_BACKUPS=$(ls "${DATA_BACKUP_FOLDER}" | grep -E "${FILTER}")
set -e
if [[ ! ${DATA_BACKUPS} ]]; then
    echo "Service \"${ENV_SERVICE_NAME}\" has no data backups"; exit -1;
fi

DATA_BACKUP=$(echo "${DATA_BACKUPS[@]}" | tail -n 1)
if [[ $MARKER != "PREVIOUS" ]]; then
    set +e
    DATA_BACKUPS=$(ls "${DATA_BACKUP_FOLDER}" | grep -E "${FILTER}" | grep "${MARKER}")
    set -e
    if [[ ! ${DATA_BACKUPS} ]]; then
        echo "Service \"${ENV_SERVICE_NAME}\" has no data backup containing \"${MARKER}\""; exit -1;
    fi
    DATA_BACKUP=$(echo "${DATA_BACKUPS[@]}" | tail -n 1)
fi

(
  cd "${SERVICES_DIR}/${ENV_SERVICE_NAME}"
  ./backup-db.sh "rollback"
)

if [[ $APP_NAME == "my-save" ]] && [[ $ENV_TYPE == "prod" ]]; then
    GZIP_FILE="${DATA_BACKUP_FOLDER}/${DATA_BACKUP}"
    SQL_FILE=$(echo "${GZIP_FILE}" | sed 's/.gz//')
    gzip -k -f -d "$GZIP_FILE"
    echo "Restoring: ${SQL_FILE}"
    sudo mysql -u root "${MYSQL_APP_NAME}" -e "DROP DATABASE ${MYSQL_APP_NAME}; CREATE DATABASE ${MYSQL_APP_NAME}; GRANT ALL PRIVILEGES ON ${MYSQL_APP_NAME}.* TO 'db-user'@'localhost'; FLUSH PRIVILEGES;"
    sudo mysql -u db-user "${MYSQL_APP_NAME}" < "${SQL_FILE}"
    rm "${SQL_FILE}"
else
    echo "Restoring: ${DATA_BACKUP}"
    cp "${DATA_BACKUP_FOLDER}/${DATA_BACKUP}"/* "${DATA_DIR}/${ENV_SERVICE_NAME}"
fi
