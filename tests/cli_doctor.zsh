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

function assert_file() {
  emulate -L zsh
  local path="${1:-}"
  local label="${2:-assertion}"

  if [[ ! -f "$path" ]]; then
    print -u2 -- "FAIL: $label"
    print -u2 -- "missing file: $path"
    return 1
  fi
}

doctor_output="$("$REINA_BIN" doctor 2>/dev/null)"
assert_contains "$doctor_output" "Doctor:" "doctor imprime encabezado" || exit 1
assert_contains "$doctor_output" "manifest:integrity" "doctor revisa manifiesto" || exit 1
assert_contains "$doctor_output" "storage:config" "doctor revisa permisos config" || exit 1
assert_contains "$doctor_output" "dependency:zsh" "doctor revisa zsh" || exit 1

doctor_json="$("$REINA_BIN" --json doctor 2>/dev/null)"
assert_contains "$doctor_json" "\"command\":\"doctor\"" "doctor --json expone command" || exit 1
assert_contains "$doctor_json" "\"checks\":" "doctor --json expone checks" || exit 1
assert_contains "$doctor_json" "\"manifest:integrity\"" "doctor --json incluye manifiesto" || exit 1

"$REINA_BIN" run bass-in-the-desert >/dev/null 2>&1 || exit 1

history_output="$("$REINA_BIN" history bass-in-the-desert 2>/dev/null)"
assert_contains "$history_output" "History:" "history imprime encabezado" || exit 1
assert_contains "$history_output" "preset=bass-in-the-desert" "history muestra entrada de preset" || exit 1
assert_contains "$history_output" "result=ok" "history muestra resultado" || exit 1

history_json="$("$REINA_BIN" --json history bass-in-the-desert 2>/dev/null)"
assert_contains "$history_json" "\"entries\":" "history --json expone entries" || exit 1
assert_contains "$history_json" "preset=bass-in-the-desert" "history --json incluye cuerpo" || exit 1

snapshot_list="$("$REINA_BIN" snapshot bass-in-the-desert list 2>/dev/null)"
assert_contains "$snapshot_list" "Snapshots:" "snapshot list imprime encabezado" || exit 1
assert_contains "$snapshot_list" "bass-in-the-desert-run" "snapshot list muestra snapshot de run" || exit 1

snapshot_list_json="$("$REINA_BIN" --json snapshot bass-in-the-desert list 2>/dev/null)"
assert_contains "$snapshot_list_json" "\"snapshots\":" "snapshot list --json expone snapshots" || exit 1

restore_output="$("$REINA_BIN" snapshot bass-in-the-desert restore 2>/dev/null)"
assert_contains "$restore_output" "Snapshot restore:" "snapshot restore imprime encabezado" || exit 1
assert_contains "$restore_output" "status:  ok" "snapshot restore termina ok" || exit 1

profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/bass-in-the-desert/profile.txt"
assert_file "$profile_path" "snapshot restore escribe profile.txt" || exit 1

profile_body="$(<"$profile_path")"
assert_contains "$profile_body" "transform=desert-purify" "restore copia receta del snapshot" || exit 1

old_cache_path="${REINA_CACHE_ROOT}/reina-de-copas/network/prune-old.txt"
old_cache_meta="${old_cache_path:r}.meta"
mkdir -p "${old_cache_path:h}"
print -- "old-body" > "$old_cache_path"
{
  print -- "key=prune-old"
  print -- "category=cache"
  print -- "scope=network"
  print -- "origin=remote"
  print -- "created_epoch=0"
  print -- "ttl_seconds=1"
} > "$old_cache_meta"

"$REINA_BIN" prune --cache >/dev/null 2>&1 || exit 1
if [[ -f "$old_cache_path" ]]; then
  print -u2 -- "FAIL: prune --cache debio remover cache vencido"
  exit 1
fi

fresh_cache_path="${REINA_CACHE_ROOT}/reina-de-copas/network/prune-fresh.txt"
fresh_cache_meta="${fresh_cache_path:r}.meta"
print -- "fresh-body" > "$fresh_cache_path"
{
  print -- "key=prune-fresh"
  print -- "category=cache"
  print -- "scope=network"
  print -- "origin=remote"
  print -- "created_epoch=$(date +%s)"
  print -- "ttl_seconds=9999"
} > "$fresh_cache_meta"
"$REINA_BIN" prune --cache >/dev/null 2>&1 || exit 1
assert_file "$fresh_cache_path" "prune --cache conserva cache vigente" || exit 1

prune_json="$("$REINA_BIN" --json prune --all 2>/dev/null)"
assert_contains "$prune_json" "\"mode\":\"all\"" "prune --all --json reporta modo all" || exit 1

print -- "cli doctor tests passed"