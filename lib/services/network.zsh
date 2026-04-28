function reina_network_defaults() {
  emulate -L zsh

  typeset -gx REINA_NETWORK_TIMEOUT="${REINA_NETWORK_TIMEOUT:-5}"
  typeset -gx REINA_NETWORK_RETRIES="${REINA_NETWORK_RETRIES:-2}"
  typeset -gx REINA_NETWORK_BACKOFF_MS="${REINA_NETWORK_BACKOFF_MS:-150}"
  typeset -gx REINA_NETWORK_HEALTHCHECK_URL="${REINA_NETWORK_HEALTHCHECK_URL:-https://example.com/}"
}

function reina_network_init() {
  emulate -L zsh
  reina_network_defaults

  typeset -gx REINA_NETWORK_CLIENT="${REINA_NETWORK_CURL_BIN:-curl}"
  typeset -gx REINA_NETWORK_CACHE_DIR="$(reina_storage_network_cache_dir)"
  typeset -gx REINA_NETWORK_CLIENT_AVAILABLE=0
  typeset -gx REINA_NETWORK_INITIALIZED=1

  if command -v "$REINA_NETWORK_CLIENT" >/dev/null 2>&1; then
    REINA_NETWORK_CLIENT_AVAILABLE=1
  fi

  reina_network_reset_result
  log_debug "network init offline=${REINA_OFFLINE:-0} client=$REINA_NETWORK_CLIENT available=$REINA_NETWORK_CLIENT_AVAILABLE timeout=$REINA_NETWORK_TIMEOUT retries=$REINA_NETWORK_RETRIES"
}

function reina_network_reset_result() {
  emulate -L zsh

  typeset -gx REINA_NETWORK_LAST_STATUS="idle"
  typeset -gx REINA_NETWORK_LAST_BODY=""
  typeset -gx REINA_NETWORK_LAST_HEADERS=""
  typeset -gx REINA_NETWORK_LAST_HTTP_STATUS=""
  if [[ "${REINA_OFFLINE:-0}" == "1" ]]; then
    typeset -gx REINA_NETWORK_LAST_SOURCE="offline"
  else
    typeset -gx REINA_NETWORK_LAST_SOURCE="remote"
  fi
  typeset -gx REINA_NETWORK_LAST_ELAPSED_MS=0
  typeset -gx REINA_NETWORK_LAST_ERROR=""
  typeset -gx REINA_NETWORK_LAST_ATTEMPTS=0
  typeset -gx REINA_NETWORK_LAST_ENDPOINT=""
  typeset -gx REINA_NETWORK_CURL_ERROR_KEY=""
}

function reina_network_mode() {
  emulate -L zsh

  if [[ "${REINA_OFFLINE:-0}" == "1" ]]; then
    print -- "offline"
  else
    print -- "online"
  fi
}

function reina_network_status() {
  emulate -L zsh

  if [[ "${REINA_OFFLINE:-0}" == "1" ]]; then
    print -- "offline"
  elif [[ "${REINA_NETWORK_CLIENT_AVAILABLE:-0}" != "1" ]]; then
    print -- "degraded"
  else
    print -- "available"
  fi
}

function reina_network_require_client() {
  emulate -L zsh

  if [[ "${REINA_OFFLINE:-0}" == "1" ]]; then
    reina_network_set_error ERR_NETWORK_OFFLINE "network desactivado por --offline"
    return "$(reina_error_code ERR_NETWORK_OFFLINE)"
  fi

  if [[ "${REINA_NETWORK_CLIENT_AVAILABLE:-0}" != "1" ]]; then
    reina_network_set_error ERR_NETWORK_DEPENDENCY_MISSING "curl no esta disponible para operaciones de red"
    return "$(reina_error_code ERR_NETWORK_DEPENDENCY_MISSING)"
  fi

  return 0
}

