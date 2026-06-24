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

typeset -a low_end_slugs=(
  upright-bass
  synth-bass
  808-boom-control
)

for slug in "${low_end_slugs[@]}"; do
  run_output="$("$REINA_BIN" run "$slug" 2>/dev/null)"
  assert_contains "$run_output" "result_status: ok" "run $slug termina ok" || exit 1
  assert_contains "$run_output" "history_recorded: true" "run $slug registra historial" || exit 1
  assert_contains "$run_output" "runner_kind: family" "run $slug usa runner de familia" || exit 1
  assert_contains "$run_output" "implementation: low-end-family" "run $slug expone implementation de familia" || exit 1
done

upright_output="$("$REINA_BIN" run upright-bass 2>/dev/null)"
assert_contains "$upright_output" "low-end upright purificado" "upright-bass aplica semantica organic" || exit 1

synth_output="$("$REINA_BIN" run synth-bass 2>/dev/null)"
assert_contains "$synth_output" "low-end synth purificado" "synth-bass aplica semantica synthetic" || exit 1

boom_output="$("$REINA_BIN" run 808-boom-control 2>/dev/null)"
assert_contains "$boom_output" "low-end 808 purificado" "808-boom-control aplica semantica impact" || exit 1

dry_run_output="$("$REINA_BIN" run 808-boom-control --dry-run 2>/dev/null)"
assert_contains "$dry_run_output" "history_recorded: false" "dry-run no registra historial" || exit 1
assert_contains "$dry_run_output" "result_status: ok" "dry-run ejecuta preset real sin persistir" || exit 1

upright_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/upright-bass/profile.txt"
synth_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/synth-bass/profile.txt"
boom_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/808-boom-control/profile.txt"

assert_file "$upright_profile_path" "upright-bass crea profile.txt" || exit 1
assert_file "$synth_profile_path" "synth-bass crea profile.txt" || exit 1
assert_file "$boom_profile_path" "808-boom-control crea profile.txt" || exit 1

upright_profile="$(<"$upright_profile_path")"
synth_profile="$(<"$synth_profile_path")"
boom_profile="$(<"$boom_profile_path")"

assert_contains "$upright_profile" "bass_inherit=enabled" "upright-bass hereda core bass" || exit 1
assert_contains "$upright_profile" "source_character=woody" "upright-bass perfil organico" || exit 1
assert_contains "$synth_profile" "bass_inherit=disabled" "synth-bass no hereda core bass" || exit 1
assert_contains "$synth_profile" "non_interference=upright-bass" "synth-bass declara no-interferencia" || exit 1
assert_contains "$boom_profile" "808_governor=true" "808-boom-control activa gobernador de sub" || exit 1
assert_contains "$boom_profile" "boom_control=active" "808-boom-control politica de impacto" || exit 1

assert_not_contains "$synth_profile" "source_character=woody" "synth-bass no mezcla perfil organico" || exit 1
assert_not_contains "$upright_profile" "source_character=synthetic" "upright-bass no mezcla perfil sintetico" || exit 1

upright_snapshot_dir="${REINA_STATE_ROOT}/reina-de-copas/snapshots/upright-bass"
synth_snapshot_dir="${REINA_STATE_ROOT}/reina-de-copas/snapshots/synth-bass"
typeset -a upright_snapshots synth_snapshots
upright_snapshots=("${upright_snapshot_dir}"/*.txt(N))
synth_snapshots=("${synth_snapshot_dir}"/*.txt(N))

if (( ${#upright_snapshots[@]} == 0 || ${#synth_snapshots[@]} == 0 )); then
  print -u2 -- "FAIL: se esperaban snapshots para upright-bass y synth-bass"
  exit 1
fi

upright_snapshot="$(<"${upright_snapshots[1]}")"
synth_snapshot="$(<"${synth_snapshots[1]}")"

assert_contains "$upright_snapshot" "transform=upright-organic" "snapshot upright guarda transformacion organica" || exit 1
assert_contains "$synth_snapshot" "transform=synth-sub" "snapshot synth guarda transformacion sintetica" || exit 1
assert_contains "$upright_snapshot" "isolation=synth-bass" "upright declara aislamiento de synth" || exit 1
assert_contains "$synth_snapshot" "isolation=upright-bass" "synth declara aislamiento de upright" || exit 1
assert_not_contains "$upright_snapshot" "transform=synth-sub" "upright no contamina transform synth" || exit 1
assert_not_contains "$synth_snapshot" "transform=upright-organic" "synth no contamina transform upright" || exit 1

boom_json="$("$REINA_BIN" --json run 808-boom-control 2>/dev/null)"
assert_contains "$boom_json" "\"ok\":true" "808-boom-control --json reporta ok" || exit 1
assert_contains "$boom_json" "\"variant\":\"impact\"" "808-boom-control --json expone variant" || exit 1
assert_contains "$boom_json" "\"implementation\":\"low-end-family\"" "808-boom-control --json expone implementation" || exit 1

info_output="$("$REINA_BIN" info upright-bass)"
assert_contains "$info_output" "status:       active" "info upright-bass reporta active" || exit 1
assert_contains "$info_output" "family:       low-end" "info upright-bass reporta familia low-end" || exit 1

print -- "presets low-end tests passed"