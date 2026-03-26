#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOG_DIR="${FSM_LOG_DIR:-${BASE_DIR}/logs}"

ACTION="${1:-}"

die() {
  echo "ERROR: $*" >&2
  exit 1
}

require_env() {
  local var_name="$1"
  [ -n "${!var_name:-}" ] || die "Missing required environment variable ${var_name}."
}

setup_logging() {
  local action_name="$1"
  local log_name="$2"

  mkdir -p "${LOG_DIR}"
  LOG_FILE="${LOG_DIR}/${log_name}"

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

require_env FSM_SERVICE
require_env FSM_SAMPLE_USER
require_env FSM_SAMPLE_USER_PW
require_env FSM_APEX_USER
require_env FSM_APEX_USER_PW
require_env FSM_APEX_WORKSPACE
require_env FSM_APEX_APP_ID

export NLS_LANG="${NLS_LANG:-GERMAN_GERMANY.AL32UTF8}"

case "${ACTION}" in
  install)
    setup_logging "install-sample" "Install_FSM_sample_${FSM_SAMPLE_USER}.log"
    run_sqlplus "${FSM_SAMPLE_USER}" "${FSM_SAMPLE_USER_PW}" "${FSM_SERVICE}" "${SCRIPT_DIR}/install_sample.sql" "${FSM_SAMPLE_USER}" "${FSM_APEX_USER}"
    run_sqlplus "${FSM_APEX_USER}" "${FSM_APEX_USER_PW}" "${FSM_SERVICE}" "${SCRIPT_DIR}/install_sample_app.sql" "${FSM_SAMPLE_USER}" "${FSM_APEX_USER}" "${FSM_APEX_WORKSPACE}" "${FSM_APEX_APP_ID}"
    ;;
  uninstall)
    setup_logging "uninstall-sample" "Uninstall_FSM_sample_${FSM_SAMPLE_USER}.log"
    run_sqlplus "${FSM_APEX_USER}" "${FSM_APEX_USER_PW}" "${FSM_SERVICE}" "${SCRIPT_DIR}/uninstall_sample_app.sql" "${FSM_SAMPLE_USER}" "${FSM_APEX_USER}" "${FSM_APEX_WORKSPACE}" "${FSM_APEX_APP_ID}"
    run_sqlplus "${FSM_SAMPLE_USER}" "${FSM_SAMPLE_USER_PW}" "${FSM_SERVICE}" "${SCRIPT_DIR}/uninstall_sample.sql" "${FSM_SAMPLE_USER}" "${FSM_APEX_USER}"
    ;;
  *)
    die "Unknown sample action: ${ACTION}"
    ;;
esac
