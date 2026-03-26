#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NLS_LANG="${NLS_LANG:-GERMAN_GERMANY.AL32UTF8}"
export NLS_LANG

COMMAND="${1:-help}"
if [ $# -gt 0 ]; then
  shift
fi

OWNER=""
OWNER_PW="${FSM_OWNER_PW:-}"
CLIENT=""
CLIENT_PW="${FSM_CLIENT_PW:-}"
SERVICE=""
DEFAULT_LANGUAGE="${FSM_DEFAULT_LANGUAGE:-GERMAN}"
LOG_DIR="${FSM_LOG_DIR:-${SCRIPT_DIR}/logs}"
SAMPLE_USER=""
SAMPLE_USER_PW="${FSM_SAMPLE_USER_PW:-}"
APEX_USER=""
APEX_USER_PW="${FSM_APEX_USER_PW:-}"
APEX_WORKSPACE="${FSM_APEX_WORKSPACE:-}"
APEX_APP_ID="${FSM_APEX_APP_ID:-}"

usage() {
  cat <<'EOF'
Usage:
  ./fsm.sh <command> [options]

Commands:
  install            Install FSM in the owner schema
  install-client     Grant FSM access to one client schema
  install-sample     Install sample business logic and APEX app
  uninstall          Remove FSM from the owner schema
  uninstall-client   Remove FSM grants and synonyms from one client schema
  uninstall-sample   Remove sample business logic and APEX app
  help               Show this help

Options:
  --owner <schema>              Owner schema for FSM
  --service <service>           Database service or PDB
  --client <schema>             Client schema for install-client and uninstall-client
  --default-language <lang>     Install language, default: GERMAN
  --sample-user <schema>        Schema for FSM sample business logic
  --apex-user <schema>          Schema owning the APEX application
  --apex-workspace <workspace>  APEX workspace name
  --apex-app-id <id>            APEX application ID
  --log-dir <path>              Directory for per-action logs

Environment:
  FSM_OWNER
  FSM_OWNER_PW
  FSM_CLIENT
  FSM_CLIENT_PW
  FSM_SERVICE
  FSM_DEFAULT_LANGUAGE
  FSM_LOG_DIR
  FSM_SAMPLE_USER
  FSM_SAMPLE_USER_PW
  FSM_APEX_USER
  FSM_APEX_USER_PW
  FSM_APEX_WORKSPACE
  FSM_APEX_APP_ID

Notes:
  Passwords are intentionally not accepted as CLI options.
  Missing values fall back from CLI to environment and finally to interactive prompts.
EOF
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

prompt_value() {
  local var_name="$1"
  local prompt_text="$2"
  local current_value="${!var_name:-}"

  if [ -z "${current_value}" ]; then
    [ -t 0 ] || die "Missing required value for ${var_name} in non-interactive mode."
    read -r -p "${prompt_text}" current_value
  fi

  [ -n "${current_value}" ] || die "Missing required value for ${var_name}."
  printf -v "${var_name}" '%s' "${current_value}"
}

prompt_secret() {
  local var_name="$1"
  local prompt_text="$2"
  local current_value="${!var_name:-}"

  if [ -z "${current_value}" ]; then
    [ -t 0 ] || die "Missing required secret for ${var_name} in non-interactive mode."
    read -r -s -p "${prompt_text}" current_value
    echo
  fi

  [ -n "${current_value}" ] || die "Missing required secret for ${var_name}."
  printf -v "${var_name}" '%s' "${current_value}"
}

setup_logging() {
  local action_name="$1"
  local log_name="$2"

  mkdir -p "${LOG_DIR}"
  LOG_FILE="${LOG_DIR}/${log_name}"
  export LOG_FILE

  exec > >(tee -a "${LOG_FILE}") 2>&1
  echo "Action: ${action_name}"
  echo "Log file: ${LOG_FILE}"
}

run_sqlplus() {
  local db_user="$1"
  local db_password="$2"
  local db_service="$3"
  local sql_script="$4"
  shift 4

  echo "Running ${sql_script} as ${db_user}@${db_service}"

  sqlplus -s /nolog <<SQL
whenever oserror exit failure rollback
whenever sqlerror exit failure rollback
connect ${db_user}/"${db_password}"@${db_service}
@${sql_script} $*
exit
SQL
}

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --owner)
        [ $# -ge 2 ] || die "Option --owner requires a value."
        OWNER="$2"
        shift 2
        ;;
      --service)
        [ $# -ge 2 ] || die "Option --service requires a value."
        SERVICE="$2"
        shift 2
        ;;
      --client)
        [ $# -ge 2 ] || die "Option --client requires a value."
        CLIENT="$2"
        shift 2
        ;;
      --default-language)
        [ $# -ge 2 ] || die "Option --default-language requires a value."
        DEFAULT_LANGUAGE="$2"
        shift 2
        ;;
      --sample-user)
        [ $# -ge 2 ] || die "Option --sample-user requires a value."
        SAMPLE_USER="$2"
        shift 2
        ;;
      --apex-user)
        [ $# -ge 2 ] || die "Option --apex-user requires a value."
        APEX_USER="$2"
        shift 2
        ;;
      --apex-workspace)
        [ $# -ge 2 ] || die "Option --apex-workspace requires a value."
        APEX_WORKSPACE="$2"
        shift 2
        ;;
      --apex-app-id)
        [ $# -ge 2 ] || die "Option --apex-app-id requires a value."
        APEX_APP_ID="$2"
        shift 2
        ;;
      --log-dir)
        [ $# -ge 2 ] || die "Option --log-dir requires a value."
        LOG_DIR="$2"
        shift 2
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        die "Unknown option: $1"
        ;;
    esac
  done
}

parse_args "$@"

case "${COMMAND}" in
  help|-h|--help)
    usage
    ;;
  install)
    OWNER="${OWNER:-${FSM_OWNER:-}}"
    SERVICE="${SERVICE:-${FSM_SERVICE:-}}"

    prompt_value OWNER "Enter owner schema for FSM: "
    prompt_secret OWNER_PW "Enter password for ${OWNER}: "
    prompt_value SERVICE "Enter service name of the database or PDB: "

    setup_logging "install" "Install_FSM.log"
    run_sqlplus "${OWNER}" "${OWNER_PW}" "${SERVICE}" "${SCRIPT_DIR}/install_scripts/install.sql" "${OWNER}" "${DEFAULT_LANGUAGE}"
    ;;
  install-client)
    OWNER="${OWNER:-${FSM_OWNER:-}}"
    SERVICE="${SERVICE:-${FSM_SERVICE:-}}"
    CLIENT="${CLIENT:-${FSM_CLIENT:-}}"

    prompt_value OWNER "Enter owner schema for FSM: "
    prompt_secret OWNER_PW "Enter password for ${OWNER}: "
    prompt_value SERVICE "Enter service name for the database or PDB: "
    prompt_value CLIENT "Enter client schema name: "
    prompt_secret CLIENT_PW "Enter password for ${CLIENT}: "

    setup_logging "install-client" "Install_FSM_client_${CLIENT}.log"
    run_sqlplus "${OWNER}" "${OWNER_PW}" "${SERVICE}" "${SCRIPT_DIR}/install_scripts/grant_client_access.sql" "${OWNER}" "${CLIENT}"
    run_sqlplus "${CLIENT}" "${CLIENT_PW}" "${SERVICE}" "${SCRIPT_DIR}/install_scripts/create_client_synonyms.sql" "${OWNER}" "${CLIENT}"
    ;;
  install-sample)
    SAMPLE_USER="${SAMPLE_USER:-${FSM_SAMPLE_USER:-}}"
    SERVICE="${SERVICE:-${FSM_SERVICE:-}}"
    APEX_USER="${APEX_USER:-${FSM_APEX_USER:-}}"

    prompt_value SAMPLE_USER "Enter schema that holds the sample business logic: "
    prompt_secret SAMPLE_USER_PW "Enter password for ${SAMPLE_USER}: "
    prompt_value SERVICE "Enter service name for the database or PDB: "
    prompt_value APEX_USER "Enter APEX schema that owns the APEX application: "
    prompt_secret APEX_USER_PW "Enter password for ${APEX_USER}: "
    prompt_value APEX_WORKSPACE "Enter name of APEX workspace: "
    prompt_value APEX_APP_ID "Enter the FSM application ID: "
    export FSM_SERVICE="${SERVICE}"
    export FSM_LOG_DIR="${LOG_DIR}"
    export FSM_SAMPLE_USER="${SAMPLE_USER}"
    export FSM_SAMPLE_USER_PW="${SAMPLE_USER_PW}"
    export FSM_APEX_USER="${APEX_USER}"
    export FSM_APEX_USER_PW="${APEX_USER_PW}"
    export FSM_APEX_WORKSPACE="${APEX_WORKSPACE}"
    export FSM_APEX_APP_ID="${APEX_APP_ID}"
    "${SCRIPT_DIR}/install_scripts/sample_app.sh" install
    ;;
  uninstall)
    OWNER="${OWNER:-${FSM_OWNER:-}}"
    SERVICE="${SERVICE:-${FSM_SERVICE:-}}"

    prompt_value OWNER "Enter owner schema of FSM: "
    prompt_secret OWNER_PW "Enter password for ${OWNER}: "
    prompt_value SERVICE "Enter service name of the database or PDB: "

    setup_logging "uninstall" "Uninstall_FSM.log"
    run_sqlplus "${OWNER}" "${OWNER_PW}" "${SERVICE}" "${SCRIPT_DIR}/install_scripts/uninstall.sql" "${OWNER}" "${OWNER}"
    ;;
  uninstall-client)
    OWNER="${OWNER:-${FSM_OWNER:-}}"
    SERVICE="${SERVICE:-${FSM_SERVICE:-}}"
    CLIENT="${CLIENT:-${FSM_CLIENT:-}}"

    prompt_value OWNER "Enter owner schema of FSM: "
    prompt_secret OWNER_PW "Enter password for ${OWNER}: "
    prompt_value SERVICE "Enter service name for the database or PDB: "
    prompt_value CLIENT "Enter client schema name: "
    prompt_secret CLIENT_PW "Enter password for ${CLIENT}: "

    setup_logging "uninstall-client" "Uninstall_FSM_client_${CLIENT}.log"
    run_sqlplus "${OWNER}" "${OWNER_PW}" "${SERVICE}" "${SCRIPT_DIR}/install_scripts/revoke_client_access.sql" "${OWNER}" "${CLIENT}"
    run_sqlplus "${CLIENT}" "${CLIENT_PW}" "${SERVICE}" "${SCRIPT_DIR}/install_scripts/uninstall_client.sql" "${OWNER}" "${CLIENT}"
    ;;
  uninstall-sample)
    SAMPLE_USER="${SAMPLE_USER:-${FSM_SAMPLE_USER:-}}"
    SERVICE="${SERVICE:-${FSM_SERVICE:-}}"
    APEX_USER="${APEX_USER:-${FSM_APEX_USER:-}}"

    prompt_value SAMPLE_USER "Enter schema that holds the sample business logic: "
    prompt_secret SAMPLE_USER_PW "Enter password for ${SAMPLE_USER}: "
    prompt_value SERVICE "Enter service name for the database or PDB: "
    prompt_value APEX_USER "Enter APEX schema that owns the APEX application: "
    prompt_secret APEX_USER_PW "Enter password for ${APEX_USER}: "
    prompt_value APEX_WORKSPACE "Enter name of APEX workspace: "
    prompt_value APEX_APP_ID "Enter the FSM application ID: "
    export FSM_SERVICE="${SERVICE}"
    export FSM_LOG_DIR="${LOG_DIR}"
    export FSM_SAMPLE_USER="${SAMPLE_USER}"
    export FSM_SAMPLE_USER_PW="${SAMPLE_USER_PW}"
    export FSM_APEX_USER="${APEX_USER}"
    export FSM_APEX_USER_PW="${APEX_USER_PW}"
    export FSM_APEX_WORKSPACE="${APEX_WORKSPACE}"
    export FSM_APEX_APP_ID="${APEX_APP_ID}"
    "${SCRIPT_DIR}/install_scripts/sample_app.sh" uninstall
    ;;
  *)
    die "Unknown command: ${COMMAND}"
    ;;
esac