function reina_network_set_error() {
  emulate -L zsh
  local key="${1:-ERR_NETWORK_UNREACHABLE}"
  local message="${2:-$(reina_error_message "$key")}"
  local context="${3:-endpoint=${REINA_NETWORK_LAST_ENDPOINT:-}}"
  local details="${4:-attempts=${REINA_NETWORK_LAST_ATTEMPTS:-0} http_status=${REINA_NETWORK_LAST_HTTP_STATUS:-}}"

  REINA_NETWORK_LAST_STATUS="error"
  REINA_NETWORK_LAST_ERROR="$key"
  reina_fail "$key" "$message" "network" "$context" "$details"
}

function reina_network_elapsed_ms() {
  emulate -L zsh
  local seconds="${1:-0}"

  awk -v seconds="$seconds" 'BEGIN { printf "%d", seconds * 1000 }'
}

function reina_network_sleep_backoff() {
  emulate -L zsh
  local attempt="${1:-1}"
  local backoff_ms="${REINA_NETWORK_BACKOFF_MS:-150}"
  local sleep_seconds

  sleep_seconds="$(awk -v ms="$backoff_ms" -v attempt="$attempt" 'BEGIN { printf "%.3f", (ms * attempt) / 1000 }')"
  sleep "$sleep_seconds"
}

function reina_network_cache_key() {
  emulate -L zsh
  local key="${1:-}"

  print -rn -- "$key" | sed -E 's/[^A-Za-z0-9._-]+/_/g; s/^_+//; s/_+$//'
}

function reina_network_cache_body_path() {
  emulate -L zsh
  reina_storage_body_path cache "$(reina_network_cache_key "${1:-}")" network
}

function reina_network_cache_meta_path() {
  emulate -L zsh
  reina_storage_meta_path cache "$(reina_network_cache_key "${1:-}")" network
}

function reina_network_read_cache() {
  emulate -L zsh
  local cache_key="${1:-}"
  local safe_key

  [[ -n "$cache_key" ]] || return 1
  safe_key="$(reina_network_cache_key "$cache_key")"

  reina_storage_exists cache "$safe_key" network || return 1
  reina_storage_get cache "$safe_key" network >/dev/null 2>&1 || return 1

  if [[ "${REINA_OFFLINE:-0}" == "1" ]]; then
    REINA_NETWORK_LAST_STATUS="degraded"
  else
    REINA_NETWORK_LAST_STATUS="ok"
  fi
  REINA_NETWORK_LAST_SOURCE="cache"
  REINA_NETWORK_LAST_BODY="$REINA_STORE_LAST_VALUE"
  if [[ -f "$REINA_STORE_LAST_META_PATH" ]]; then
    REINA_NETWORK_LAST_HEADERS="$(<"$REINA_STORE_LAST_META_PATH")"
  else
    REINA_NETWORK_LAST_HEADERS=""
  fi
  REINA_NETWORK_LAST_HTTP_STATUS=""
  REINA_NETWORK_LAST_ELAPSED_MS=0
  REINA_NETWORK_LAST_ERROR=""

  log_debug "network cache hit key=$safe_key"
  if [[ "${REINA_OFFLINE:-0}" == "1" ]]; then
    reina_degrade ERR_NETWORK_OFFLINE "network offline; usando cache local" "network" "cache_key=$safe_key" "cache" "source=cache"
  fi
  return 0
}

function reina_network_write_cache() {
  emulate -L zsh
  local cache_key="${1:-}"
  local body="${2:-}"
  local endpoint="${3:-}"
  local safe_key

  [[ -n "$cache_key" ]] || return 0

  safe_key="$(reina_network_cache_key "$cache_key")"
  reina_storage_put cache "$safe_key" "$body" network 86400 "remote:$endpoint" || return $?

  log_debug "network cache write key=$safe_key path=$REINA_STORE_LAST_PATH"
}

function reina_network_classify_curl_error() {
  emulate -L zsh
  local curl_code="${1:-0}"

  case "$curl_code" in
    28)
      print -- "ERR_NETWORK_TIMEOUT"
      ;;
    6|7)
      print -- "ERR_NETWORK_UNREACHABLE"
      ;;
    *)
      print -- "ERR_NETWORK_UNREACHABLE"
      ;;
  esac
}

