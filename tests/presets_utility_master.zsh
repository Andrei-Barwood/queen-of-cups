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

typeset -a utility_slugs=(
  camels-need-water
  lofi-looper
  master-smiley-face
)

for slug in "${utility_slugs[@]}"; do
  run_output="$("$REINA_BIN" run "$slug" 2>/dev/null)"
  assert_contains "$run_output" "result_status: ok" "run $slug termina ok" || exit 1
  assert_contains "$run_output" "history_recorded: true" "run $slug registra historial" || exit 1
  assert_contains "$run_output" "runner_kind: family" "run $slug usa runner de familia" || exit 1
done

refresh_output="$("$REINA_BIN" run camels-need-water 2>/dev/null)"
assert_contains "$refresh_output" "implementation: camels-need-water-refresh" "camels-need-water expone implementation refresh" || exit 1
assert_contains "$refresh_output" "Camels Need Water Recovery" "camels-need-water emite recovery report" || exit 1
assert_contains "$refresh_output" "hydration_axis: active" "camels-need-water reporta hidratacion" || exit 1

lofi_output="$("$REINA_BIN" run lofi-looper 2>/dev/null)"
assert_contains "$lofi_output" "utility-texture-and-master lofi purificado" "lofi-looper aplica semantica lofi" || exit 1
assert_contains "$lofi_output" "implementation: utility-texture-and-master-family" "lofi-looper usa family runner" || exit 1

master_output="$("$REINA_BIN" run master-smiley-face 2>/dev/null)"
assert_contains "$master_output" "utility-texture-and-master master purificado" "master-smiley-face aplica semantica master" || exit 1

master_json="$("$REINA_BIN" --json run master-smiley-face 2>/dev/null)"
assert_contains "$master_json" "\"ok\":true" "master-smiley-face --json reporta ok" || exit 1
assert_contains "$master_json" "\"variant\":\"master\"" "master-smiley-face --json expone variant master" || exit 1

refresh_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/camels-need-water/profile.txt"
lofi_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/lofi-looper/profile.txt"
master_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/master-smiley-face/profile.txt"

assert_file "$refresh_profile_path" "camels-need-water crea profile.txt" || exit 1
assert_file "$lofi_profile_path" "lofi-looper crea profile.txt" || exit 1
assert_file "$master_profile_path" "master-smiley-face crea profile.txt" || exit 1

refresh_profile="$(<"$refresh_profile_path")"
lofi_profile="$(<"$lofi_profile_path")"
master_profile="$(<"$master_profile_path")"

assert_contains "$refresh_profile" "utility_mode=recovery-refresh" "refresh perfil de recuperacion" || exit 1
assert_contains "$refresh_profile" "hydration_axis=active" "refresh perfil hidrata la red" || exit 1
assert_contains "$lofi_profile" "texture_character=repetitive-loop" "lofi perfil repetitivo" || exit 1
assert_contains "$lofi_profile" "degradation_policy=gentle" "lofi perfil degradacion amable" || exit 1
assert_contains "$master_profile" "master_character=final-balance" "master perfil balance final" || exit 1
assert_contains "$master_profile" "sweetening=gentle-smile" "master perfil sweetening amable" || exit 1

assert_not_contains "$lofi_profile" "hydration_axis=active" "lofi no usa perfil refresh" || exit 1
assert_not_contains "$master_profile" "memory_span=short" "master no usa perfil lofi" || exit 1

refresh_snapshot_dir="${REINA_STATE_ROOT}/reina-de-copas/snapshots/camels-need-water"
master_snapshot_dir="${REINA_STATE_ROOT}/reina-de-copas/snapshots/master-smiley-face"
typeset -a refresh_snapshots master_snapshots
refresh_snapshots=("${refresh_snapshot_dir}"/*.txt(N))
master_snapshots=("${master_snapshot_dir}"/*.txt(N))

if (( ${#refresh_snapshots[@]} == 0 || ${#master_snapshots[@]} == 0 )); then
  print -u2 -- "FAIL: se esperaban snapshots para camels-need-water y master-smiley-face"
  exit 1
fi

refresh_snapshot="$(<"${refresh_snapshots[1]}")"
master_snapshot="$(<"${master_snapshots[1]}")"

assert_contains "$refresh_snapshot" "transform=camels-need-water-refresh" "snapshot refresh guarda transform propio" || exit 1
assert_contains "$refresh_snapshot" "recovery_report<<EOF" "snapshot refresh guarda recovery report" || exit 1
assert_contains "$master_snapshot" "transform=master-smiley-face" "snapshot master guarda transform propio" || exit 1
assert_not_contains "$master_snapshot" "transform=camels-need-water-refresh" "master no contamina transform refresh" || exit 1

info_refresh="$("$REINA_BIN" info camels-need-water)"
assert_contains "$info_refresh" "status:       active" "info camels-need-water reporta active" || exit 1
assert_contains "$info_refresh" "family:       utility-texture-and-master" "info camels-need-water reporta familia" || exit 1

info_master="$("$REINA_BIN" info master-smiley-face)"
assert_contains "$info_master" "variant:      master" "info master-smiley-face reporta variant" || exit 1

print -- "presets utility-texture-and-master tests passed"