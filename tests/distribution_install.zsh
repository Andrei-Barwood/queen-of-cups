#!/usr/bin/env zsh

setopt NO_UNSET PIPE_FAIL

typeset -r PROJECT_ROOT="${0:A:h:h}"
typeset -r TMP_DIR="$(mktemp -d)"
typeset -r PREFIX="${TMP_DIR}/prefix"
typeset -r VERSION="$(<"$PROJECT_ROOT/VERSION")"

function cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

function fail() {
  print -u2 -- "FAIL: $*"
  return 1
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

function assert_file() {
  emulate -L zsh
  local target_path="${1:-}"
  local label="${2:-file exists}"

  [[ -f "$target_path" ]] || fail "$label: $target_path"
}

function assert_symlink() {
  emulate -L zsh
  local target_path="${1:-}"
  local label="${2:-symlink exists}"

  [[ -L "$target_path" ]] || fail "$label: $target_path"
}

function assert_not_exists() {
  emulate -L zsh
  local target_path="${1:-}"
  local label="${2:-path should not exist}"

  [[ ! -e "$target_path" ]] || fail "$label: $target_path"
}

zsh "$PROJECT_ROOT/scripts/install.zsh" --prefix "$PREFIX" >/dev/null || exit 1

assert_file "$PREFIX/lib/reina-de-copas/bin/reina" "binario instalado" || exit 1
assert_file "$PREFIX/lib/reina-de-copas/lib/core/bootstrap.zsh" "core instalado" || exit 1
assert_file "$PREFIX/lib/reina-de-copas/presets/manifest.tsv" "manifest instalado" || exit 1
assert_file "$PREFIX/lib/reina-de-copas/VERSION" "version instalada" || exit 1
assert_symlink "$PREFIX/bin/reina" "symlink instalado" || exit 1

version_output="$("$PREFIX/bin/reina" version)"
assert_contains "$version_output" "$VERSION" "version instalada reporta VERSION" || exit 1

version_json_output="$("$PREFIX/bin/reina" --json --version)"
assert_contains "$version_json_output" "\"version\":\"$VERSION\"" "--version soporta JSON" || exit 1

list_output="$(
  REINA_CONFIG_ROOT="${TMP_DIR}/config-root" \
  REINA_CACHE_ROOT="${TMP_DIR}/cache-root" \
  REINA_STATE_ROOT="${TMP_DIR}/state-root" \
  "$PREFIX/bin/reina" list
)"
assert_contains "$list_output" "bass-in-the-desert" "instalacion lista presets" || exit 1

run_output="$(
  REINA_CONFIG_ROOT="${TMP_DIR}/config-root" \
  REINA_CACHE_ROOT="${TMP_DIR}/cache-root" \
  REINA_STATE_ROOT="${TMP_DIR}/state-root" \
  "$PREFIX/bin/reina" run bass-in-the-desert --dry-run 2>/dev/null
)"
assert_contains "$run_output" "result_status: ok" "instalacion ejecuta preset fundacional" || exit 1

stderr_file="$(mktemp)"
REINA_CONFIG_ROOT="${TMP_DIR}/config-root" \
REINA_CACHE_ROOT="${TMP_DIR}/cache-root" \
REINA_STATE_ROOT="${TMP_DIR}/state-root" \
"$PREFIX/bin/reina" run parallel-processing-drums >/dev/null 2>"$stderr_file"
run_exit_code=$?
run_stderr="$(<"$stderr_file")"
rm -f "$stderr_file"

if [[ "$run_exit_code" -ne 3 ]]; then
  print -u2 -- "FAIL: instalacion declara preset no implementado con exit code 3 y llego $run_exit_code"
  exit 1
fi

assert_contains "$run_stderr" "ERR_PRESET_NOT_IMPLEMENTED" "instalacion ejecuta dispatcher honesto" || exit 1

zsh "$PROJECT_ROOT/scripts/uninstall.zsh" --prefix "$PREFIX" >/dev/null || exit 1
assert_not_exists "$PREFIX/bin/reina" "uninstall remueve symlink" || exit 1
assert_not_exists "$PREFIX/lib/reina-de-copas" "uninstall remueve arbol instalado" || exit 1

print -- "distribution install tests passed"