function reina_network_perform_curl() {
  emulate -L zsh
  local method="${1:-GET}"
  local endpoint="${2:-}"
  local body="${3:-}"
  local timeout="${4:-$REINA_NETWORK_TIMEOUT}"
  local body_file headers_file err_file curl_meta curl_code http_status elapsed_seconds
  local -a curl_args

  body_file="$(mktemp)"
  headers_file="$(mktemp)"
  err_file="$(mktemp)"

  curl_args=(-sS -L -D "$headers_file" -o "$body_file" --max-time "$timeout" -w "%{http_code} %{time_total}")

  if [[ "$method" == "POST" ]]; then
    curl_args+=(-X POST -H "Content-Type: application/json" --data "$body")
  fi

  curl_meta="$("$REINA_NETWORK_CLIENT" "${curl_args[@]}" "$endpoint" 2>"$err_file")"
  curl_code=$?

  REINA_NETWORK_LAST_BODY="$(<"$body_file")"
  REINA_NETWORK_LAST_HEADERS="$(<"$headers_file")"

  rm -f "$body_file" "$headers_file" "$err_file"

  if (( curl_code != 0 )); then
    REINA_NETWORK_LAST_HTTP_STATUS=""
    REINA_NETWORK_LAST_ELAPSED_MS=0
    REINA_NETWORK_CURL_ERROR_KEY="$(reina_network_classify_curl_error "$curl_code")"
    return 1
  fi

  http_status="${curl_meta%% *}"
  elapsed_seconds="${curl_meta##* }"
  REINA_NETWORK_LAST_HTTP_STATUS="$http_status"
  REINA_NETWORK_LAST_ELAPSED_MS="$(reina_network_elapsed_ms "$elapsed_seconds")"

  if [[ -z "$http_status" || "$http_status" == "000" ]]; then
    REINA_NETWORK_CURL_ERROR_KEY="ERR_NETWORK_INVALID_RESPONSE"
    return 1
  fi

  if (( http_status < 200 || http_status >= 400 )); then
    REINA_NETWORK_CURL_ERROR_KEY="ERR_NETWORK_HTTP"
    return 1
  fi

  if [[ -z "$REINA_NETWORK_LAST_BODY" ]]; then
    REINA_NETWORK_CURL_ERROR_KEY="ERR_NETWORK_EMPTY"
    return 1
  fi

  REINA_NETWORK_CURL_ERROR_KEY=""
  return 0
}

