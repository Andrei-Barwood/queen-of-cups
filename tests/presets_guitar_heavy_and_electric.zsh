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

function assert_not_contains() {
  emulate -L zsh
  local haystack="${1:-}"
  local needle="${2:-}"
  local label="${3:-assertion}"

  if [[ "$haystack" == *"$needle"* ]]; then
    print -u2 -- "FAIL: ${label}"
    print -u2 -- "expected to not find: ${needle}"
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

typeset -a electric_slugs=(
  heavy-bright-guitar
  heavy-guitar-with-reverb
  wildin-camel-guitar
  el-gtr-driver
  gtr
)

for slug in "${electric_slugs[@]}"; do
  run_output="$("$REINA_BIN" run "$slug" 2>/dev/null)"
  assert_contains "$run_output" "result_status: ok" "run $slug termina ok" || exit 1
  assert_contains "$run_output" "history_recorded: true" "run $slug registra historial" || exit 1
  assert_contains "$run_output" "runner_kind: family" "run $slug usa runner de familia" || exit 1
  assert_contains "$run_output" "implementation: guitar-heavy-and-electric-family" "run $slug expone implementation" || exit 1
done

bright_output="$("$REINA_BIN" run heavy-bright-guitar 2>/dev/null)"
assert_contains "$bright_output" "guitar-heavy-and-electric bright purificado" "heavy-bright-guitar aplica semantica bright" || exit 1

reverb_json="$("$REINA_BIN" --json run heavy-guitar-with-reverb 2>/dev/null)"
assert_contains "$reverb_json" "\"ok\":true" "heavy-guitar-with-reverb --json reporta ok" || exit 1
assert_contains "$reverb_json" "\"variant\":\"reverb\"" "reverb --json expone variant" || exit 1

wild_output="$("$REINA_BIN" run wildin-camel-guitar 2>/dev/null)"
assert_contains "$wild_output" "guitar-heavy-and-electric wild-camel purificado" "wildin-camel-guitar aplica semantica wild" || exit 1

driver_output="$("$REINA_BIN" run el-gtr-driver 2>/dev/null)"
assert_contains "$driver_output" "guitar-heavy-and-electric driver purificado" "el-gtr-driver aplica semantica driver" || exit 1

base_output="$("$REINA_BIN" run gtr 2>/dev/null)"
assert_contains "$base_output" "guitar-heavy-and-electric base purificado" "gtr aplica semantica base" || exit 1

bright_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/heavy-bright-guitar/profile.txt"
reverb_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/heavy-guitar-with-reverb/profile.txt"
wild_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/wildin-camel-guitar/profile.txt"
driver_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/el-gtr-driver/profile.txt"
base_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/gtr/profile.txt"

assert_file "$bright_profile_path" "heavy-bright-guitar crea profile.txt" || exit 1
assert_file "$reverb_profile_path" "heavy-guitar-with-reverb crea profile.txt" || exit 1
assert_file "$wild_profile_path" "wildin-camel-guitar crea profile.txt" || exit 1
assert_file "$driver_profile_path" "el-gtr-driver crea profile.txt" || exit 1
assert_file "$base_profile_path" "gtr crea profile.txt" || exit 1

bright_profile="$(<"$bright_profile_path")"
reverb_profile="$(<"$reverb_profile_path")"
wild_profile="$(<"$wild_profile_path")"
driver_profile="$(<"$driver_profile_path")"
base_profile="$(<"$base_profile_path")"

assert_contains "$bright_profile" "electric_mode=heavy-bright" "bright perfil heavy-bright" || exit 1
assert_contains "$bright_profile" "front_presence=high" "bright perfil brillo frontal" || exit 1
assert_contains "$reverb_profile" "space_character=reverb-tail" "reverb perfil cola espacial" || exit 1
assert_contains "$wild_profile" "camel_wild_line=wildin-camel-guitar" "wild perfil linea camel" || exit 1
assert_contains "$driver_profile" "drive_presence=forward" "driver perfil empuje" || exit 1
assert_contains "$base_profile" "generalist_mode=active" "gtr perfil generalista" || exit 1

assert_not_contains "$driver_profile" "generalist_mode=active" "driver no usa perfil base" || exit 1
assert_not_contains "$base_profile" "drive_presence=forward" "gtr no usa perfil driver" || exit 1

wild_snapshot_dir="${REINA_STATE_ROOT}/reina-de-copas/snapshots/wildin-camel-guitar"
driver_snapshot_dir="${REINA_STATE_ROOT}/reina-de-copas/snapshots/el-gtr-driver"
typeset -a wild_snapshots driver_snapshots
wild_snapshots=("${wild_snapshot_dir}"/*.txt(N))
driver_snapshots=("${driver_snapshot_dir}"/*.txt(N))

if (( ${#wild_snapshots[@]} == 0 || ${#driver_snapshots[@]} == 0 )); then
  print -u2 -- "FAIL: se esperaban snapshots para wildin-camel-guitar y el-gtr-driver"
  exit 1
fi

wild_snapshot="$(<"${wild_snapshots[1]}")"
driver_snapshot="$(<"${driver_snapshots[1]}")"

assert_contains "$wild_snapshot" "transform=wildin-camel-guitar" "snapshot wild guarda transform propio" || exit 1
assert_contains "$wild_snapshot" "camel_wild=active" "snapshot wild declara camel" || exit 1
assert_contains "$driver_snapshot" "transform=el-gtr-driver" "snapshot driver guarda transform driver" || exit 1
assert_not_contains "$wild_snapshot" "transform=el-gtr-driver" "wild no contamina transform driver" || exit 1

info_gtr="$("$REINA_BIN" info gtr)"
assert_contains "$info_gtr" "status:       active" "info gtr reporta active" || exit 1
assert_contains "$info_gtr" "family:       guitar-heavy-and-electric" "info gtr reporta familia" || exit 1

info_driver="$("$REINA_BIN" info el-gtr-driver)"
assert_contains "$info_driver" "slug:         el-gtr-driver" "info el-gtr-driver slug distinto de gtr" || exit 1

print -- "presets guitar-heavy-and-electric tests passed"