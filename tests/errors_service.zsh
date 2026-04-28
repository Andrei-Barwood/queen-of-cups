#!/usr/bin/env zsh

setopt NO_UNSET PIPE_FAIL

typeset -r PROJECT_ROOT="${0:A:h:h}"
typeset -r REINA_BIN="${PROJECT_ROOT}/bin/reina"
typeset -r TMP_DIR="$(mktemp -d)"
typeset -r STUB_CURL="${TMP_DIR}/curl-stub"

function cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

cat > "$STUB_CURL" <<'EOF'
#!/usr/bin/env zsh

body_file=""
headers_file=""

while (( $# > 0 )); do
  case "$1" in
    -o)
      shift
      body_file="$1"
      ;;
    -D)
      shift
      headers_file="$1"
      ;;
  esac

  shift
done

[[ -n "$headers_file" ]] && print -- "HTTP/1.1 200 OK" > "$headers_file"

case "${REINA_STUB_CURL_MODE:-success}" in
  success)
    [[ -n "$body_file" ]] && print -- "hello remote" > "$body_file"
    print -rn -- "200 0.010"
    exit 0
    ;;
  timeout)
    print -u2 -- "operation timed out"
    exit 28
    ;;
esac
EOF

chmod +x "$STUB_CURL"

typeset -gx REINA_PROJECT_ROOT="$PROJECT_ROOT"
typeset -gx REINA_CONFIG_ROOT="${TMP_DIR}/config-root"
typeset -gx REINA_CACHE_ROOT="${TMP_DIR}/cache-root"
typeset -gx REINA_STATE_ROOT="${TMP_DIR}/state-root"
typeset -gx REINA_NETWORK_CURL_BIN="$STUB_CURL"
typeset -gx REINA_NETWORK_TIMEOUT=1
typeset -gx REINA_NETWORK_RETRIES=0
typeset -gx REINA_NETWORK_BACKOFF_MS=1
typeset -gx REINA_DEBUG=0
typeset -gx REINA_QUIET=1
typeset -gx REINA_OFFLINE=0
typeset -gx REINA_JSON=0

source "$PROJECT_ROOT/lib/core/logging.zsh"
source "$PROJECT_ROOT/lib/core/json.zsh"
source "$PROJECT_ROOT/lib/services/errors.zsh"
source "$PROJECT_ROOT/lib/services/storage.zsh"
source "$PROJECT_ROOT/lib/services/network.zsh"

function assert_eq() {
  emulate -L zsh
  local expected="${1:-}"
  local actual="${2:-}"
  local label="${3:-assertion}"

  if [[ "$expected" != "$actual" ]]; then
    print -u2 -- "FAIL: $label"
    print -u2 -- "expected: $expected"
    print -u2 -- "actual:   $actual"
    return 1
  fi
}

function assert_contains() {
  emulate -L zsh
  local haystack="${1:-}"
  local needle="${2:-}"
  local label="${3:-assertion}"

  if [[ "$haystack" != *"$needle"* ]]; then
    print -u2 -- "FAIL: $label"
    print -u2 -- "expected to find: $needle"
    return 1
  fi
}

function assert_not_contains() {
  emulate -L zsh
  local haystack="${1:-}"
  local needle="${2:-}"
  local label="${3:-assertion}"

  if [[ "$haystack" == *"$needle"* ]]; then
    print -u2 -- "FAIL: $label"
    print -u2 -- "did not expect to find: $needle"
    return 1
  fi
}

function assert_nonzero() {
  emulate -L zsh
  local code="${1:-0}"
  local label="${2:-assertion}"

  if (( code == 0 )); then
    print -u2 -- "FAIL: $label"
    print -u2 -- "expected non-zero status"
    return 1
  fi
}

stderr_file="${TMP_DIR}/invalid-json.err"
json_output="$(
  REINA_CONFIG_ROOT="${TMP_DIR}/cli-config" \
  REINA_CACHE_ROOT="${TMP_DIR}/cli-cache" \
  REINA_STATE_ROOT="${TMP_DIR}/cli-state" \
  "$REINA_BIN" --json not-a-command extra 2>"$stderr_file"
)"
exit_code=$?
assert_eq "2" "$exit_code" "comando invalido usa exit code 2" || exit 1
assert_contains "$json_output" "\"ok\":false" "error JSON marca ok false" || exit 1
assert_contains "$json_output" "\"code\":\"ERR_CLI_INVALID_COMMAND\"" "error JSON usa codigo canonico" || exit 1
assert_contains "$json_output" "\"exit_code\":2" "error JSON expone exit code" || exit 1