function reina_network_request() {
  emulate -L zsh
  local method="${1:-GET}"
  local endpoint="${2:-}"
  local body="${3:-}"
  local timeout="${4:-$REINA_NETWORK_TIMEOUT}"
  local retries="${5:-$REINA_NETWORK_RETRIES}"
  local cache_key="${6:-}"
  local attempt=0 max_attempts error_key message fallback_error

  reina_network_init
  reina_network_reset_result
  REINA_NETWORK_LAST_ENDPOINT="$endpoint"

  if [[ -z "$endpoint" ]]; then
    reina_network_set_error ERR_CLI_USAGE "falta endpoint para operacion de red" "method=$method"
    return $?
  fi

  if [[ "${REINA_OFFLINE:-0}" == "1" ]]; then
    if reina_network_read_cache "$cache_key"; then
      return 0
    fi

    REINA_NETWORK_LAST_STATUS="offline"
    REINA_NETWORK_LAST_SOURCE="offline"
    reina_network_set_error ERR_NETWORK_OFFLINE "network bloqueado por --offline y no hay cache disponible" "endpoint=$endpoint cache_key=$cache_key" "fallback=cache_miss"
    return $?
  fi

  reina_network_require_client || return $?

  max_attempts=$(( retries + 1 ))
  while (( attempt < max_attempts )); do
    attempt=$(( attempt + 1 ))
    REINA_NETWORK_LAST_ATTEMPTS="$attempt"
    log_debug "network $method attempt=$attempt endpoint=$endpoint timeout=$timeout"

    if reina_network_perform_curl "$method" "$endpoint" "$body" "$timeout"; then
      REINA_NETWORK_LAST_STATUS="ok"
      REINA_NETWORK_LAST_SOURCE="remote"
      REINA_NETWORK_LAST_ERROR=""
      reina_network_write_cache "$cache_key" "$REINA_NETWORK_LAST_BODY" "$endpoint" >/dev/null 2>&1 || true
      log_debug "network $method ok endpoint=$endpoint elapsed_ms=$REINA_NETWORK_LAST_ELAPSED_MS attempts=$attempt"
      return 0
    fi

    error_key="$REINA_NETWORK_CURL_ERROR_KEY"
    REINA_NETWORK_LAST_ERROR="$error_key"
    log_debug "network $method failed endpoint=$endpoint error=$error_key attempt=$attempt"

    (( attempt < max_attempts )) && reina_network_sleep_backoff "$attempt"
  done

  case "$REINA_NETWORK_LAST_ERROR" in
    ERR_NETWORK_TIMEOUT)
      message="timeout consultando $endpoint"
      ;;
    ERR_NETWORK_HTTP)
      message="respuesta HTTP no exitosa desde $endpoint status=${REINA_NETWORK_LAST_HTTP_STATUS:-unknown}"
      ;;
    ERR_NETWORK_EMPTY)
      message="respuesta vacia desde $endpoint"
      ;;
    ERR_NETWORK_INVALID_RESPONSE)
      message="respuesta invalida desde $endpoint"
      ;;
    *)
      message="endpoint inaccesible: $endpoint"
      ;;
  esac

  fallback_error="$REINA_NETWORK_LAST_ERROR"
  if [[ -n "$cache_key" ]] && reina_network_read_cache "$cache_key"; then
    REINA_NETWORK_LAST_STATUS="degraded"
    REINA_NETWORK_LAST_SOURCE="cache"
    reina_degrade "$fallback_error" "network fallo; usando cache local" "network" "endpoint=$endpoint cache_key=$cache_key" "cache" "attempts=$REINA_NETWORK_LAST_ATTEMPTS"
    return 0
  fi

  reina_network_set_error "$REINA_NETWORK_LAST_ERROR" "$message"
}

function reina_network_get() {
  emulate -L zsh

  reina_network_request GET "${1:-}" "" "${2:-$REINA_NETWORK_TIMEOUT}" "${3:-$REINA_NETWORK_RETRIES}" "${4:-}"
}

function reina_network_post() {
  emulate -L zsh

  reina_network_request POST "${1:-}" "${2:-}" "${3:-$REINA_NETWORK_TIMEOUT}" "${4:-$REINA_NETWORK_RETRIES}" "${5:-}"
}

function reina_network_fetch_to_cache() {
  emulate -L zsh
  local endpoint="${1:-}"
  local cache_key="${2:-}"

  reina_network_get "$endpoint" "${3:-$REINA_NETWORK_TIMEOUT}" "${4:-$REINA_NETWORK_RETRIES}" "$cache_key"
}

function reina_network_retry() {
  emulate -L zsh
  reina_network_request "$@"
}

function reina_network_fail() {
  emulate -L zsh
  reina_network_set_error "$@"
}

