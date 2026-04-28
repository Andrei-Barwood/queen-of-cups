#!/usr/bin/env zsh

setopt NO_UNSET PIPE_FAIL

typeset -r PROJECT_ROOT="${0:A:h:h}"
typeset -r REINA_BIN="${PROJECT_ROOT}/bin/reina"
typeset -r TMP_DIR="$(mktemp -d)"

function cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

typeset -gx REINA_CONFIG_ROOT="${TMP_DIR}/config-root"
typeset -gx REINA_CACHE_ROOT="${TMP_DIR}/cache-root"
typeset -gx REINA_STATE_ROOT="${TMP_DIR}/state-root"

function assert_contains() {
  emulate -L zsh
  local haystack="${1:-}"
  local needle="${2:-}"
  local label="${3:-assertion}"

  if [[ "$haystack" != *"$needle"* ]]; then
    print -u2 -- "FAIL: ${label}"
    print -u2 -- "expected to find: ${needle}"
    return 1
  fi
}

help_output="$("$REINA_BIN" help)"
assert_contains "$help_output" "reina list" "help expone el subcomando list" || exit 1
assert_contains "$help_output" "reina info <preset>" "help expone el subcomando info" || exit 1

list_output="$("$REINA_BIN" list)"
assert_contains "$list_output" "bass-in-the-desert" "list incluye el preset fundacional" || exit 1
assert_contains "$list_output" "master-smiley-face" "list recorre el catalogo completo" || exit 1

list_json_output="$("$REINA_BIN" --json list)"
assert_contains "$list_json_output" "\"slug\":\"bass-in-the-desert\"" "list --json incluye slugs" || exit 1

info_output="$("$REINA_BIN" info bass-in-the-desert)"
assert_contains "$info_output" "display_name: Bass in the Desert" "info resuelve por slug" || exit 1

alias_info_output="$("$REINA_BIN" info ac-gtr)"
assert_contains "$alias_info_output" "slug:         acoustic-gtr" "info resuelve por alias" || exit 1

run_output="$("$REINA_BIN" run bass-in-the-desert --dry-run)"
assert_contains "$run_output" "flujo base preparado" "run entra al flujo base" || exit 1

short_run_output="$("$REINA_BIN" ac-gtr --dry-run --offline)"
assert_contains "$short_run_output" "network: offline" "forma corta respeta --offline" || exit 1

run_json_output="$("$REINA_BIN" --json --offline --dry-run run bass-in-the-desert)"
assert_contains "$run_json_output" "\"command\":\"run\"" "run --json describe el comando" || exit 1
assert_contains "$run_json_output" "\"mode\":\"offline\"" "run --json incluye contexto offline" || exit 1
assert_contains "$run_json_output" "\"client_available\":" "run --json incluye cliente de red" || exit 1

net_check_offline_output="$("$REINA_BIN" net-check --offline)"
assert_contains "$net_check_offline_output" "status:  offline" "net-check respeta --offline" || exit 1

net_check_json_output="$("$REINA_BIN" --json net-check --offline)"
assert_contains "$net_check_json_output" "\"status\":\"offline\"" "net-check --json reporta offline" || exit 1

stderr_file="$(mktemp)"
"$REINA_BIN" preset-inexistente >/dev/null 2>"$stderr_file"
exit_code=$?

if [[ "$exit_code" -eq 0 ]]; then
  print -u2 -- "FAIL: un preset inexistente no deberia salir con codigo 0"
  rm -f "$stderr_file"
  exit 1
fi
stderr_output="$(<"$stderr_file")"
rm -f "$stderr_file"

if [[ "$exit_code" -ne 3 ]]; then
  print -u2 -- "FAIL: se esperaba exit code 3 y llego $exit_code"
  exit 1
fi

assert_contains "$stderr_output" "ERR_PRESET_NOT_FOUND" "error controlado para preset inexistente" || exit 1

stderr_file="$(mktemp)"
"$REINA_BIN" info preset-inexistente >/dev/null 2>"$stderr_file"
exit_code=$?
stderr_output="$(<"$stderr_file")"
rm -f "$stderr_file"

if [[ "$exit_code" -ne 3 ]]; then
  print -u2 -- "FAIL: se esperaba exit code 3 para info inexistente y llego $exit_code"
  exit 1
fi

assert_contains "$stderr_output" "ERR_PRESET_NOT_FOUND" "info falla bien con preset inexistente" || exit 1

print -- "smoke tests passed"
