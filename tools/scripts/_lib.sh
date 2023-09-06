##################################################
#
# CONSTANTS
#
##################################################

export cRESET="\e[0m";
export cBLACK="\e[0;30m";
export cRED="\e[0;31m";
export cGREEN="\e[0;32m";
export cYELLOW="\e[0;33m";
export cBLUE="\e[0;34m";
export cMAGENTA="\e[0;35m";
export cCYAN="\e[0;36m";
export cLIGHT_GRAY="\e[0;37m";
export cDARK_GRAY="\e[0;90m";
export cLIGHT_RED="\e[0;91m";
export cLIGHT_GREEN="\e[0;92m";
export cLIGHT_YELLOW="\e[0;93m";
export cLIGHT_BLUE="\e[0;94m";
export cLIGHT_MAGENTA="\e[0;95m";
export cLIGHT_CYAN="\e[0;96m";
export cWHITE="\e[0;97m";
export CURDIR="$(pwd)";

##################################################
#
# PRINTING FUNCTIONS
#
##################################################

function read_enter () {
  echo -n "Press enter to continue..."; read
}

##################################################

function localhost() {
  local host_name=$(hostname)

  if [[ $host_name == "Hephaestus" ]]; then
    echo "local"
    return
  fi
  if [[ $host_name == "Ares" ]]; then
    echo "local"
    return
  fi

  return
}

##################################################

