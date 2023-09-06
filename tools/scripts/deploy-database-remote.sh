#!/bin/bash
source ~/.bashrc
set -e # Bail on first error

APP_NAME="<APP_NAME>"
CURRENT_DATESTAMP="<CURRENT_DATESTAMP>"
DIST_ZIP="<DIST_ZIP>"
ENV_HOST="<ENV_HOST>"
REMOTE_SCRIPT="<REMOTE_SCRIPT>"
ENV_SERVICE_NAME="<ENV_SERVICE_NAME>"
ENV_TYPE="<ENV_TYPE>"

ROOT_DIR="/home/ubuntu"
DOWNLOADS_DIR="${ROOT_DIR}/downloads"; mkdir -p "${DOWNLOADS_DIR}"
SITES_DIR="${ROOT_DIR}/sites"; mkdir -p "${SITES_DIR}"
SITES_BACKUP_DIR="${ROOT_DIR}/sites_backup"; mkdir -p "${SITES_BACKUP_DIR}"
SERVICES_DIR="${ROOT_DIR}/services"; mkdir -p "${SERVICES_DIR}"
SERVICES_BACKUP_DIR="${ROOT_DIR}/services_backup"; mkdir -p "${SERVICES_BACKUP_DIR}"
DATA_DIR="${ROOT_DIR}/data"; mkdir -p "${DATA_DIR}"
SERVICE_DATA_DIR="${DATA_DIR}/${ENV_SERVICE_NAME}"
CONF_DIR="${ROOT_DIR}/conf"; mkdir -p "${CONF_DIR}"
UNZIP_DIR="${DOWNLOADS_DIR}/${APP_NAME}-${ENV_TYPE}-tmp"

if [[ -d "${UNZIP_DIR}" ]]; then
  rm -rf "${UNZIP_DIR}"
fi
mkdir "${UNZIP_DIR}"
cd "${UNZIP_DIR}"
unzip "${DOWNLOADS_DIR}/${DIST_ZIP}"
chmod +x *.sh
cd ../

if [[ -d "${SERVICES_DIR}/${ENV_SERVICE_NAME}.db/" ]]; then
  mv "${SERVICES_DIR}/${ENV_SERVICE_NAME}.db/" "${SERVICES_BACKUP_DIR}/${CURRENT_DATESTAMP}_${ENV_SERVICE_NAME}.db"
fi

cd "${SERVICES_DIR}/${ENV_SERVICE_NAME}"
./backup-db.sh

mv "${UNZIP_DIR}" "${SERVICES_DIR}/${ENV_SERVICE_NAME}.db"
cd "${SERVICES_DIR}/${ENV_SERVICE_NAME}.db"

mkdir -p "${SERVICE_DATA_DIR}"
for s in *.sh; do
  done_file="${SERVICE_DATA_DIR}/${s}.done"
  if [[ ! -f "${done_file}" ]]; then
    ./${s}
    touch "${done_file}"
  fi;
done;

rm "${DOWNLOADS_DIR}/${DIST_ZIP}"
rm "${DOWNLOADS_DIR}/${REMOTE_SCRIPT}"
