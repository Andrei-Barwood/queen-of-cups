function reina_error_json_escape() {
  emulate -L zsh
  local value="${1:-}"

  if whence -w reina_json_escape >/dev/null 2>&1; then
    reina_json_escape "$value"
    return $?
  fi

  print -rn -- "$value" | sed 's/\\/\\\\/g; s/"/\\"/g; s/	/\\t/g'
}

function reina_error_json_bool() {
  emulate -L zsh
  local value="${1:-0}"

  if whence -w reina_json_bool >/dev/null 2>&1; then
    reina_json_bool "$value"
    return $?
  fi

  if [[ "$value" == "1" || "$value" == "true" ]]; then
    print -rn -- "true"
  else
    print -rn -- "false"
  fi
}

function reina_error_canonical() {
  emulate -L zsh

  case "${1:-ERR_INTERNAL}" in
    ERR_USAGE)
      print -- "ERR_CLI_USAGE"
      ;;
    ERR_ARGUMENT_MISSING)
      print -- "ERR_INPUT_ARGUMENT_MISSING"
      ;;
    ERR_COMMAND_INVALID)
      print -- "ERR_CLI_INVALID_COMMAND"
      ;;
    ERR_COMMAND_NOT_IMPLEMENTED)
      print -- "ERR_CLI_NOT_IMPLEMENTED"
      ;;
    ERR_ALIAS_AMBIGUOUS)
      print -- "ERR_PRESET_ALIAS_AMBIGUOUS"
      ;;
    ERR_MANIFEST_MISSING)
      print -- "ERR_RUNTIME_MANIFEST_MISSING"
      ;;
    ERR_MANIFEST_INVALID)
      print -- "ERR_RUNTIME_MANIFEST_INVALID"
      ;;
    ERR_VERSION_UNSUPPORTED)
      print -- "ERR_RUNTIME_VERSION_UNSUPPORTED"
      ;;
    ERR_DEPENDENCY_MISSING)
      print -- "ERR_RUNTIME_DEPENDENCY_MISSING"
      ;;
    ERR_STORAGE_FAILURE)
      print -- "ERR_STORE_FAILURE"
      ;;
    *)
      print -- "${1:-ERR_INTERNAL}"
      ;;
  esac
}

function reina_error_kind() {
  emulate -L zsh
  local code
  code="$(reina_error_canonical "${1:-ERR_INTERNAL}")"

  case "$code" in
    ERR_CLI_*)
      print -- "CLI"
      ;;
    ERR_PRESET_*)
      print -- "PRESET"
      ;;
    ERR_NETWORK_*)
      print -- "NETWORK"
      ;;
    ERR_STORE_*)
      print -- "STORAGE"
      ;;
    ERR_INPUT_*)
      print -- "INPUT"
      ;;
    ERR_RUNTIME_*)
      print -- "RUNTIME"
      ;;
    *)
      print -- "INTERNAL"
      ;;
  esac
}

function reina_error_default_source() {
  emulate -L zsh
  local kind
  kind="$(reina_error_kind "${1:-ERR_INTERNAL}")"
  print -rn -- "$kind" | tr '[:upper:]' '[:lower:]'
}

function reina_error_code() {
  emulate -L zsh
  local code
  code="$(reina_error_canonical "${1:-ERR_INTERNAL}")"

  case "$code" in
    ERR_CLI_*|ERR_INPUT_*)
      print -- 2
      ;;
    ERR_PRESET_NOT_FOUND|ERR_PRESET_ALIAS_AMBIGUOUS|ERR_PRESET_NOT_IMPLEMENTED|ERR_STORE_NOT_FOUND|ERR_RUNTIME_MANIFEST_MISSING)
      print -- 3
      ;;
    ERR_RUNTIME_*|ERR_NETWORK_DEPENDENCY_MISSING)
      print -- 6
      ;;
    ERR_NETWORK_*)
      print -- 4
      ;;
    ERR_STORE_*)
      print -- 5
      ;;
    ERR_INTERNAL|ERR_RUNTIME_MANIFEST_INVALID)
      print -- 7
      ;;
    *)
      print -- 1
      ;;
  esac
}

