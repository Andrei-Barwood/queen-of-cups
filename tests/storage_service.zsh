#!/usr/bin/env zsh

setopt NO_UNSET PIPE_FAIL

typeset -r PROJECT_ROOT="${0:A:h:h}"
typeset -r TMP_DIR="$(mktemp -d)"

function cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

typeset -gx REINA_PROJECT_ROOT="$PROJECT_ROOT"
typeset -gx REINA_CONFIG_ROOT="${TMP_DIR}/config-root"
typeset -gx REINA_CACHE_ROOT="${TMP_DIR}/cache-root"
typeset -gx REINA_STATE_ROOT="${TMP_DIR}/state-root"
typeset -gx REINA_DEBUG=0
typeset -gx REINA_QUIET=1
typeset -gx REINA_OFFLINE=0

source "$PROJECT_ROOT/lib/core/logging.zsh"
source "$PROJECT_ROOT/lib/core/json.zsh"
source "$PROJECT_ROOT/lib/services/errors.zsh"
source "$PROJECT_ROOT/lib/services/storage.zsh"

function fail() {
  emulate -L zsh
  print -u2 -- "FAIL: $*"
  return 1
}

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

function assert_dir() {
  emulate -L zsh
  local target_path="${1:-}"
  local label="${2:-directory exists}"

  [[ -d "$target_path" ]] || fail "$label: $target_path"
}

function assert_file() {
  emulate -L zsh
  local target_path="${1:-}"
  local label="${2:-file exists}"

  [[ -f "$target_path" ]] || fail "$label: $target_path"
}