if [[ -s "$stderr_file" ]]; then
  print -u2 -- "FAIL: --json no deberia emitir texto humano en stderr"
  print -u2 -- "$(<"$stderr_file")"
  exit 1
fi

stderr_file="${TMP_DIR}/missing-json.err"
missing_output="$(
  REINA_CONFIG_ROOT="${TMP_DIR}/missing-config" \
  REINA_CACHE_ROOT="${TMP_DIR}/missing-cache" \
  REINA_STATE_ROOT="${TMP_DIR}/missing-state" \
  "$REINA_BIN" --json info preset-inexistente 2>"$stderr_file"
)"
exit_code=$?
assert_eq "3" "$exit_code" "preset inexistente usa exit code 3" || exit 1
assert_contains "$missing_output" "\"code\":\"ERR_PRESET_NOT_FOUND\"" "preset inexistente serializa codigo" || exit 1
assert_contains "$missing_output" "\"source\":\"preset\"" "preset inexistente serializa source" || exit 1

quiet_stderr="$({
  REINA_CONFIG_ROOT="${TMP_DIR}/quiet-config" \
  REINA_CACHE_ROOT="${TMP_DIR}/quiet-cache" \
  REINA_STATE_ROOT="${TMP_DIR}/quiet-state" \
  "$REINA_BIN" --quiet not-a-command extra >/dev/null
} 2>&1)"
exit_code=$?
assert_eq "2" "$exit_code" "--quiet conserva exit code" || exit 1
assert_not_contains "$quiet_stderr" "error context=" "--quiet no muestra contexto debug" || exit 1

stderr_file="${TMP_DIR}/debug.err"
REINA_CONFIG_ROOT="${TMP_DIR}/debug-config" \
REINA_CACHE_ROOT="${TMP_DIR}/debug-cache" \
REINA_STATE_ROOT="${TMP_DIR}/debug-state" \
"$REINA_BIN" --debug not-a-command extra >/dev/null 2>"$stderr_file"
exit_code=$?
debug_stderr="$(<"$stderr_file")"
assert_eq "2" "$exit_code" "--debug conserva exit code" || exit 1
assert_contains "$debug_stderr" "reina: debug: error source=cli" "--debug muestra source" || exit 1
assert_contains "$debug_stderr" "error context=command=not-a-command" "--debug muestra contexto" || exit 1

reina_error_reset
typeset -gx REINA_STUB_CURL_MODE=timeout
stderr_file="${TMP_DIR}/timeout.err"
reina_network_get "https://example.test/slow" 1 0 "" >/dev/null 2>"$stderr_file"
exit_code=$?
assert_eq "4" "$exit_code" "timeout de red usa exit code 4" || exit 1
assert_eq "ERR_NETWORK_TIMEOUT" "$REINA_ERROR_LAST_CODE" "timeout registra codigo comun" || exit 1
assert_eq "NETWORK" "$REINA_ERROR_LAST_KIND" "timeout registra familia NETWORK" || exit 1

reina_error_reset
corrupt_path="$(reina_storage_body_path cache corrupt network)"
mkdir -p "$corrupt_path" || exit 1
stderr_file="${TMP_DIR}/corrupt.err"
reina_storage_get cache corrupt network >/dev/null 2>"$stderr_file"
exit_code=$?
assert_eq "5" "$exit_code" "storage corrupto usa exit code 5" || exit 1
assert_eq "ERR_STORE_CORRUPT" "$REINA_ERROR_LAST_CODE" "storage corrupto registra codigo comun" || exit 1
assert_eq "STORAGE" "$REINA_ERROR_LAST_KIND" "storage corrupto registra familia STORAGE" || exit 1
rm -rf "$corrupt_path"

reina_error_reset
typeset -gx REINA_OFFLINE=0
typeset -gx REINA_STUB_CURL_MODE=success
reina_network_get "https://example.test/profile" 1 0 "profile" >/dev/null || exit 1

typeset -gx REINA_OFFLINE=1
stderr_file="${TMP_DIR}/fallback.err"
reina_network_get "https://example.test/profile" 1 0 "profile" >/dev/null 2>"$stderr_file"
exit_code=$?
assert_eq "0" "$exit_code" "fallback a cache conserva exit code 0" || exit 1
assert_eq "degraded" "${REINA_RESULT_STATUS:-ok}" "fallback marca resultado degradado" || exit 1
assert_eq "cache" "$REINA_NETWORK_LAST_SOURCE" "fallback usa cache" || exit 1
assert_contains "$(reina_error_records_json degradations)" "ERR_NETWORK_OFFLINE" "degradacion queda serializada" || exit 1

print -- "errors service tests passed"