function reina_error_message() {
  emulate -L zsh
  local code
  code="$(reina_error_canonical "${1:-ERR_INTERNAL}")"

  case "$code" in
    ERR_CLI_USAGE)
      print -- "uso invalido"
      ;;
    ERR_INPUT_ARGUMENT_MISSING)
      print -- "falta un argumento requerido"
      ;;
    ERR_INPUT_INVALID_FLAG)
      print -- "flag invalida"
      ;;
    ERR_CLI_INVALID_COMMAND)
      print -- "comando invalido"
      ;;
    ERR_CLI_NOT_IMPLEMENTED)
      print -- "comando reconocido pero aun no implementado"
      ;;
    ERR_PRESET_NOT_FOUND)
      print -- "preset no encontrado"
      ;;
    ERR_PRESET_ALIAS_AMBIGUOUS)
      print -- "alias ambiguo"
      ;;
    ERR_PRESET_NOT_IMPLEMENTED)
      print -- "preset aun no implementado"
      ;;
    ERR_RUNTIME_MANIFEST_MISSING)
      print -- "manifest no encontrado"
      ;;
    ERR_RUNTIME_MANIFEST_INVALID)
      print -- "manifest invalido"
      ;;
    ERR_RUNTIME_VERSION_UNSUPPORTED)
      print -- "version de zsh no soportada"
      ;;
    ERR_RUNTIME_DEPENDENCY_MISSING)
      print -- "dependencia faltante"
      ;;
    ERR_NETWORK_UNAVAILABLE)
      print -- "servicio de red no disponible"
      ;;
    ERR_NETWORK_OFFLINE)
      print -- "network desactivado por modo offline"
      ;;
    ERR_NETWORK_TIMEOUT)
      print -- "timeout de red"
      ;;
    ERR_NETWORK_UNREACHABLE)
      print -- "endpoint de red inaccesible"
      ;;
    ERR_NETWORK_HTTP)
      print -- "respuesta HTTP no exitosa"
      ;;
    ERR_NETWORK_EMPTY)
      print -- "respuesta de red vacia"
      ;;
    ERR_NETWORK_INVALID_RESPONSE)
      print -- "respuesta de red invalida"
      ;;
    ERR_NETWORK_DEPENDENCY_MISSING)
      print -- "dependencia de red faltante"
      ;;
    ERR_STORE_FAILURE)
      print -- "fallo de almacenamiento"
      ;;
    ERR_STORE_INIT)
      print -- "no se pudo inicializar storage"
      ;;
    ERR_STORE_NOT_FOUND)
      print -- "entrada de storage no encontrada"
      ;;
    ERR_STORE_CORRUPT)
      print -- "entrada de storage corrupta"
      ;;
    ERR_STORE_WRITE)
      print -- "no se pudo escribir storage"
      ;;
    ERR_STORE_READ)
      print -- "no se pudo leer storage"
      ;;
    ERR_STORE_PRUNE)
      print -- "no se pudo limpiar storage"
      ;;
    ERR_STORE_LOCKED)
      print -- "storage bloqueado"
      ;;
    ERR_STORE_RUNTIME_INVALID)
      print -- "runtime de storage invalido"
      ;;
    *)
      print -- "fallo interno inesperado"
      ;;
  esac
}

function reina_error_reset() {
  emulate -L zsh

  typeset -gx REINA_RESULT_STATUS="ok"
  typeset -gx REINA_ERROR_LAST_CODE=""
  typeset -gx REINA_ERROR_LAST_KIND=""
  typeset -gx REINA_ERROR_LAST_MESSAGE=""
  typeset -gx REINA_ERROR_LAST_DETAILS=""
  typeset -gx REINA_ERROR_LAST_SOURCE=""
  typeset -gx REINA_ERROR_LAST_CONTEXT=""
  typeset -gx REINA_ERROR_LAST_FATAL=0
  typeset -gx REINA_ERROR_LAST_FALLBACK_APPLIED=0
  typeset -gx REINA_ERROR_LAST_EXIT_CODE=0
  typeset -ga REINA_WARNING_RECORDS
  typeset -ga REINA_DEGRADATION_RECORDS
  REINA_WARNING_RECORDS=()
  REINA_DEGRADATION_RECORDS=()
}

function reina_error_ensure_state() {
  emulate -L zsh

  if [[ -z "${REINA_RESULT_STATUS+x}" ]]; then
    reina_error_reset
  fi
}

