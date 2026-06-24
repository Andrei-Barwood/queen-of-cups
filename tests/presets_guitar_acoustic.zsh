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

typeset -a acoustic_slugs=(
  acoustic-guitar-wet
  acoustic-gtr
  muted-cuatro
  muted-cuatro-wet
)

for slug in "${acoustic_slugs[@]}"; do
  run_output="$("$REINA_BIN" run "$slug" 2>/dev/null)"
  assert_contains "$run_output" "result_status: ok" "run $slug termina ok" || exit 1
  assert_contains "$run_output" "history_recorded: true" "run $slug registra historial" || exit 1
  assert_contains "$run_output" "runner_kind: family" "run $slug usa runner de familia" || exit 1
  assert_contains "$run_output" "implementation: guitar-acoustic-and-plucked-family" "run $slug expone implementation" || exit 1
done

wet_output="$("$REINA_BIN" run acoustic-guitar-wet 2>/dev/null)"
assert_contains "$wet_output" "guitar-acoustic-and-plucked wet purificado" "acoustic-guitar-wet aplica semantica wet" || exit 1

base_json="$("$REINA_BIN" --json run acoustic-gtr 2>/dev/null)"
assert_contains "$base_json" "\"ok\":true" "acoustic-gtr --json reporta ok" || exit 1
assert_contains "$base_json" "\"variant\":\"base\"" "acoustic-gtr --json expone variant base" || exit 1

alias_output="$("$REINA_BIN" run ac-gtr 2>/dev/null)"
assert_contains "$alias_output" "result_status: ok" "run ac-gtr termina ok" || exit 1
assert_contains "$alias_output" "slug:    acoustic-gtr" "ac-gtr resuelve slug canonico" || exit 1
assert_contains "$alias_output" "guitar-acoustic-and-plucked base purificado" "ac-gtr ejecuta semantica base" || exit 1

muted_output="$("$REINA_BIN" run muted-cuatro 2>/dev/null)"
assert_contains "$muted_output" "guitar-acoustic-and-plucked muted purificado" "muted-cuatro aplica semantica muted" || exit 1

muted_wet_output="$("$REINA_BIN" run muted-cuatro-wet 2>/dev/null)"
assert_contains "$muted_wet_output" "guitar-acoustic-and-plucked muted-wet purificado" "muted-cuatro-wet aplica semantica muted-wet" || exit 1

wet_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/acoustic-guitar-wet/profile.txt"
base_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/acoustic-gtr/profile.txt"
muted_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/muted-cuatro/profile.txt"
muted_wet_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/muted-cuatro-wet/profile.txt"

assert_file "$wet_profile_path" "acoustic-guitar-wet crea profile.txt" || exit 1
assert_file "$base_profile_path" "acoustic-gtr crea profile.txt" || exit 1
assert_file "$muted_profile_path" "muted-cuatro crea profile.txt" || exit 1
assert_file "$muted_wet_profile_path" "muted-cuatro-wet crea profile.txt" || exit 1

wet_profile="$(<"$wet_profile_path")"
base_profile="$(<"$base_profile_path")"
muted_profile="$(<"$muted_profile_path")"
muted_wet_profile="$(<"$muted_wet_profile_path")"

assert_contains "$wet_profile" "resonance_mode=acoustic-wet" "wet perfil acustico humedo" || exit 1
assert_contains "$base_profile" "canonical_alias=ac-gtr" "base perfil declara alias" || exit 1
assert_contains "$base_profile" "alias_policy=ac-gtr-explicit-short" "base perfil politica alias" || exit 1
assert_contains "$muted_profile" "plucked_mode=muted-percussive" "muted perfil percusivo" || exit 1
assert_contains "$muted_wet_profile" "derivation_parent=muted-cuatro" "muted-wet extiende muted" || exit 1
assert_contains "$muted_wet_profile" "derivation_chain=muted-cuatro>muted-cuatro-wet" "muted-wet cadena derivacion" || exit 1

assert_not_contains "$muted_profile" "derivation_parent=muted-cuatro" "muted no declara extension humeda" || exit 1
assert_not_contains "$base_profile" "plucked_mode=muted-percussive" "base no usa perfil muted" || exit 1

muted_snapshot_dir="${REINA_STATE_ROOT}/reina-de-copas/snapshots/muted-cuatro"
muted_wet_snapshot_dir="${REINA_STATE_ROOT}/reina-de-copas/snapshots/muted-cuatro-wet"
typeset -a muted_snapshots muted_wet_snapshots
muted_snapshots=("${muted_snapshot_dir}"/*.txt(N))
muted_wet_snapshots=("${muted_wet_snapshot_dir}"/*.txt(N))

if (( ${#muted_snapshots[@]} == 0 || ${#muted_wet_snapshots[@]} == 0 )); then
  print -u2 -- "FAIL: se esperaban snapshots para muted-cuatro y muted-cuatro-wet"
  exit 1
fi

muted_snapshot="$(<"${muted_snapshots[1]}")"
muted_wet_snapshot="$(<"${muted_wet_snapshots[1]}")"

assert_contains "$muted_snapshot" "transform=muted-cuatro" "snapshot muted guarda transform propio" || exit 1
assert_contains "$muted_wet_snapshot" "transform=muted-cuatro-wet" "snapshot muted-wet guarda transform wet" || exit 1
assert_contains "$muted_wet_snapshot" "derivation_parent=muted-cuatro" "snapshot muted-wet declara derivacion" || exit 1
assert_not_contains "$muted_snapshot" "transform=muted-cuatro-wet" "muted no contamina transform wet" || exit 1

info_alias="$("$REINA_BIN" info ac-gtr)"
assert_contains "$info_alias" "slug:         acoustic-gtr" "info ac-gtr resuelve slug canonico" || exit 1
assert_contains "$info_alias" "status:       active" "info ac-gtr reporta active" || exit 1
assert_contains "$info_alias" "family:       guitar-acoustic-and-plucked" "info ac-gtr reporta familia" || exit 1

info_muted_wet="$("$REINA_BIN" info muted-cuatro-wet)"
assert_contains "$info_muted_wet" "variant:      muted-wet" "info muted-cuatro-wet reporta variant" || exit 1

print -- "presets guitar-acoustic-and-plucked tests passed"