function reina_network_check() {
  emulate -L zsh
  local endpoint="${1:-${REINA_NETWORK_HEALTHCHECK_URL:-https://example.com/}}"
  local timeout="${2:-2}"
  local error_key

  reina_network_init
  reina_network_reset_result
  REINA_NETWORK_LAST_ENDPOINT="$endpoint"

  if [[ "${REINA_OFFLINE:-0}" == "1" ]]; then
    REINA_NETWORK_LAST_STATUS="offline"
    REINA_NETWORK_LAST_SOURCE="offline"
    REINA_NETWORK_LAST_ERROR="ERR_NETWORK_OFFLINE"
    log_debug "network check skipped offline endpoint=$endpoint"
    return 1
  fi

  reina_network_require_client || return $?

  if reina_network_perform_curl GET "$endpoint" "" "$timeout"; then
    REINA_NETWORK_LAST_STATUS="available"
    REINA_NETWORK_LAST_SOURCE="remote"
    REINA_NETWORK_LAST_ERROR=""
    log_debug "network check available endpoint=$endpoint elapsed_ms=$REINA_NETWORK_LAST_ELAPSED_MS"
    return 0
  fi

  error_key="$REINA_NETWORK_CURL_ERROR_KEY"

  if [[ "$error_key" == "ERR_NETWORK_EMPTY" && "${REINA_NETWORK_LAST_HTTP_STATUS:-0}" -ge 200 && "${REINA_NETWORK_LAST_HTTP_STATUS:-0}" -lt 400 ]]; then
    REINA_NETWORK_LAST_STATUS="available"
    REINA_NETWORK_LAST_SOURCE="remote"
    REINA_NETWORK_LAST_ERROR=""
    log_debug "network check available endpoint=$endpoint empty_body=true elapsed_ms=$REINA_NETWORK_LAST_ELAPSED_MS"
    return 0
  fi

  REINA_NETWORK_LAST_STATUS="degraded"
  REINA_NETWORK_LAST_SOURCE="remote"
  REINA_NETWORK_LAST_ERROR="$error_key"
  reina_degrade "$error_key" "healthcheck de red degradado" "network" "endpoint=$endpoint" "diagnostic_only" "http_status=${REINA_NETWORK_LAST_HTTP_STATUS:-}"
  log_debug "network check degraded endpoint=$endpoint error=$error_key"
  return 1
}

function reina_network_result_json() {
  emulate -L zsh

  print -rn -- "{"
  print -rn -- "\"status\":\"$(reina_json_escape "$REINA_NETWORK_LAST_STATUS")\","
  print -rn -- "\"source\":\"$(reina_json_escape "$REINA_NETWORK_LAST_SOURCE")\","
  print -rn -- "\"endpoint\":\"$(reina_json_escape "$REINA_NETWORK_LAST_ENDPOINT")\","
  print -rn -- "\"http_status\":\"$(reina_json_escape "$REINA_NETWORK_LAST_HTTP_STATUS")\","
  print -rn -- "\"elapsed_ms\":${REINA_NETWORK_LAST_ELAPSED_MS:-0},"
  print -rn -- "\"attempts\":${REINA_NETWORK_LAST_ATTEMPTS:-0},"
  print -rn -- "\"body\":\"$(reina_json_escape "$REINA_NETWORK_LAST_BODY")\","
  print -rn -- "\"headers\":\"$(reina_json_escape "$REINA_NETWORK_LAST_HEADERS")\","
  print -rn -- "\"error\":\"$(reina_json_escape "$REINA_NETWORK_LAST_ERROR")\""
  print -rn -- "}"
}

function reina_network_context_json() {
  emulate -L zsh

  print -rn -- "{"
  print -rn -- "\"mode\":\"$(reina_json_escape "$(reina_network_mode)")\","
  print -rn -- "\"status\":\"$(reina_json_escape "$(reina_network_status)")\","
  print -rn -- "\"offline\":$(reina_json_bool "${REINA_OFFLINE:-0}"),"
  print -rn -- "\"timeout\":${REINA_NETWORK_TIMEOUT:-5},"
  print -rn -- "\"retries\":${REINA_NETWORK_RETRIES:-2},"
  print -rn -- "\"debug\":$(reina_json_bool "${REINA_DEBUG:-0}"),"
  print -rn -- "\"client\":\"$(reina_json_escape "${REINA_NETWORK_CLIENT:-curl}")\","
  print -rn -- "\"client_available\":$(reina_json_bool "${REINA_NETWORK_CLIENT_AVAILABLE:-0}"),"
  print -rn -- "\"cache_dir\":\"$(reina_json_escape "${REINA_NETWORK_CACHE_DIR:-$(reina_storage_network_cache_dir)}")\""
  print -rn -- "}"
}

# Short contract aliases used in roadmap notes.
function net_init() { reina_network_init "$@" }
function net_check() { reina_network_check "$@" }
function net_get() { reina_network_get "$@" }
function net_post() { reina_network_post "$@" }
function net_fetch_to_cache() { reina_network_fetch_to_cache "$@" }
function net_retry() { reina_network_retry "$@" }
function net_fail() { reina_network_fail "$@" }