function assert_not_exists() {
  emulate -L zsh
  local target_path="${1:-}"
  local label="${2:-path should not exist}"

  [[ ! -e "$target_path" ]] || fail "$label: $target_path"
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

reina_storage_init || exit 1

assert_dir "$(reina_storage_config_dir)" "config root creado" || exit 1
assert_dir "$(reina_storage_global_config_dir)" "config global creado" || exit 1
assert_dir "$(reina_storage_preset_config_dir)" "config por preset creado" || exit 1
assert_dir "$(reina_storage_cache_dir)" "cache root creado" || exit 1
assert_dir "$(reina_storage_network_cache_dir)" "cache de red creado" || exit 1
assert_dir "$(reina_storage_preset_cache_dir)" "cache de presets creado" || exit 1
assert_dir "$(reina_storage_state_dir)" "state root creado" || exit 1
assert_dir "$(reina_storage_history_dir)" "history creado" || exit 1
assert_dir "$(reina_storage_snapshots_dir)" "snapshots creado" || exit 1
assert_dir "$(reina_storage_runtime_dir)" "runtime creado" || exit 1
assert_dir "$(reina_storage_tmp_dir)" "tmp creado" || exit 1
assert_dir "$(reina_storage_locks_dir)" "locks creado" || exit 1

context_json="$(reina_storage_context_json)"
assert_contains "$context_json" "\"network_cache\"" "contexto expone cache de red" || exit 1
assert_contains "$context_json" "\"locks\"" "contexto expone locks" || exit 1

reina_storage_put config profile global-profile global 0 local || exit 1
reina_storage_get config profile global >/dev/null || exit 1
assert_eq "global-profile" "$REINA_STORE_LAST_VALUE" "store_get lee config global" || exit 1

reina_storage_put config profile preset-profile bass-in-the-desert 0 local || exit 1
reina_storage_config_get profile bass-in-the-desert fallback >/dev/null || exit 1
assert_eq "preset-profile" "$REINA_STORE_LAST_VALUE" "config por preset tiene precedencia" || exit 1

reina_storage_config_get profile unknown-preset fallback >/dev/null || exit 1
assert_eq "global-profile" "$REINA_STORE_LAST_VALUE" "config global actua como fallback" || exit 1

reina_storage_config_get missing bass-in-the-desert fallback >/dev/null || exit 1
assert_eq "fallback" "$REINA_STORE_LAST_VALUE" "config ausente usa default" || exit 1

if reina_storage_exists cache profile network; then
  fail "cache miss inesperado antes de escribir" || exit 1
fi

reina_storage_put cache profile "cached body" network 60 remote || exit 1
reina_storage_exists cache profile network || fail "cache hit esperado" || exit 1
reina_storage_get cache profile network >/dev/null || exit 1
assert_eq "cached body" "$REINA_STORE_LAST_VALUE" "cache devuelve body esperado" || exit 1

stderr_file="${TMP_DIR}/missing.err"
reina_storage_get cache missing network >/dev/null 2>"$stderr_file"
exit_code=$?
assert_nonzero "$exit_code" "store_get missing falla" || exit 1
assert_eq "ERR_STORE_NOT_FOUND" "$REINA_STORE_LAST_ERROR" "missing tipificado" || exit 1

reina_storage_snapshot bass-in-the-desert "snapshot body" run remote || exit 1
snapshot_path="$REINA_STORE_LAST_PATH"
assert_file "$snapshot_path" "snapshot creado" || exit 1
snapshot_body="$(<"$snapshot_path")"
assert_contains "$snapshot_body" "snapshot body" "snapshot guarda contenido" || exit 1

reina_storage_record_history bass-in-the-desert ok 0 "offline=false dry_run=false" online false || exit 1
history_path="$REINA_STORE_LAST_PATH"
assert_file "$history_path" "historial creado" || exit 1
history_body="$(<"$history_path")"
assert_contains "$history_body" "preset=bass-in-the-desert" "historial guarda preset" || exit 1
assert_contains "$history_body" "network=online" "historial guarda modo de red" || exit 1

reina_storage_lock day4 300 || exit 1
lock_path="$REINA_STORE_LAST_PATH"
assert_dir "$lock_path" "lock creado" || exit 1

stderr_file="${TMP_DIR}/locked.err"
reina_storage_lock day4 300 >/dev/null 2>"$stderr_file"
exit_code=$?
assert_nonzero "$exit_code" "segundo lock falla" || exit 1
assert_eq "ERR_STORE_LOCKED" "$REINA_STORE_LAST_ERROR" "lock tipificado" || exit 1

reina_storage_unlock day4 || exit 1
assert_not_exists "$lock_path" "unlock remueve lock" || exit 1

corrupt_path="$(reina_storage_body_path cache corrupt network)"
mkdir -p "$corrupt_path" || exit 1
stderr_file="${TMP_DIR}/corrupt.err"
reina_storage_get cache corrupt network >/dev/null 2>"$stderr_file"
exit_code=$?
assert_nonzero "$exit_code" "entrada corrupta falla" || exit 1
assert_eq "ERR_STORE_CORRUPT" "$REINA_STORE_LAST_ERROR" "corrupt tipificado" || exit 1
rm -rf "$corrupt_path"

reina_storage_put cache old old-body network 1 remote || exit 1
old_body="$REINA_STORE_LAST_PATH"
old_meta="$REINA_STORE_LAST_META_PATH"
{
  print -- "key=old"
  print -- "category=cache"
  print -- "scope=network"
  print -- "origin=remote"
  print -- "created_epoch=0"
  print -- "ttl_seconds=1"
} > "$old_meta"

reina_storage_prune cache network 1 || exit 1
assert_not_exists "$old_body" "prune remueve cache vencido" || exit 1

reina_storage_put cache fresh fresh-body network 9999 remote || exit 1
fresh_body="$REINA_STORE_LAST_PATH"
reina_storage_prune cache network 9999 || exit 1
assert_file "$fresh_body" "prune conserva cache vigente" || exit 1

list_output="$(reina_storage_list cache network)"
assert_contains "$list_output" "fresh.txt" "store_list lista entradas vigentes" || exit 1

reina_storage_delete cache fresh network || exit 1
assert_not_exists "$fresh_body" "store_delete borra body" || exit 1

print -- "storage service tests passed"
