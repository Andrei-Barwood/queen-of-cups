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

typeset -a female_slugs=(
  female-vox-1
  female-vox-1-wet
  female-vocal-wet
)

for slug in "${female_slugs[@]}"; do
  run_output="$("$REINA_BIN" run "$slug" 2>/dev/null)"
  assert_contains "$run_output" "result_status: ok" "run $slug termina ok" || exit 1
  assert_contains "$run_output" "history_recorded: true" "run $slug registra historial" || exit 1
  assert_contains "$run_output" "runner_kind: family" "run $slug usa runner de familia" || exit 1
  assert_contains "$run_output" "implementation: female-vocal-family" "run $slug expone implementation" || exit 1
done

dry_output="$("$REINA_BIN" run female-vox-1 2>/dev/null)"
assert_contains "$dry_output" "female-vocal dry purificados" "female-vox-1 aplica semantica dry" || exit 1

wet_output="$("$REINA_BIN" run female-vox-1-wet 2>/dev/null)"
assert_contains "$wet_output" "female-vocal wet purificados" "female-vox-1-wet aplica semantica wet" || exit 1

wide_json="$("$REINA_BIN" --json run female-vocal-wet 2>/dev/null)"
assert_contains "$wide_json" "\"ok\":true" "female-vocal-wet --json reporta ok" || exit 1
assert_contains "$wide_json" "\"variant\":\"wet-wide\"" "female-vocal-wet --json expone variant" || exit 1

dry_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/female-vox-1/profile.txt"
wet_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/female-vox-1-wet/profile.txt"
wide_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/female-vocal-wet/profile.txt"

assert_file "$dry_profile_path" "female-vox-1 crea profile.txt" || exit 1
assert_file "$wet_profile_path" "female-vox-1-wet crea profile.txt" || exit 1
assert_file "$wide_profile_path" "female-vocal-wet crea profile.txt" || exit 1

dry_profile="$(<"$dry_profile_path")"
wet_profile="$(<"$wet_profile_path")"
wide_profile="$(<"$wide_profile_path")"

assert_contains "$dry_profile" "presence_mode=frontal" "dry conserva presencia frontal" || exit 1
assert_contains "$dry_profile" "reverb_send=none" "dry permanece seco" || exit 1
assert_contains "$dry_profile" "derivation_chain=female-vox-1" "dry declara raiz de cadena" || exit 1

assert_contains "$wet_profile" "derivation=extends-dry" "wet extiende dry sin copiar" || exit 1
assert_contains "$wet_profile" "derivation_parent=female-vox-1" "wet declara parent dry" || exit 1
assert_contains "$wet_profile" "presence_mode=frontal" "wet hereda core dry" || exit 1
assert_contains "$wet_profile" "wet_blend=focused" "wet agrega capa humeda enfocada" || exit 1
assert_contains "$wet_profile" "derivation_chain=female-vox-1>female-vox-1-wet" "wet declara cadena parcial" || exit 1

assert_contains "$wide_profile" "derivation=extends-wet" "wet-wide extiende wet" || exit 1
assert_contains "$wide_profile" "derivation_parent=female-vox-1-wet" "wet-wide declara parent wet" || exit 1
assert_contains "$wide_profile" "presence_mode=frontal" "wet-wide hereda raiz dry" || exit 1
assert_contains "$wide_profile" "wet_blend=diffuse" "wet-wide agrega mezcla difusa" || exit 1
assert_contains "$wide_profile" "stereo_width=expanded" "wet-wide expande estereo" || exit 1
assert_contains "$wide_profile" "derivation_chain=female-vox-1>female-vox-1-wet>female-vocal-wet" "wet-wide declara cadena completa" || exit 1

assert_not_contains "$dry_profile" "derivation=extends-dry" "dry no finge extension wet" || exit 1
assert_not_contains "$wet_profile" "stereo_width=expanded" "wet no salta a wide sin extension" || exit 1

wet_snapshot_dir="${REINA_STATE_ROOT}/reina-de-copas/snapshots/female-vox-1-wet"
wide_snapshot_dir="${REINA_STATE_ROOT}/reina-de-copas/snapshots/female-vocal-wet"
typeset -a wet_snapshots wide_snapshots
wet_snapshots=("${wet_snapshot_dir}"/*.txt(N))
wide_snapshots=("${wide_snapshot_dir}"/*.txt(N))

if (( ${#wet_snapshots[@]} == 0 || ${#wide_snapshots[@]} == 0 )); then
  print -u2 -- "FAIL: se esperaban snapshots para wet y wet-wide"
  exit 1
fi

wet_snapshot="$(<"${wet_snapshots[1]}")"
wide_snapshot="$(<"${wide_snapshots[1]}")"

assert_contains "$wet_snapshot" "extend=add-focused-wet" "snapshot wet registra extension" || exit 1
assert_contains "$wet_snapshot" "transform=female-vox-dry" "snapshot wet hereda transform dry" || exit 1
assert_contains "$wide_snapshot" "extend=add-wide-wet" "snapshot wide registra extension amplia" || exit 1
assert_contains "$wide_snapshot" "derivation_chain=female-vox-1>female-vox-1-wet>female-vocal-wet" "snapshot wide declara cadena" || exit 1

info_output="$("$REINA_BIN" info female-vox-1)"
assert_contains "$info_output" "status:       active" "info female-vox-1 reporta active" || exit 1
assert_contains "$info_output" "family:       female-vocal" "info female-vox-1 reporta familia" || exit 1

print -- "presets female-vocal tests passed"