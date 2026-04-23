#!/usr/bin/env zsh

setopt NO_UNSET PIPE_FAIL

typeset -r PROJECT_ROOT="${0:A:h:h}"
typeset -r REINA_BIN="${PROJECT_ROOT}/bin/reina"

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

list_output="$("$REINA_BIN" list)"
assert_contains "$list_output" "bass-in-the-desert" "list incluye el preset fundacional" || exit 1
assert_contains "$list_output" "master-smiley-face" "list recorre el catalogo completo" || exit 1

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

print -- "smoke tests passed"
