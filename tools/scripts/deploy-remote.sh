#!/bin/bash

set -e # Bail on first error
set -x # Print out all commands

APP_NAME="<APP_NAME>"
CURRENT_DATE_STAMP="<CURRENT_DATE_STAMP>"
DIST_ZIP="<DIST_ZIP>"
ENV_HOST="<ENV_HOST>"
REMOTE_SCRIPT="<REMOTE_SCRIPT>"
SERVICE_NAME="<SERVICE_NAME>"
ENV_TYPE="<ENV_TYPE>"

ROOT_DIR="/home/ubuntu"
DOWNLOADS_DIR="${ROOT_DIR}/downloads"; mkdir -p ${DOWNLOADS_DIR}
SITES_DIR="${ROOT_DIR}/sites"; mkdir -p ${SITES_DIR}
SITES_BACKUP_DIR="${ROOT_DIR}/sites_backup"; mkdir -p ${SITES_BACKUP_DIR}
SERVICES_DIR="${ROOT_DIR}/services"; mkdir -p ${SERVICES_DIR}
SERVICES_BACKUP_DIR="${ROOT_DIR}/services_backup"; mkdir -p ${SERVICES_BACKUP_DIR}
DATA_DIR="${ROOT_DIR}/data"; mkdir -p ${DATA_DIR}
DATA_BACKUP_DIR="${ROOT_DIR}/data_backup"; mkdir -p ${DATA_BACKUP_DIR}
CONF_DIR="${ROOT_DIR}/conf"; mkdir -p ${CONF_DIR}
UNZIP_DIR="${DOWNLOADS_DIR}/${APP_NAME}-${ENV_TYPE}-tmp"

if [[ -d ${UNZIP_DIR} ]]; then
  rm -rf ${UNZIP_DIR}
fi
mkdir ${UNZIP_DIR}
cd ${UNZIP_DIR}
unzip "${DOWNLOADS_DIR}/${DIST_ZIP}"

if [[ -d server ]]; then
  chmod +x *.sh
  ./install.sh

  if [[ -d "${SERVICES_DIR}/${SERVICE_NAME}/" ]]; then
    mv "${SERVICES_DIR}/${SERVICE_NAME}/" "${SERVICES_BACKUP_DIR}/${CURRENT_DATE_STAMP}_${SERVICE_NAME}"
  fi

  if [[ -d "${DATA_DIR}/${SERVICE_NAME}/" ]]; then
    cp -r "${DATA_DIR}/${SERVICE_NAME}/" "${DATA_BACKUP_DIR}/${CURRENT_DATE_STAMP}_${SERVICE_NAME}"
  fi

  cd ../
  mv ${UNZIP_DIR} "${SERVICES_DIR}/${SERVICE_NAME}"
  cd "${SERVICES_DIR}/${SERVICE_NAME}"
  ./start.sh

  cd "${CONF_DIR}"
  rm -f "${ENV_HOST}.conf"
  mv "${SERVICES_DIR}/${SERVICE_NAME}/client/http.conf" "${ENV_HOST}.conf"

  rm -f "${ENV_HOST}-le-ssl.conf"
  mv "${SERVICES_DIR}/${SERVICE_NAME}/client/https.conf" "${ENV_HOST}-le-ssl.conf"

elif [[ -d client ]]; then
  cd client
  sudo chown -R www-data:ubuntu .
  cd ../

  if [[ -d "${SITES_DIR}/${ENV_HOST}/" ]]; then
    mv "${SITES_DIR}/${ENV_HOST}/" "${SITES_BACKUP_DIR}/${CURRENT_DATE_STAMP}_${ENV_HOST}"
  fi

  mv client "${SITES_DIR}/${ENV_HOST}"

  cd "${CONF_DIR}"
  rm -f "${ENV_HOST}.conf"
  mv "${SITES_DIR}/${ENV_HOST}/http.conf" "${ENV_HOST}.conf"

  rm -f "${ENV_HOST}-le-ssl.conf"
  mv "${SITES_DIR}/${ENV_HOST}/https.conf" "${ENV_HOST}-le-ssl.conf"
else
  echo "Server or client not found in dist"
  exit -1;

fi

cd

sudo a2ensite "${ENV_HOST}.conf" "${ENV_HOST}-le-ssl.conf"
sudo systemctl reload apache2

rm "${DOWNLOADS_DIR}/${DIST_ZIP}"
rm "${DOWNLOADS_DIR}/${REMOTE_SCRIPT}"