function reina_error_record() {
  emulate -L zsh
  local code="${1:-ERR_INTERNAL}"
  local message="${2:-$(reina_error_message "$code")}"
  local source="${3:-$(reina_error_default_source "$code")}"
  local context="${4:-}"
  local details="${5:-}"
  local fatal="${6:-1}"
  local fallback_applied="${7:-0}"
  local canonical kind exit_code

  reina_error_ensure_state

  canonical="$(reina_error_canonical "$code")"
  kind="$(reina_error_kind "$canonical")"
  exit_code="$(reina_error_code "$canonical")"

  typeset -gx REINA_ERROR_LAST_CODE="$canonical"
  typeset -gx REINA_ERROR_LAST_KIND="$kind"
  typeset -gx REINA_ERROR_LAST_MESSAGE="${message:-$(reina_error_message "$canonical")}"
  typeset -gx REINA_ERROR_LAST_DETAILS="$details"
  typeset -gx REINA_ERROR_LAST_SOURCE="$source"
  typeset -gx REINA_ERROR_LAST_CONTEXT="$context"
  typeset -gx REINA_ERROR_LAST_FATAL="$fatal"
  typeset -gx REINA_ERROR_LAST_FALLBACK_APPLIED="$fallback_applied"
  typeset -gx REINA_ERROR_LAST_EXIT_CODE="$exit_code"

  if [[ "$fatal" == "1" || "$fatal" == "true" ]]; then
    REINA_RESULT_STATUS="failed"
  elif [[ "$fallback_applied" == "1" || "$fallback_applied" == "true" ]]; then
    [[ "$REINA_RESULT_STATUS" == "failed" ]] || REINA_RESULT_STATUS="degraded"
  fi
}

function reina_error_json() {
  emulate -L zsh

  reina_error_ensure_state

  print -rn -- "{"
  print -rn -- "\"code\":\"$(reina_error_json_escape "$REINA_ERROR_LAST_CODE")\","
  print -rn -- "\"kind\":\"$(reina_error_json_escape "$REINA_ERROR_LAST_KIND")\","
  print -rn -- "\"message\":\"$(reina_error_json_escape "$REINA_ERROR_LAST_MESSAGE")\","
  print -rn -- "\"details\":\"$(reina_error_json_escape "$REINA_ERROR_LAST_DETAILS")\","
  print -rn -- "\"source\":\"$(reina_error_json_escape "$REINA_ERROR_LAST_SOURCE")\","
  print -rn -- "\"context\":\"$(reina_error_json_escape "$REINA_ERROR_LAST_CONTEXT")\","
  print -rn -- "\"fatal\":$(reina_error_json_bool "$REINA_ERROR_LAST_FATAL"),"
  print -rn -- "\"fallback_applied\":$(reina_error_json_bool "$REINA_ERROR_LAST_FALLBACK_APPLIED"),"
  print -rn -- "\"exit_code\":${REINA_ERROR_LAST_EXIT_CODE:-1}"
  print -rn -- "}"
}

function reina_error_record_json() {
  emulate -L zsh
  local record="${1:-}"
  local code kind message source context details fallback_applied

  IFS=$'\t' read -r code kind message source context details fallback_applied <<< "$record"

  print -rn -- "{"
  print -rn -- "\"code\":\"$(reina_error_json_escape "$code")\","
  print -rn -- "\"kind\":\"$(reina_error_json_escape "$kind")\","
  print -rn -- "\"message\":\"$(reina_error_json_escape "$message")\","
  print -rn -- "\"source\":\"$(reina_error_json_escape "$source")\","
  print -rn -- "\"context\":\"$(reina_error_json_escape "$context")\","
  print -rn -- "\"details\":\"$(reina_error_json_escape "$details")\","
  print -rn -- "\"fallback_applied\":$(reina_error_json_bool "$fallback_applied")"
  print -rn -- "}"
}

function reina_error_records_json() {
  emulate -L zsh
  local collection="${1:-warnings}"
  local first=1 record
  local -a records

  reina_error_ensure_state

  if [[ "$collection" == "degradations" ]]; then
    records=("${REINA_DEGRADATION_RECORDS[@]}")
  else
    records=("${REINA_WARNING_RECORDS[@]}")
  fi

  print -rn -- "["
  for record in "${records[@]}"; do
    if (( first )); then
      first=0
    else
      print -rn -- ","
    fi

    reina_error_record_json "$record"
  done
  print -rn -- "]"
}

function reina_error_result_json() {
  emulate -L zsh
  local exit_code="${REINA_ERROR_LAST_EXIT_CODE:-1}"

  print -rn -- "{"
  print -rn -- "\"ok\":false,"
  print -rn -- "\"degraded\":false,"
  print -rn -- "\"status\":\"failed\","
  print -rn -- "\"code\":\"$(reina_error_json_escape "$REINA_ERROR_LAST_CODE")\","
  print -rn -- "\"message\":\"$(reina_error_json_escape "$REINA_ERROR_LAST_MESSAGE")\","
  print -rn -- "\"source\":\"$(reina_error_json_escape "$REINA_ERROR_LAST_SOURCE")\","
  print -rn -- "\"context\":\"$(reina_error_json_escape "$REINA_ERROR_LAST_CONTEXT")\","
  print -rn -- "\"exit_code\":$exit_code,"
  print -rn -- "\"error\":$(reina_error_json),"
  print -rn -- "\"warnings\":$(reina_error_records_json warnings),"
  print -rn -- "\"degradations\":$(reina_error_records_json degradations)"
  print -- "}"
}