function notify () {
  if [[ $# -lt 2 ]]; then
    echo "Usage $0: [TITLE] [MESSAGE] [ICON (OPTIONAL)]";
    return
  fi

  if [[ $(localhost) != "local" ]]; then
    return
  fi

  TITLE=$1
  shift 1;

  MESSAGE=$1
  shift 1;

  ICON=$1
  shift 1;

  local snore_toast_folder="${UTILS_DIR}/snore-toast";
  nohup "$snore_toast_folder/SnoreToast.exe" -p "$snore_toast_folder/images/$ICON.png" -t "$TITLE" -m "$MESSAGE" -w &> /dev/null &
}

##################################################

function speak() {
  if [[ $(localhost) != "local" ]]; then
    return
  fi

  powershell -Command "Add-Type -AssemblyName System.Speech; (New-Object System.Speech.Synthesis.SpeechSynthesizer).Speak('"$@"');"
}

##################################################

function alert_user () {
  if [[ $# -lt 2 ]]; then
    echo "Usage: alert_user [APP_NAME] [MESSAGE]";
    exit 1;
  fi

  local APP_NAME="${1}"
  shift 1;

  local ICON_NAME=`echo $APP_NAME | tr '[:upper:]' '[:lower:]'`

  notify "${APP_NAME}" "$@" "${ICON_NAME}" &
  speak $@ &
  echo "$@"
}

##################################################

function print_key_val () {
  if [[ $# -lt 2 ]]; then
    echo "Usage $0: [KEY] [VALUE] [VALUE COLOUR (OPTIONAL)]";
    return
  fi

  key=$1
  value=$2
  value_colour=$3

  if [[ -z $value_colour ]]; then
    value_colour="${cCYAN}"
  fi

  echo -e -n ${cGREEN}${key}${cRESET}
  echo -e -n ${cWHITE}" => "${cRESET}
  echo -e ${value_colour}${value}${cRESET}
}

##################################################

function print_debug () {
  if [[ $# -lt 1 ]]; then
    echo "Usage $0: [MESSAGE]";
    return
  fi

  echo -e $cDARK_GRAY$1$cRESET
}

##################################################

function print_info () {
  if [[ $# -lt 1 ]]; then
    echo "Usage $0: [MESSAGE]";
    return
  fi

  echo -e $cCYAN$1$cRESET
}

##################################################

function print_success () {
  if [[ $# -lt 1 ]]; then
    echo "Usage $0: [MESSAGE]";
    return
  fi

  echo -e $cGREEN$1$cRESET
}

##################################################

function print_warning () {
  if [[ $# -lt 1 ]]; then
    echo "Usage $0: [MESSAGE]";
    return
  fi

  echo -e $cYELLOW"Warning: "$1$cRESET
}

##################################################

function print_error () {
  if [[ $# -lt 1 ]]; then
    echo "Usage $0: [MESSAGE]";
    return
  fi

  echo -e $cRED"Error: "$1$cRESET
}

##################################################

function print_header () {
  if [[ $# -lt 1 ]]; then
    echo "Usage $0: [TITLE]";
    return
  fi

  highlight -bcolor "blue" $@
}

##################################################

function highlight () {
  if [[ $# -gt 0 ]]; then
    background_color="blue"
    color="white"
    content=""

    parsing="true"
    while [[ $parsing ]]; do
      parsing=""

      if [[ $1 == "-bcolor" ]]; then
        background_color=$2;
        parsing="true"
        shift 2;
        continue
      fi

      if [[ $1 == "-color" ]]; then
        color=$2;
        parsing="true"
        shift 2;
        continue
      fi

      if [[ $1 ]]; then
        content="$content $1"
        parsing="true"
        shift 1;
        continue
      fi
    done

    content=`echo $content | awk '{$1=$1;print}'`
    chrlen=$((${#content}))
    line=`echo $content | tr '[:lower:]' '[:upper:]'`

    background_color=`echo $background_color | tr '[:lower:]' '[:upper:]'`
    background_color='$cB'$background_color
    background_color=`eval "echo $background_color"`

    color=`echo $color | tr '[:lower:]' '[:upper:]'`
    color='$c'$color'_NR'
    color=`eval "echo $color"`

    echo
    echo -e -n $background_color
    printf %4s
    printf %"$chrlen"s
    printf %4s
    echo -e -n $cRESET
    echo

    echo -e -n $background_color
    printf %4s
    echo -e -n $color"$line"
    printf %4s
    echo -e -n $cRESET
    echo

    echo -e -n $background_color
    printf %4s
    printf %"$chrlen"s
    printf "%4s"
    echo -e -n $cRESET
    echo -e "\n"
  fi
}

##################################################

function get_webpack_config () {
  if [[ $# -lt 1 ]]; then
    echo "Usage: get_webpack_config [ENV_TYPE]";
    exit 1;
  fi

  local ENV_TYPE="${1}"

  local WEBPACK_CONFIG="dev"
  if [[ "${ENV_TYPE}" == "test" ]]; then
    local WEBPACK_CONFIG="prod"
  elif [[ "${ENV_TYPE}" == "prod" ]]; then
    local WEBPACK_CONFIG="prod"
  fi

  echo -n "${WEBPACK_CONFIG}"
}

##################################################

function get_env_type () {
  if [[ $# -lt 1 ]]; then
    echo "Usage: get_env_type [ENV_TYPE]";
    exit 1;
  fi

  local ENV_TYPE_INPUT="${1} | tr '[:upper:]' '[:lower:]'"

  local ENV_TYPE="dev"
  if [[ "${ENV_TYPE_INPUT}" == "test"* ]]; then
    local ENV_TYPE="test"
  elif [[ "${ENV_TYPE_INPUT}" == "prod"* ]]; then
    local ENV_TYPE="prod"
  fi

  echo -n "${ENV_TYPE}"
}

##################################################

function get_env_type_full () {
  if [[ $# -lt 1 ]]; then
    echo "Usage: get_env_type_full [ENV_TYPE]";
    exit 1;
  fi

  local ENV_TYPE="${1}"

  local ENV_TYPE_FULL="Development"
  if [[ "${ENV_TYPE}" == "test" ]]; then
    local ENV_TYPE_FULL="Test"
  elif [[ "${ENV_TYPE}" == "prod" ]]; then
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
  if [[ "${ENV_TYPE}" == "test" ]]; then
    local ENV_HOST_PREFIX="test."
  elif [[ "${ENV_TYPE}" == "prod" ]]; then
    local ENV_HOST_PREFIX=""
  fi

  echo -n "${ENV_HOST_PREFIX}"
}

##################################################

function get_deloy_host () {
  if [[ $# -lt 2 ]]; then
    echo "Usage: get_deloy_host [ENV_TYPE] [APP_NAME]";
    exit 1;
  fi

  local ENV_TYPE="${1}"
  local APP_NAME="${2}"

  local DEPLOY_HOST="services.jobot-software.com"
  if [[ "${ENV_TYPE}" == "test" ]]; then
    local DEPLOY_HOST="services.jobot-software.com"
  elif [[ "${ENV_TYPE}" == "prod" ]]; then
    if [[ "${APP_NAME}" == "my-save" ]]; then
      local DEPLOY_HOST="mysave.co.nz"
    else
      local DEPLOY_HOST="services.jobot-software.com"
    fi
  fi

  echo -n "${DEPLOY_HOST}"
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
  if [[ "${SERVICE_NAME}" ]]; then
    if [[ "${ENV_TYPE}" == "test" ]]; then
      local ENV_SERVICE_NAME="test.${SERVICE_NAME}"
    elif [[ "${ENV_TYPE}" == "prod" ]]; then
      local ENV_SERVICE_NAME="${SERVICE_NAME}"
    fi
  fi

  echo -n "${ENV_SERVICE_NAME}"
}

##################################################

function get_http_port () {
  if [[ $# -lt 2 ]]; then
    echo "Usage: get_http_port [ENV_TYPE] [APP_PORT_IDX]";
    exit 1;
  fi

  local ENV_TYPE="${1}"
  local APP_PORT_IDX="${2}"

  local HTTP_PORT="$(( 8000 + $APP_PORT_IDX * 10 ))"
  if [[ "${ENV_TYPE}" == "test" ]]; then
    local HTTP_PORT="$(( 6000 + $APP_PORT_IDX * 10 ))"
  elif [[ "${ENV_TYPE}" == "prod" ]]; then
    local HTTP_PORT="$(( 4000 + $APP_PORT_IDX * 10 ))"
  fi

  echo -n "${HTTP_PORT}"
}

##################################################

function get_https_port () {
  if [[ $# -lt 2 ]]; then
    echo "Usage: get_https_port [ENV_TYPE] [APP_PORT_IDX]";
    exit 1;
  fi

  local ENV_TYPE="${1}"
  local APP_PORT_IDX="${2}"

  local HTTPS_PORT="$(( 8000 + $APP_PORT_IDX * 10 + 1 ))"
  if [[ "${ENV_TYPE}" == "test" ]]; then
    local HTTPS_PORT="$(( 6000 + $APP_PORT_IDX * 10 + 1 ))"
  elif [[ "${ENV_TYPE}" == "prod" ]]; then
    local HTTPS_PORT="$(( 4000 + $APP_PORT_IDX * 10 + 1 ))"
  fi

  echo -n "${HTTPS_PORT}"
}

##################################################

function get_test_https_port () {
  if [[ $# -lt 2 ]]; then
    echo "Usage: get_test_https_port [ENV_TYPE] [APP_PORT_IDX]";
    exit 1;
  fi

  local ENV_TYPE="${1}"
  local APP_PORT_IDX="${2}"

  local TEST_HTTPS_PORT="$(( 8000 + $APP_PORT_IDX * 10 + 2 ))"
  if [[ "${ENV_TYPE}" == "test" ]]; then
    local TEST_HTTPS_PORT="$(( 6000 + $APP_PORT_IDX * 10 + 2 ))"
  elif [[ "${ENV_TYPE}" == "prod" ]]; then
    local TEST_HTTPS_PORT="$(( 4000 + $APP_PORT_IDX * 10 + 2 ))"
  fi

  echo -n "${TEST_HTTPS_PORT}"
}

##################################################

function get_script_data_dir () {
  if [[ $# -lt 1 ]]; then
    echo "Usage: get_script_data_dir [ENV_TYPE]";
    exit 1;
  fi

  local ENV_TYPE="${1}"

  local PROJECT_DIR="$(echo $CURDIR | sed 's/^\/cygdrive\/c/C:/; s/^\/c/C:/')"
  local DATA_DIR="$(realpath $(echo "${PROJECT_DIR}\/data") | sed 's/\//\\\//g')"

  if [[ "${ENV_TYPE}" == "test" ]]; then
    local DATA_DIR="\/home\/ubuntu\/data"
  elif [[ "${ENV_TYPE}" == "prod" ]]; then
    local DATA_DIR="\/home\/ubuntu\/data"
  fi

  echo -n "${DATA_DIR}"
}

##################################################

function get_script_services_dir () {
  if [[ $# -lt 2 ]]; then
    echo "Usage: get_script_services_dir [ENV_TYPE]";
    exit 1;
  fi

  local ENV_TYPE="${1}"
  local ENV_SERVICE_NAME="${2}"

  local PROJECT_DIR="$(echo $CURDIR | sed 's/^\/cygdrive\/c/C:/; s/^\/c/C:/')"
  local SERVICES_DIR="$(realpath $(echo "${PROJECT_DIR}/../") | sed 's/\//\\\//g')"

  if [[ "${ENV_TYPE}" == "test" ]]; then
    local SERVICES_DIR="\/home\/ubuntu\/services"
  elif [[ "${ENV_TYPE}" == "prod" ]]; then
    local SERVICES_DIR="\/home\/ubuntu\/services"
  fi

  echo -n "${SERVICES_DIR}"
}

##################################################

function get_current_date_stamp () {
  local CURRENT_DATESTAMP=`date -u +"%Y-%m-%d-%H%M%S"`
  echo -n "${CURRENT_DATESTAMP}"
}

##################################################

function get_os_type () {
  if [[ "${OSTYPE}" == "darwin18" || "${OSTYPE}" == "darwin18.0" ]]; then
    echo -n "mac"
  elif [[ "${OSTYPE}" == "msys" ]]; then
    echo -n "win"
  else
    echo -n "unknown: ${OSTYPE}"
  fi
}

##################################################

function get_dist_zip_name () {
  if [[ $# -lt 4 ]]; then
    echo "Usage: get_dist_zip_name [DIST_TYPE] [ENV_TYPE] [APP_NAME] [CURRENT_DATESTAMP]";
    exit 1;
  fi

  local DIST_TYPE="${1}"
  local ENV_TYPE="${2}"
  local APP_NAME="${3}"
  local CURRENT_DATESTAMP="${4}"

  local DIST_ZIP="${DIST_TYPE}-${APP_NAME}-${ENV_TYPE}-${CURRENT_DATESTAMP}.zip"

  echo -n "${DIST_ZIP}"
}

##################################################

function get_remote_script_name () {
  if [[ $# -lt 4 ]]; then
    echo "Usage: get_remote_script_name [DIST_TYPE] [ENV_TYPE] [APP_NAME] [CURRENT_DATESTAMP]";
    exit 1;
  fi

  local DIST_TYPE="${1}"
  local ENV_TYPE="${2}"
  local APP_NAME="${3}"
  local CURRENT_DATESTAMP="${4}"

  local REMOTE_SCRIPT="${DIST_TYPE}-${APP_NAME}-${ENV_TYPE}-${CURRENT_DATESTAMP}.sh"

  echo -n "${REMOTE_SCRIPT}"
}

##################################################

function replace_vars () {
  if [[ $# -lt 8 ]]; then
    echo "Usage: replace_vars [FILE] [ENV_TYPE] [APP_HOST] [APP_NAME] [APP_PORT_IDX] [SERVICE_NAME] [CURRENT_DATESTAMP] [DIST_TYPE]";
    exit 1;
  fi

  local FILE="${1}"
  local ENV_TYPE="${2}"
  local APP_HOST="${3}"
  local APP_NAME="${4}"
  local APP_PORT_IDX="${5}"
  local SERVICE_NAME="${6}"
  local CURRENT_DATESTAMP="${7}"
  local DIST_TYPE="${8}"

  local ENV_HOST_PREFIX="$(get_env_host_prefix "${ENV_TYPE}")"
  local ENV_HOST="${ENV_HOST_PREFIX}${APP_HOST}"

  local ENV_SERVICE_NAME="$(get_env_service_name "${ENV_TYPE}" "${SERVICE_NAME}")"

  local SERVER_ADMIN="jobot.software@gmail.com"

  local DIST_ZIP="$(get_dist_zip_name "${DIST_TYPE}" "${ENV_TYPE}" "${APP_NAME}" "${CURRENT_DATESTAMP}")"
  local REMOTE_SCRIPT="$(get_remote_script_name "${DIST_TYPE}" "${ENV_TYPE}" "${APP_NAME}" "${CURRENT_DATESTAMP}")"

  local HTTP_PORT=$(get_http_port "${ENV_TYPE}" "${APP_PORT_IDX}")

  local DATA_DIR=$(get_script_data_dir "${ENV_TYPE}")
  local SERVICES_DIR=$(get_script_services_dir "${ENV_TYPE}" "${ENV_SERVICE_NAME}")

  sed -i '
      s/<DATA_DIR>/'${DATA_DIR}'/g;
      s/<APP_NAME>/'${APP_NAME}'/g;
      s/<ENV_TYPE>/'${ENV_TYPE}'/g;
      s/<ENV_HOST>/'${ENV_HOST}'/g;
      s/<SERVICES_DIR>/'${SERVICES_DIR}'/g;
      s/<ENV_SERVICE_NAME>/'${ENV_SERVICE_NAME}'/g;
      s/<SERVICE_NAME>/'${SERVICE_NAME}'/g;
      s/<CURRENT_DATESTAMP>/'${CURRENT_DATESTAMP}'/g;
      s/<SERVER_ADMIN>/'${SERVER_ADMIN}'/g;
      s/<DIST_ZIP>/'${DIST_ZIP}'/g;
      s/<REMOTE_SCRIPT>/'${REMOTE_SCRIPT}'/g;
      s/<HTTP_PORT>/'${HTTP_PORT}'/g;
  ' "${FILE}"
}

##################################################

function set_config () {
  if [[ $# -lt 11 ]]; then
    echo "Usage: set_config [ENV_TYPE] [APP_HOST] [APP_VERSION] [APP_TITLE] [APP_SLOGA] [APP_PORT_IDX] [SERVICE_NAME] [APP_SERVER_MAIL_FROM] [APP_ENQUIRIES_MAIL_TO] [APP_GA_TRACKING_ID] [APP_TRELLO_BOARD_ID]";
    exit 1;
  fi

  local ENV_TYPE="${1}"
  local APP_HOST="${2}"
  local APP_VERSION="${3}"
  local APP_TITLE="${4}"
  local APP_SLOGAN="${5}"
  local APP_PORT_IDX="${6}"
  local SERVICE_NAME="${7}"
  local APP_SERVER_MAIL_FROM="${8}"
  local APP_ENQUIRIES_MAIL_TO="${9}"
  local APP_GA_TRACKING_ID="${10}"
  local APP_TRELLO_BOARD_ID="${11}"
  set +e
  local APP_IP=$(ipconfig | grep IPv4 | tail -1 | cut -d ':' -f 2 | tr -d '[:space:]')
  set -e

  local CONFIG_FOLDER="./src/shared/env"
  local BASE_CONFIG_FILE="${CONFIG_FOLDER}/config.base.ts"
  local PROD_CONFIG_FILE="${CONFIG_FOLDER}/config.prod.ts"
  local TEST_CONFIG_FILE="${CONFIG_FOLDER}/config.test.ts"
  local DEV_CONFIG_FILE="${CONFIG_FOLDER}/config.dev.ts"
  local CONFIG_FILE="${CONFIG_FOLDER}/config.ts"

  if [[ -f "${DEV_CONFIG_FILE}" ]]; then
    echo "import { LOG_LEVEL } from '../enums/log-level';"   > "${BASE_CONFIG_FILE}"
    echo ""                                                  >> "${BASE_CONFIG_FILE}"
    echo "export const config = {"                           >> "${BASE_CONFIG_FILE}"
    echo "    appIp: '${APP_IP}',"                           >> "${BASE_CONFIG_FILE}"
    echo "    appHost: '${APP_HOST}',"                       >> "${BASE_CONFIG_FILE}"
    echo "    appVersion: '${APP_VERSION}',"                 >> "${BASE_CONFIG_FILE}"
    echo "    appTitle: '${APP_TITLE}',"                     >> "${BASE_CONFIG_FILE}"
    echo "    appSlogan: '${APP_SLOGAN}',"                   >> "${BASE_CONFIG_FILE}"
    echo "    portIdx: ${APP_PORT_IDX},"                     >> "${BASE_CONFIG_FILE}"
    echo "    serviceName: '${SERVICE_NAME}',"               >> "${BASE_CONFIG_FILE}"
    echo "    serverMailFrom: '${APP_SERVER_MAIL_FROM}',"    >> "${BASE_CONFIG_FILE}"
    echo "    enquiriesMailTo: '${APP_ENQUIRIES_MAIL_TO}',"  >> "${BASE_CONFIG_FILE}"
    echo "    gaTrackingId: '${APP_GA_TRACKING_ID}',"        >> "${BASE_CONFIG_FILE}"
    echo "    logLevel: LOG_LEVEL.Info,"                     >> "${BASE_CONFIG_FILE}"
    echo "    trello: {"                                     >> "${BASE_CONFIG_FILE}"
    echo "        board_id: '${APP_TRELLO_BOARD_ID}'"        >> "${BASE_CONFIG_FILE}"
    echo "    },"                                            >> "${BASE_CONFIG_FILE}"
    echo "};"                                                >> "${BASE_CONFIG_FILE}"

    if [[ "${ENV_TYPE}" == "prod" ]]; then
      cp "${PROD_CONFIG_FILE}" "${CONFIG_FILE}"
    elif [[ "${ENV_TYPE}" == "test" ]]; then
      cp "${TEST_CONFIG_FILE}" "${CONFIG_FILE}"
    else
      cp "${DEV_CONFIG_FILE}" "${CONFIG_FILE}"
    fi
  fi
}

##################################################

function restore_config () {
  local CONFIG_FOLDER="./src/shared/env"

  local DEV_CONFIG_FILE="${CONFIG_FOLDER}/config.dev.ts"
  local CONFIG_FILE="${CONFIG_FOLDER}/config.ts"

  if [[ -f "${DEV_CONFIG_FILE}" ]]; then
    cp "${DEV_CONFIG_FILE}" "${CONFIG_FILE}"
  fi
}

##################################################

function install_certificates () {
  if [[ $# -lt 3 ]]; then
    echo "Usage: install_certificates [ENV_TYPE] [APP_HOST] [INSTALL_CERT]";
    exit 1;
  fi

  local ENV_TYPE="${1}"
  local APP_HOST="${2}"
  local INSTALL_CERT="${3}"
  if [[ ! "${INSTALL_CERT}" ]]; then
    if [[ "${LOCAL}" ]]; then
      INSTALL_CERT="INSTALL"
    fi
  fi

  local ENV_HOST_PREFIX="$(get_env_host_prefix "${ENV_TYPE}")"
  local ENV_HOST="${ENV_HOST_PREFIX}${APP_HOST}"

  local ROOT_DIR="$(pwd | sed 's/^\/cygdrive\/c/C:/; s/^\/c/C:/')"
  local CERTS_DIR="${ROOT_DIR}/src/cert"

  local OS_TYPE="$(get_os_type)"

  if [[ "${INSTALL_CERT}" == "INSTALL" ]]; then
    if [[ "${OS_TYPE}" == "mac" ]]; then
      local INSTALLED_CERT="$(security find-certificate -a -p -c "${ENV_HOST}")"
    else
      local INSTALLED_CERT="$(powershell -f "${ROOT_DIR}/tools/scripts/find-cert.ps1" -certName:"${ENV_HOST} certificate" -certPath:"${CERTS_DIR}/${ENV_HOST}.crt")"
    fi
  fi

  if [[ ! -f "${CERTS_DIR}/${ENV_HOST}.crt" ]]; then
    echo "Creating certificate..."
    mkdir -p "${CERTS_DIR}"
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
      -batch \
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

  if [[ "${INSTALL_CERT}" == "INSTALL" ]] && [[ ! "${INSTALLED_CERT}" ]]; then
    echo "Installing certificate..."
    if [[ "${OS_TYPE}" == "mac" ]]; then
      local FOUND_CERT="$(security find-certificate -a -p -c "${ENV_HOST}")"
      if [[ "${FOUND_CERT}" ]]; then
        sudo security delete-certificate -c "${ENV_HOST}"
      fi
      sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" "${CERTS_DIR}/${ENV_HOST}.crt"
    else
      powershell -f "${ROOT_DIR}/tools/scripts/install-cert.ps1" -certName:"${ENV_HOST} certificate" -certPath:"${CERTS_DIR}/${ENV_HOST}.crt"
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

  local ENV_HOST_PREFIX="$(get_env_host_prefix "${ENV_TYPE}")"
  local ENV_HOST="${ENV_HOST_PREFIX}${APP_HOST}"

  local OS_TYPE="$(get_os_type)"

  local HOSTS_FILE="C:/Windows/System32/drivers/etc/hosts"
  local LOCALHOST_IP="127.0.0.1"

  if [[ -f "${HOSTS_FILE}" ]]; then
    set +e
    local CUR_IP="$(cat "${HOSTS_FILE}" 2>/dev/null | grep " ${ENV_HOST}")"
    set -e

    if [[ ! "${CUR_IP}" ]]; then
      if [[ "${OS_TYPE}" == "mac" ]]; then
        sudo chmod g+w "${HOSTS_FILE}"
      fi

      echo "Adding host file entry..."
      echo "${LOCALHOST_IP} ${ENV_HOST}" >> "${HOSTS_FILE}"

    elif [[ "${CUR_IP}" != "${LOCALHOST_IP} ${ENV_HOST}" ]]; then
      if [[ "${OS_TYPE}" == "mac" ]]; then
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
  if [[ $# -lt 4 ]]; then
    echo "Usage: launch_server [ENV_TYPE] [APP_HOST] [APP_PORT_IDX] [PERSIST_DATA] [RESPAWN (OPTIONAL)]";
    exit 1;
  fi

  local ENV_TYPE="${1}"
  local APP_HOST="${2}"
  local APP_PORT_IDX="${3}"
  local PERSIST_DATA="${4}"
  local RESPAWN="${5}"

  local ENV_HOST_PREFIX="$(get_env_host_prefix "${ENV_TYPE}")"
  local ENV_HOST="${ENV_HOST_PREFIX}${APP_HOST}"
  local HTTPS_PORT=$(get_https_port "${ENV_TYPE}" "${APP_PORT_IDX}")
  local PROTOCOL="https"

  local SERVER_FOLDER="./src/server"
  local SERVER_FILE="${SERVER_FOLDER}/server.ts"

  SERVER_LAUNCHED="" #global

  if [[ ! -d "${SERVER_FOLDER}" ]]; then
    return
  fi

  function _healthcheck () {
      local api_url="${PROTOCOL}://${ENV_HOST}:${HTTPS_PORT}/v1/status"
      local status_success=$(curl -k -s -L "${api_url}" | jq -r ".success")
      if [[ "${status_success}" != "true" ]]; then
          echo "FAIL"
          return
      fi
      echo "PASS"
  }

  sleep 3
  if [[ "$(_healthcheck)" == "PASS" ]]; then
    echo "Server already launched"
    return
  fi

  echo "Launching server..."

  local NODE_ARGS="--trace-deprecation --no-notify"
  if [[ "${RESPAWN}" == "true" ]]; then
    local NODE_ARGS="${NODE_ARGS} --respawn"
  fi

  if [[ "${PERSIST_DATA}" == "true" ]]; then
    export FORCE_PERSIST_DATA=true
  fi

  npx ts-node-dev ${NODE_ARGS} "${SERVER_FILE}" &

  if [[ "${RESPAWN}" == "true" ]]; then
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

  local ENV_TYPE_FULL="$(get_env_type_full "${ENV_TYPE}")"

  local ENV_HOST_PREFIX="$(get_env_host_prefix "${ENV_TYPE}")"
  local ENV_HOST="${ENV_HOST_PREFIX}${APP_HOST}"

  local HTTPS_PORT=$(get_https_port "${ENV_TYPE}" "${APP_PORT_IDX}")

  local SERVER_FOLDER="./src/server"
  local SERVER_FILE="${SERVER_FOLDER}/server.ts"

  if [[ ! "${SERVER_LAUNCHED}" ]]; then
    return
  fi

  if [[ ! -d "${SERVER_FOLDER}" ]]; then
    return
  fi

  echo "Terminating server..."
  curl -k -s -L "https://${ENV_HOST}:${HTTPS_PORT}/v1/terminate" 2>&1
}

##################################################

function launch_ci () {
  if [[ $# -lt 2 ]]; then
    echo "Usage: launch_ci [PERSIST_DATA] [RESPAWN] [CI_ARGS]";
    exit 1;
  fi

  local PERSIST_DATA="${1}"
  shift 1;
  local RESPAWN="${1}"
  shift 1;
  local CI_ARGS="$@"

  local CI_FOLDER="./src/ci"
  local CI_FILE="${CI_FOLDER}/main.ts"

  if [[ ! -d "${CI_FOLDER}" ]]; then
    return
  fi

  echo "Launching ci..."

  local NODE_ARGS="--no-notify"
  if [[ "${RESPAWN}" == "true" ]]; then
    local NODE_ARGS="${NODE_ARGS} --respawn"
  fi

  if [[ "${PERSIST_DATA}" == "true" ]]; then
    export FORCE_PERSIST_DATA=true
  fi

  npx ts-node-dev ${NODE_ARGS} "${CI_FILE}" ${CI_ARGS}
}

##################################################
