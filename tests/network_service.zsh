#!/usr/bin/env zsh

setopt NO_UNSET PIPE_FAIL

typeset -r PROJECT_ROOT="${0:A:h:h}"
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
    print -rn -- "200 0.042"
    exit 0
    ;;
  timeout)
    print -u2 -- "operation timed out"
    exit 28
    ;;
  unreachable)
    print -u2 -- "could not connect"
    exit 7
    ;;
  http)
    [[ -n "$body_file" ]] && print -- "server error" > "$body_file"
    print -rn -- "500 0.010"
    exit 0
    ;;
  empty)
    [[ -n "$body_file" ]] && : > "$body_file"
    print -rn -- "200 0.010"
    exit 0
    ;;
  invalid)
    [[ -n "$body_file" ]] && print -- "broken" > "$body_file"
    print -rn -- "000 0.000"
    exit 0
    ;;
esac
EOF

chmod +x "$STUB_CURL"

typeset -gx REINA_PROJECT_ROOT="$PROJECT_ROOT"
typeset -gx REINA_RUNTIME_MODE=local
typeset -gx REINA_NETWORK_CURL_BIN="$STUB_CURL"
typeset -gx REINA_NETWORK_TIMEOUT=1
typeset -gx REINA_NETWORK_RETRIES=0
typeset -gx REINA_NETWORK_BACKOFF_MS=1
typeset -gx REINA_DEBUG=0
typeset -gx REINA_QUIET=1
typeset -gx REINA_OFFLINE=0

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

typeset -gx REINA_STUB_CURL_MODE=success
reina_network_check "https://example.test/health"
assert_eq "available" "$REINA_NETWORK_LAST_STATUS" "healthcheck exitoso marca available" || exit 1

reina_network_get "https://example.test/profile" 1 0 "profile"
assert_eq "ok" "$REINA_NETWORK_LAST_STATUS" "GET exitoso marca status ok" || exit 1
assert_eq "remote" "$REINA_NETWORK_LAST_SOURCE" "GET exitoso viene de remote" || exit 1
assert_eq "hello remote" "$REINA_NETWORK_LAST_BODY" "GET exitoso guarda body" || exit 1

REINA_OFFLINE=1
reina_network_get "https://example.test/profile" 1 0 "profile"
assert_eq "cache" "$REINA_NETWORK_LAST_SOURCE" "offline usa cache si existe" || exit 1
assert_eq "hello remote" "$REINA_NETWORK_LAST_BODY" "offline lee body desde cache" || exit 1

stderr_file="${TMP_DIR}/offline.err"
reina_network_get "https://example.test/missing" 1 0 "missing" >/dev/null 2>"$stderr_file"
exit_code=$?
assert_nonzero "$exit_code" "offline sin cache falla controlado" || exit 1
assert_eq "ERR_NETWORK_OFFLINE" "$REINA_NETWORK_LAST_ERROR" "offline sin cache reporta error correcto" || exit 1

REINA_OFFLINE=0
REINA_STUB_CURL_MODE=timeout
stderr_file="${TMP_DIR}/timeout.err"
reina_network_get "https://example.test/slow" 1 0 "" >/dev/null 2>"$stderr_file"
exit_code=$?
assert_nonzero "$exit_code" "timeout devuelve error" || exit 1
assert_eq "ERR_NETWORK_TIMEOUT" "$REINA_NETWORK_LAST_ERROR" "timeout tipificado" || exit 1

REINA_STUB_CURL_MODE=unreachable
stderr_file="${TMP_DIR}/unreachable.err"
reina_network_get "https://example.test/unreachable" 1 0 "" >/dev/null 2>"$stderr_file"
exit_code=$?
assert_nonzero "$exit_code" "endpoint inaccesible devuelve error" || exit 1
assert_eq "ERR_NETWORK_UNREACHABLE" "$REINA_NETWORK_LAST_ERROR" "endpoint inaccesible tipificado" || exit 1

REINA_STUB_CURL_MODE=http
stderr_file="${TMP_DIR}/http.err"
reina_network_get "https://example.test/http" 1 0 "" >/dev/null 2>"$stderr_file"
exit_code=$?
assert_nonzero "$exit_code" "HTTP no exitoso devuelve error" || exit 1
assert_eq "ERR_NETWORK_HTTP" "$REINA_NETWORK_LAST_ERROR" "HTTP no exitoso tipificado" || exit 1

REINA_STUB_CURL_MODE=empty
stderr_file="${TMP_DIR}/empty.err"
reina_network_get "https://example.test/empty" 1 0 "" >/dev/null 2>"$stderr_file"
exit_code=$?
assert_nonzero "$exit_code" "body vacio devuelve error" || exit 1
assert_eq "ERR_NETWORK_EMPTY" "$REINA_NETWORK_LAST_ERROR" "body vacio tipificado" || exit 1

REINA_NETWORK_CURL_BIN="${TMP_DIR}/missing-curl"
stderr_file="${TMP_DIR}/missing.err"
reina_network_get "https://example.test/profile" 1 0 "" >/dev/null 2>"$stderr_file"
exit_code=$?
assert_nonzero "$exit_code" "curl faltante devuelve error" || exit 1
assert_eq "ERR_NETWORK_DEPENDENCY_MISSING" "$REINA_NETWORK_LAST_ERROR" "curl faltante tipificado" || exit 1

print -- "network service tests passed"