function reina_error_emit() {
  emulate -L zsh
  local level="${1:-error}"
  local prefix message

  reina_error_ensure_state

  if (( ${REINA_JSON:-0} )); then
    [[ "$level" == "error" ]] && reina_error_result_json
    return 0
  fi

  prefix="reina: $level:"
  message="${REINA_ERROR_LAST_MESSAGE} (${REINA_ERROR_LAST_CODE})"

  if (( ${REINA_QUIET:-0} )) && (( ! ${REINA_DEBUG:-0} )); then
    [[ "$level" == "error" ]] || return 0
    print -u2 -- "$prefix $message"
    return 0
  fi

  case "$level" in
    warn)
      if whence -w log_warn >/dev/null 2>&1; then
        log_warn "$message"
      else
        print -u2 -- "$prefix $message"
      fi
      ;;
    degraded)
      if whence -w log_warn >/dev/null 2>&1; then
        log_warn "degradado: $message"
      else
        print -u2 -- "$prefix $message"
      fi
      ;;
    *)
      if whence -w log_error >/dev/null 2>&1; then
        log_error "$message"
      else
        print -u2 -- "$prefix $message"
      fi
      ;;
  esac

  if (( ${REINA_DEBUG:-0} )); then
    log_debug "error source=${REINA_ERROR_LAST_SOURCE} fatal=$(reina_error_json_bool "$REINA_ERROR_LAST_FATAL") fallback=$(reina_error_json_bool "$REINA_ERROR_LAST_FALLBACK_APPLIED") exit_code=${REINA_ERROR_LAST_EXIT_CODE}"
    [[ -n "$REINA_ERROR_LAST_CONTEXT" ]] && log_debug "error context=$REINA_ERROR_LAST_CONTEXT"
    [[ -n "$REINA_ERROR_LAST_DETAILS" ]] && log_debug "error details=$REINA_ERROR_LAST_DETAILS"
  fi
}

function reina_warn() {
  emulate -L zsh
  local code="${1:-ERR_INTERNAL}"
  local message="${2:-$(reina_error_message "$code")}"
  local source="${3:-$(reina_error_default_source "$code")}"
  local context="${4:-}"
  local details="${5:-}"
  local canonical kind record

  reina_error_record "$code" "$message" "$source" "$context" "$details" 0 0
  canonical="$REINA_ERROR_LAST_CODE"
  kind="$REINA_ERROR_LAST_KIND"
  record="${canonical}"$'\t'"${kind}"$'\t'"${message}"$'\t'"${source}"$'\t'"${context}"$'\t'"${details}"$'\t'"0"
  REINA_WARNING_RECORDS+=("$record")
  reina_error_emit warn
}

function reina_degrade() {
  emulate -L zsh
  local code="${1:-ERR_INTERNAL}"
  local message="${2:-$(reina_error_message "$code")}"
  local source="${3:-$(reina_error_default_source "$code")}"
  local context="${4:-}"
  local fallback="${5:-fallback}"
  local details="${6:-}"
  local canonical kind record

  reina_error_record "$code" "$message" "$source" "$context" "$details" 0 1
  canonical="$REINA_ERROR_LAST_CODE"
  kind="$REINA_ERROR_LAST_KIND"
  record="${canonical}"$'\t'"${kind}"$'\t'"${message}"$'\t'"${source}"$'\t'"${context}"$'\t'"fallback=${fallback}; ${details}"$'\t'"1"
  REINA_DEGRADATION_RECORDS+=("$record")
  reina_error_emit degraded
}

function reina_recover_last_error_as_degradation() {
  emulate -L zsh
  local fallback="${1:-fallback}"
  local code="${REINA_ERROR_LAST_CODE:-ERR_INTERNAL}"
  local message="${REINA_ERROR_LAST_MESSAGE:-$(reina_error_message "$code")}"
  local source="${REINA_ERROR_LAST_SOURCE:-$(reina_error_default_source "$code")}"
  local context="${REINA_ERROR_LAST_CONTEXT:-}"
  local details="${REINA_ERROR_LAST_DETAILS:-}"

  REINA_RESULT_STATUS="ok"
  reina_degrade "$code" "$message" "$source" "$context" "$fallback" "$details"
}

function reina_fail() {
  emulate -L zsh
  local key="${1:-ERR_INTERNAL}"
  local message="${2:-$(reina_error_message "$key")}"
  local source="${3:-$(reina_error_default_source "$key")}"
  local context="${4:-}"
  local details="${5:-}"

  reina_error_record "$key" "$message" "$source" "$context" "$details" 1 0
  reina_error_emit error

  return "$(reina_error_code "$key")"
}
