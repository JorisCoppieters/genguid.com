##################################################

function get_webpack_config () {
  if [[ $# -lt 1 ]]; then
    echo "Usage: get_webpack_config [ENV_TYPE]";
    exit 1;
  fi

  local ENV_TYPE="${1}"

  local WEBPACK_CONFIG="dev"
  if [[ ${ENV_TYPE} == "test" ]]; then
    local WEBPACK_CONFIG="prod"
  elif [[ ${ENV_TYPE} == "prod" ]]; then
    local WEBPACK_CONFIG="prod"
  fi

  echo -n "${WEBPACK_CONFIG}"
}

##################################################

function get_env_type_full () {
  if [[ $# -lt 1 ]]; then
    echo "Usage: get_env_type_full [ENV_TYPE]";
    exit 1;
  fi

  local ENV_TYPE="${1}"

  local ENV_TYPE_FULL="Development"
  if [[ ${ENV_TYPE} == "test" ]]; then
    local ENV_TYPE_FULL="Test"
  elif [[ ${ENV_TYPE} == "prod" ]]; then
    local ENV_TYPE_FULL="Production"
  fi

  echo -n "${ENV_TYPE_FULL}"
}

##################################################

function get_env_host_prefix () {
  if [[ $# -lt 1 ]]; then
    echo "Usage: get_env_host_prefix [ENV_TYPE]";
    exit 1;
  fi

  local ENV_TYPE="${1}"

  local ENV_HOST_PREFIX="dev."
  if [[ ${ENV_TYPE} == "test" ]]; then
    local ENV_HOST_PREFIX="test."
  elif [[ ${ENV_TYPE} == "prod" ]]; then
    local ENV_HOST_PREFIX=""
  fi

  echo -n "${ENV_HOST_PREFIX}"
}

##################################################

function get_env_service_name () {
  if [[ $# -lt 2 ]]; then
    echo "Usage: get_env_service_name [ENV_TYPE] [SERVICE_NAME]";
    exit 1;
  fi

  local ENV_TYPE="${1}"
  local SERVICE_NAME="${2}"

  local ENV_SERVICE_NAME="dev.${SERVICE_NAME}"
  if [[ ${SERVICE_NAME} ]]; then
    if [[ ${ENV_TYPE} == "test" ]]; then
      local ENV_SERVICE_NAME="test.${SERVICE_NAME}"
    elif [[ ${ENV_TYPE} == "prod" ]]; then
      local ENV_SERVICE_NAME="${SERVICE_NAME}"
    fi
  fi

  echo -n "${ENV_SERVICE_NAME}"
}

##################################################

function get_socket_http_port () {
  if [[ $# -lt 2 ]]; then
    echo "Usage: get_socket_http_port [ENV_TYPE] [APP_PORT_IDX]";
    exit 1;
  fi

  local ENV_TYPE="${1}"
  local APP_PORT_IDX="${2}"

  local SOCKET_HTTP_PORT="$(( 8000 + $APP_PORT_IDX * 10 ))"
  if [[ ${ENV_TYPE} == "test" ]]; then
    local SOCKET_HTTP_PORT="$(( 6000 + $APP_PORT_IDX * 10 ))"
  elif [[ ${ENV_TYPE} == "prod" ]]; then
    local SOCKET_HTTP_PORT="$(( 4000 + $APP_PORT_IDX * 10 ))"
  fi

  echo -n "${SOCKET_HTTP_PORT}"
}

##################################################

function get_socket_https_port () {
  if [[ $# -lt 2 ]]; then
    echo "Usage: get_socket_https_port [ENV_TYPE] [APP_PORT_IDX]";
    exit 1;
  fi

  local ENV_TYPE="${1}"
  local APP_PORT_IDX="${2}"

  local SOCKET_HTTPS_PORT="$(( 8000 + $APP_PORT_IDX * 10 + 1 ))"
  if [[ ${ENV_TYPE} == "test" ]]; then
    local SOCKET_HTTPS_PORT="$(( 6000 + $APP_PORT_IDX * 10 + 1 ))"
  elif [[ ${ENV_TYPE} == "prod" ]]; then
    local SOCKET_HTTPS_PORT="$(( 4000 + $APP_PORT_IDX * 10 + 1 ))"
  fi

  echo -n "${SOCKET_HTTPS_PORT}"
}

##################################################

function get_web_http_port () {
  if [[ $# -lt 2 ]]; then
    echo "Usage: get_web_http_port [ENV_TYPE] [APP_PORT_IDX]";
    exit 1;
  fi

  local ENV_TYPE="${1}"
  local APP_PORT_IDX="${2}"

  local WEB_HTTP_PORT="$(( 9000 + $APP_PORT_IDX * 10 ))"
  if [[ ${ENV_TYPE} == "test" ]]; then
    local WEB_HTTP_PORT="$(( 7000 + $APP_PORT_IDX * 10 ))"
  elif [[ ${ENV_TYPE} == "prod" ]]; then
    local WEB_HTTP_PORT="$(( 5000 + $APP_PORT_IDX * 10 ))"
  fi

  echo -n "${WEB_HTTP_PORT}"
}

##################################################

function get_web_https_port () {
  if [[ $# -lt 2 ]]; then
    echo "Usage: get_web_https_port [ENV_TYPE] [APP_PORT_IDX]";
    exit 1;
  fi

  local ENV_TYPE="${1}"
  local APP_PORT_IDX="${2}"

  local WEB_HTTPS_PORT="$(( 9000 + $APP_PORT_IDX * 10 + 1 ))"
  if [[ ${ENV_TYPE} == "test" ]]; then
    local WEB_HTTPS_PORT="$(( 7000 + $APP_PORT_IDX * 10 + 1 ))"
  elif [[ ${ENV_TYPE} == "prod" ]]; then
    local WEB_HTTPS_PORT="$(( 5000 + $APP_PORT_IDX * 10 + 1 ))"
  fi

  echo -n "${WEB_HTTPS_PORT}"
}

##################################################

function get_web_test_port () {
  if [[ $# -lt 2 ]]; then
    echo "Usage: get_web_test_port [ENV_TYPE] [APP_PORT_IDX]";
    exit 1;
  fi

  local ENV_TYPE="${1}"
  local APP_PORT_IDX="${2}"

  local WEB_HTTPS_PORT="$(( 9000 + $APP_PORT_IDX * 10 + 2 ))"
  if [[ ${ENV_TYPE} == "test" ]]; then
    local WEB_HTTPS_PORT="$(( 7000 + $APP_PORT_IDX * 10 + 2 ))"
  elif [[ ${ENV_TYPE} == "prod" ]]; then
    local WEB_HTTPS_PORT="$(( 5000 + $APP_PORT_IDX * 10 + 2 ))"
  fi

  echo -n "${WEB_HTTPS_PORT}"
}

##################################################

function get_current_date_stamp () {
  local CURRENT_DATE_STAMP=`date -u +"%Y-%m-%d-%H%M%S"`
  echo -n "${CURRENT_DATE_STAMP}"
}

##################################################

function get_os_type () {
  if [[ $OSTYPE == "darwin18" || $OSTYPE == "darwin18.0" ]]; then
    echo -n "mac"
  else
    echo -n "win"
  fi
}

##################################################

function get_dist_zip_name () {
  if [[ $# -lt 3 ]]; then
    echo "Usage: get_dist_zip_name [ENV_TYPE] [APP_NAME] [CURRENT_DATE_STAMP]";
    exit 1;
  fi

  local ENV_TYPE="${1}"
  local APP_NAME="${3}"
  local CURRENT_DATE_STAMP="${4}"
  local DIST_ZIP="dist-${APP_NAME}-${ENV_TYPE}-${CURRENT_DATE_STAMP}.zip"

  echo -n "${DIST_ZIP}"
}

##################################################

function get_remote_script_name () {
  if [[ $# -lt 3 ]]; then
    echo "Usage: get_remote_script_name [ENV_TYPE] [APP_NAME] [CURRENT_DATE_STAMP]";
    exit 1;
  fi

  local ENV_TYPE="${1}"
  local APP_NAME="${3}"
  local CURRENT_DATE_STAMP="${4}"
  local REMOTE_SCRIPT="deploy-${APP_NAME}-${ENV_TYPE}-${CURRENT_DATE_STAMP}.sh"

  echo -n "${REMOTE_SCRIPT}"
}

##################################################

function replace_vars () {
  if [[ $# -lt 10 ]]; then
    echo "Usage: replace_vars [FILE] [ENV_TYPE] [APP_HOST] [APP_VERSION] [APP_NAME] [APP_PORT_IDX] [SERVICE_NAME] [APP_SERVER_MAIL_FROM] [APP_GA_TRACKING_ID] [CURRENT_DATE_STAMP]";
    exit 1;
  fi

  local FILE="${1}"
  local ENV_TYPE="${2}"
  local APP_HOST="${3}"
  local APP_VERSION="${4}"
  local APP_NAME="${5}"
  local APP_PORT_IDX="${6}"
  local SERVICE_NAME="${7}"
  local APP_SERVER_MAIL_FROM="${8}"
  local APP_GA_TRACKING_ID="${9}"
  local CURRENT_DATE_STAMP="${10}"

  local ENV_TYPE_FULL="$(get_env_type_full ${ENV_TYPE})"

  local ENV_HOST_PREFIX="$(get_env_host_prefix ${ENV_TYPE})"
  local ENV_HOST="${ENV_HOST_PREFIX}${APP_HOST}"

  local ENV_SERVICE_NAME="$(get_env_service_name ${ENV_TYPE} ${SERVICE_NAME})"

  local SERVER_ADMIN="jobot.software@gmail.com"

  local DIST_ZIP="$(get_dist_zip_name ${ENV_TYPE} ${APP_NAME} ${CURRENT_DATE_STAMP})"
  local REMOTE_SCRIPT="$(get_remote_script_name ${ENV_TYPE} ${APP_NAME} ${CURRENT_DATE_STAMP})"

  local SOCKET_HTTP_PORT=$(get_socket_http_port ${ENV_TYPE} ${APP_PORT_IDX})

  sed -i '
      s/<APP_VERSION>/'${APP_VERSION}'/g;
      s/<APP_NAME>/'${APP_NAME}'/g;
      s/<APP_HOST>/'${APP_HOST}'/g;
      s/<APP_PORT_IDX>/'${APP_PORT_IDX}'/g;
      s/<APP_SERVER_MAIL_FROM>/'${APP_SERVER_MAIL_FROM}'/g;
      s/<APP_GA_TRACKING_ID>/'${APP_GA_TRACKING_ID}'/g;
      s/<ENV_TYPE>/'${ENV_TYPE}'/g;
      s/<ENV_TYPE_FULL>/'${ENV_TYPE_FULL}'/g;
      s/<ENV_HOST>/'${ENV_HOST}'/g;
      s/<ENV_HOST_PREFIX>/'${ENV_HOST_PREFIX}'/g;
      s/<SERVICE_NAME>/'${ENV_SERVICE_NAME}'/g;
      s/<CURRENT_DATE_STAMP>/'${CURRENT_DATE_STAMP}'/g;
      s/<SERVER_ADMIN>/'${SERVER_ADMIN}'/g;
      s/<DIST_ZIP>/'${DIST_ZIP}'/g;
      s/<REMOTE_SCRIPT>/'${REMOTE_SCRIPT}'/g;
      s/<SOCKET_HTTP_PORT>/'${SOCKET_HTTP_PORT}'/g;
  ' ${FILE}
}

##################################################

function set_config () {
  if [[ $# -lt 9 ]]; then
    echo "Usage: set_config [ENV_TYPE] [APP_HOST] [APP_VERSION] [APP_NAME] [APP_PORT_IDX] [SERVICE_NAME] [APP_SERVER_MAIL_FROM] [APP_ENQUIRIES_MAIL_TO] [APP_GA_TRACKING_ID]";
    exit 1;
  fi

  local ENV_TYPE="${1}"
  local APP_HOST="${2}"
  local APP_VERSION="${3}"
  local APP_NAME="${4}"
  local APP_PORT_IDX="${5}"
  local SERVICE_NAME="${6}"
  local APP_SERVER_MAIL_FROM="${7}"
  local APP_ENQUIRIES_MAIL_TO="${8}"
  local APP_GA_TRACKING_ID="${9}"

  local CONFIG_FOLDER="./src/client/env"
  local BASE_CONFIG_FILE="${CONFIG_FOLDER}/config.base.ts"
  local PROD_CONFIG_FILE="${CONFIG_FOLDER}/config.prod.ts"
  local TEST_CONFIG_FILE="${CONFIG_FOLDER}/config.test.ts"
  local DEV_CONFIG_FILE="${CONFIG_FOLDER}/config.dev.ts"
  local CONFIG_FILE="${CONFIG_FOLDER}/config.ts"

  if [[ -f ""${CONFIG_FILE}"" ]]; then
    echo "" > "${BASE_CONFIG_FILE}"
    echo "export const config = {"                        >> "${BASE_CONFIG_FILE}"
    echo "  appHost: '${APP_HOST}',"                      >> "${BASE_CONFIG_FILE}"
    echo "  appVersion: '${APP_VERSION}',"                >> "${BASE_CONFIG_FILE}"
    echo "  appName: '${APP_NAME}',"                      >> "${BASE_CONFIG_FILE}"
    echo "  portIdx: ${APP_PORT_IDX},"                    >> "${BASE_CONFIG_FILE}"
    echo "  serviceName: '${SERVICE_NAME}',"              >> "${BASE_CONFIG_FILE}"
    echo "  serverMailFrom: '${APP_SERVER_MAIL_FROM}',"   >> "${BASE_CONFIG_FILE}"
    echo "  enquiriesMailTo: '${APP_ENQUIRIES_MAIL_TO}'," >> "${BASE_CONFIG_FILE}"
    echo "  gaTrackingId: '${APP_GA_TRACKING_ID}',"       >> "${BASE_CONFIG_FILE}"
    echo "};"                                             >> "${BASE_CONFIG_FILE}"

    if [[ ${ENV_TYPE} == "prod" ]]; then
      cp "${PROD_CONFIG_FILE}" "${CONFIG_FILE}"
    elif [[ ${ENV_TYPE} == "test" ]]; then
      cp "${TEST_CONFIG_FILE}" "${CONFIG_FILE}"
    else
      cp "${DEV_CONFIG_FILE}" "${CONFIG_FILE}"
    fi
  fi
}

##################################################

function restore_config () {
  local CONFIG_FOLDER="./src/client/env"
  local DEV_CONFIG_FILE="${CONFIG_FOLDER}/config.dev.ts"
  local CONFIG_FILE="${CONFIG_FOLDER}/config.ts"

  if [[ -f "${CONFIG_FILE}" ]]; then
    cp "${DEV_CONFIG_FILE}" "${CONFIG_FILE}"
  fi
}

##################################################

function install_certificates () {
  if [[ $# -lt 2 ]]; then
    echo "Usage: install_certificates [ENV_TYPE] [APP_HOST]";
    exit 1;
  fi

  local ENV_TYPE="${1}"
  local APP_HOST="${2}"

  local ENV_HOST_PREFIX="$(get_env_host_prefix ${ENV_TYPE})"
  local ENV_HOST="${ENV_HOST_PREFIX}${APP_HOST}"

  local ROOT_DIR="$(pwd | sed 's/^\/cygdrive\/c/C:/; s/^\/c/C:/')"
  local CERTS_DIR="${ROOT_DIR}/src/cert"

  local OS_TYPE="$(get_os_type)"

  if [[ ${OS_TYPE} == "mac" ]]; then
    local INSTALLED_CERT="$(security find-certificate -a -p -c "${ENV_HOST}")"
  else
    local INSTALLED_CERT="$(powershell -f ${ROOT_DIR}/tools/scripts/find-cert.ps1 -certName:"${ENV_HOST} certificate" -certPath:"${CERTS_DIR}/${ENV_HOST}.crt")"
  fi

  if [[ ! -f "src/cert/${ENV_HOST}.crt" ]]; then
    echo "Creating certificate..."
    mkdir -p ${CERTS_DIR}
    rm -f "${CERTS_DIR}/${ENV_HOST}.key" "${CERTS_DIR}/${ENV_HOST}.crt"

    echo "" > "${CERTS_DIR}/${ENV_HOST}.conf"
    echo "[req]"                                        >> "${CERTS_DIR}/${ENV_HOST}.conf"
    echo "x509_extensions = v3_req"                     >> "${CERTS_DIR}/${ENV_HOST}.conf"
    echo "distinguished_name = dn"                      >> "${CERTS_DIR}/${ENV_HOST}.conf"
    echo "[dn]"                                         >> "${CERTS_DIR}/${ENV_HOST}.conf"
    echo "countryName                 = New Zealand"    >> "${CERTS_DIR}/${ENV_HOST}.conf"
    echo "countryName_default         = NZ"             >> "${CERTS_DIR}/${ENV_HOST}.conf"
    echo "stateOrProvinceName         = Wellington"     >> "${CERTS_DIR}/${ENV_HOST}.conf"
    echo "stateOrProvinceName_default = WEL"            >> "${CERTS_DIR}/${ENV_HOST}.conf"
    echo "localityName                = Business"       >> "${CERTS_DIR}/${ENV_HOST}.conf"
    echo "localityName_default        = Jobot Software" >> "${CERTS_DIR}/${ENV_HOST}.conf"
    echo "commonName                  = Common Name"    >> "${CERTS_DIR}/${ENV_HOST}.conf"
    echo "commonName_default          = ${ENV_HOST}"    >> "${CERTS_DIR}/${ENV_HOST}.conf"
    echo "[v3_req]"                                     >> "${CERTS_DIR}/${ENV_HOST}.conf"
    echo "subjectAltName = @alt_names"                  >> "${CERTS_DIR}/${ENV_HOST}.conf"
    echo "[alt_names]"                                  >> "${CERTS_DIR}/${ENV_HOST}.conf"
    echo "DNS.1 = localhost"                            >> "${CERTS_DIR}/${ENV_HOST}.conf"
    echo "DNS.2 = *.localhost"                          >> "${CERTS_DIR}/${ENV_HOST}.conf"
    echo "DNS.3 = ${ENV_HOST}"                          >> "${CERTS_DIR}/${ENV_HOST}.conf"
    echo "DNS.4 = *.${ENV_HOST}"                        >> "${CERTS_DIR}/${ENV_HOST}.conf"

    openssl req \
      -new \
      -x509 \
      -sha256 \
      -newkey rsa:2048 \
      -nodes \
      -keyout "${CERTS_DIR}/${ENV_HOST}.key" \
      -days 3650 \
      -out "${CERTS_DIR}/${ENV_HOST}.crt" \
      -config "${CERTS_DIR}/${ENV_HOST}.conf"

    rm -f "${CERTS_DIR}/${ENV_HOST}.conf"

    local INSTALLED_CERT=""
  fi

  if [[ ! ${INSTALLED_CERT} ]]; then
    echo "Installing certificate..."
    if [[ ${OS_TYPE} == "mac" ]]; then
      local FOUND_CERT="$(security find-certificate -a -p -c "${ENV_HOST}")"
      if [[ ${FOUND_CERT} ]]; then
        sudo security delete-certificate -c "${ENV_HOST}"
      fi
      sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "${CERTS_DIR}/${ENV_HOST}.crt"
    else
      powershell -f ${ROOT_DIR}/tools/scripts/install-cert.ps1 -certName:"${ENV_HOST} certificate" -certPath:"${CERTS_DIR}/${ENV_HOST}.crt"
    fi
  fi
}

##################################################

function create_host_entries () {
  if [[ $# -lt 2 ]]; then
    echo "Usage: create_host_entries [ENV_TYPE] [APP_HOST]";
    exit 1;
  fi

  local ENV_TYPE="${1}"
  local APP_HOST="${2}"

  local ENV_HOST_PREFIX="$(get_env_host_prefix ${ENV_TYPE})"
  local ENV_HOST="${ENV_HOST_PREFIX}${APP_HOST}"

  local OS_TYPE="$(get_os_type)"

  local HOSTS_FILE="C:/Windows/System32/drivers/etc/hosts"
  local LOCALHOST_IP="127.0.0.1"

  if [[ -f ${HOSTS_FILE} ]]; then
    set +e
    local CUR_IP="$(cat "${HOSTS_FILE}" 2>/dev/null | grep " ${ENV_HOST}")"
    set -e

    if [[ ! ${CUR_IP} ]]; then
      if [[ ${OS_TYPE} == "mac" ]]; then
        sudo chmod g+w "${HOSTS_FILE}"
      fi

      echo "Adding host file entry..."
      echo "${LOCALHOST_IP} ${ENV_HOST}" >> "${HOSTS_FILE}"

    elif [[ ${CUR_IP} != "${LOCALHOST_IP} ${ENV_HOST}" ]]; then
      if [[ ${OS_TYPE} == "mac" ]]; then
        sudo chmod g+w "${HOSTS_FILE}"
      fi

      echo "Correcting host file entry..."
      sed -i 's/^[0-9.]\+\s\+'${ENV_HOST}'\s*$//g' "${HOSTS_FILE}"
      echo "${LOCALHOST_IP} ${ENV_HOST}" >> "${HOSTS_FILE}"
    fi
  fi
}

##################################################

function launch_server () {
  if [[ $# -lt 8 ]]; then
    echo "Usage: launch_server [ENV_TYPE] [APP_HOST] [APP_VERSION] [APP_NAME] [APP_PORT_IDX] [APP_SERVER_MAIL_FROM] [APP_GA_TRACKING_ID] [RESPAWN]";
    exit 1;
  fi

  local ENV_TYPE="${1}"
  local APP_HOST="${2}"
  local APP_VERSION="${3}"
  local APP_NAME="${4}"
  local APP_PORT_IDX="${5}"
  local APP_SERVER_MAIL_FROM="${6}"
  local APP_GA_TRACKING_ID="${7}"
  local RESPAWN="${8}"

  local ENV_TYPE_FULL="$(get_env_type_full ${ENV_TYPE})"

  local ENV_HOST_PREFIX="$(get_env_host_prefix ${ENV_TYPE})"
  local ENV_HOST="${ENV_HOST_PREFIX}${APP_HOST}"

  local SOCKET_HTTPS_PORT=$(get_socket_https_port ${ENV_TYPE} ${APP_PORT_IDX})

  local SERVER_FOLDER="./src/server"
  local SERVER_FILE="${SERVER_FOLDER}/server.ts"

  SERVER_LAUNCHED="" #global

  if [[ ! -d "${SERVER_FOLDER}" ]]; then
    return
  fi

  function _healthcheck () {
      local api_url="https://${ENV_HOST}:${SOCKET_HTTPS_PORT}/v1/status"
      local status_success=$(curl -k -s -L "${api_url}" | jq -r ".success")
      if [[ "${status_success}" != "true" ]]; then
          echo "FAIL"
          return
      fi
      echo "PASS"
  }

  if [[ "$(_healthcheck)" == "PASS" ]]; then
    echo "Server already launched"
    return
  fi

  echo "Launching server..."

  local NODE_ARGS="--no-notify"
  if [[ ${RESPAWN} ]]; then
    local NODE_ARGS="${NODE_ARGS} --respawn"
  fi

  APP_VERSION=${APP_VERSION} \
  APP_NAME=${APP_NAME} \
  APP_HOST=${APP_HOST} \
  APP_PORT_IDX=${APP_PORT_IDX} \
  APP_ENV_TYPE=${ENV_TYPE_FULL} \
  APP_SERVER_MAIL_FROM=${APP_SERVER_MAIL_FROM} \
  APP_GA_TRACKING_ID=${APP_GA_TRACKING_ID} \
  yarn ts-node-dev ${NODE_ARGS} "${SERVER_FILE}" &

  if [[ ${RESPAWN} ]]; then
    sleep 20;
    while [[ "$(_healthcheck)" == "FAIL"* ]]; do
        echo "Server needs to be reloaded"
        touch "${SERVER_FILE}"
        sleep 20;
    done;
  fi

  echo "Server is loaded"
  SERVER_LAUNCHED="true"
}

##################################################

function terminate_server () {
  if [[ $# -lt 3 ]]; then
    echo "Usage: terminate_server [ENV_TYPE] [APP_HOST] [APP_PORT_IDX]";
    exit 1;
  fi

  local ENV_TYPE="${1}"
  local APP_HOST="${2}"
  local APP_PORT_IDX="${3}"

  local ENV_TYPE_FULL="$(get_env_type_full ${ENV_TYPE})"

  local ENV_HOST_PREFIX="$(get_env_host_prefix ${ENV_TYPE})"
  local ENV_HOST="${ENV_HOST_PREFIX}${APP_HOST}"

  local SOCKET_HTTPS_PORT=$(get_socket_https_port ${ENV_TYPE} ${APP_PORT_IDX})

  local SERVER_FOLDER="./src/server"
  local SERVER_FILE="${SERVER_FOLDER}/server.ts"

  if [[ ! "${SERVER_LAUNCHED}" ]]; then
    return
  fi

  if [[ ! -d "${SERVER_FOLDER}" ]]; then
    return
  fi

  echo "Terminating server..."
  curl -k -s -L "https://${ENV_HOST}:${SOCKET_HTTPS_PORT}/v1/terminate"
}

##################################################
