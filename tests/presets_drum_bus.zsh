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

typeset -a drum_bus_slugs=(
  drum-bus-drivin
  drum-bus-island
  drum-bus-wild-spring-camel
  drum-bus-magic
)

for slug in "${drum_bus_slugs[@]}"; do
  run_output="$("$REINA_BIN" run "$slug" 2>/dev/null)"
  assert_contains "$run_output" "result_status: ok" "run $slug termina ok" || exit 1
  assert_contains "$run_output" "history_recorded: true" "run $slug registra historial" || exit 1
  assert_contains "$run_output" "runner_kind: family" "run $slug usa runner de familia" || exit 1
  assert_contains "$run_output" "implementation: drum-bus-family" "run $slug expone implementation" || exit 1
done

drivin_output="$("$REINA_BIN" run drum-bus-drivin 2>/dev/null)"
assert_contains "$drivin_output" "drum-bus drivin purificado" "drum-bus-drivin aplica semantica drive" || exit 1

island_output="$("$REINA_BIN" run drum-bus-island 2>/dev/null)"
assert_contains "$island_output" "drum-bus island purificado" "drum-bus-island aplica semantica spaced" || exit 1

wild_json="$("$REINA_BIN" --json run drum-bus-wild-spring-camel 2>/dev/null)"
assert_contains "$wild_json" "\"ok\":true" "drum-bus-wild-spring-camel --json reporta ok" || exit 1
assert_contains "$wild_json" "\"variant\":\"wild\"" "wild-spring-camel --json expone variant" || exit 1

magic_output="$("$REINA_BIN" run drum-bus-magic 2>/dev/null)"
assert_contains "$magic_output" "drum-bus magic purificado" "drum-bus-magic aplica semantica glue" || exit 1

drivin_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/drum-bus-drivin/profile.txt"
island_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/drum-bus-island/profile.txt"
wild_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/drum-bus-wild-spring-camel/profile.txt"
magic_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/drum-bus-magic/profile.txt"

assert_file "$drivin_profile_path" "drum-bus-drivin crea profile.txt" || exit 1
assert_file "$island_profile_path" "drum-bus-island crea profile.txt" || exit 1
assert_file "$wild_profile_path" "drum-bus-wild-spring-camel crea profile.txt" || exit 1
assert_file "$magic_profile_path" "drum-bus-magic crea profile.txt" || exit 1

drivin_profile="$(<"$drivin_profile_path")"
island_profile="$(<"$island_profile_path")"
wild_profile="$(<"$wild_profile_path")"
magic_profile="$(<"$magic_profile_path")"

assert_contains "$drivin_profile" "compression_character=forward" "drivin perfil de empuje" || exit 1
assert_contains "$drivin_profile" "drive_energy=high" "drivin energia de conjunto" || exit 1
assert_contains "$island_profile" "island_mode=active" "island modo abierto" || exit 1
assert_contains "$island_profile" "space_cohesion=open" "island espacio abierto" || exit 1
assert_contains "$wild_profile" "camel_spring=active" "wild activa spring-camel" || exit 1
assert_contains "$wild_profile" "elastic_groove=active" "wild groove elastico" || exit 1
assert_contains "$magic_profile" "magic_cohesion=active" "magic cohesion activa" || exit 1
assert_contains "$magic_profile" "compression_character=glue" "magic compresion glue" || exit 1

assert_not_contains "$island_profile" "compression_character=glue" "island no mezcla semantica magic" || exit 1
assert_not_contains "$magic_profile" "island_mode=active" "magic no mezcla semantica island" || exit 1

wild_snapshot_dir="${REINA_STATE_ROOT}/reina-de-copas/snapshots/drum-bus-wild-spring-camel"
magic_snapshot_dir="${REINA_STATE_ROOT}/reina-de-copas/snapshots/drum-bus-magic"
typeset -a wild_snapshots magic_snapshots
wild_snapshots=("${wild_snapshot_dir}"/*.txt(N))
magic_snapshots=("${magic_snapshot_dir}"/*.txt(N))

if (( ${#wild_snapshots[@]} == 0 || ${#magic_snapshots[@]} == 0 )); then
  print -u2 -- "FAIL: se esperaban snapshots para wild y magic"
  exit 1
fi

wild_snapshot="$(<"${wild_snapshots[1]}")"
magic_snapshot="$(<"${magic_snapshots[1]}")"

assert_contains "$wild_snapshot" "transform=drum-bus-wild-spring" "snapshot wild guarda transform spring" || exit 1
assert_contains "$wild_snapshot" "camel_spring=active" "snapshot wild declara camel_spring" || exit 1
assert_contains "$magic_snapshot" "transform=drum-bus-magic-glue" "snapshot magic guarda transform glue" || exit 1
assert_not_contains "$wild_snapshot" "transform=drum-bus-magic-glue" "wild no contamina transform magic" || exit 1

info_output="$("$REINA_BIN" info drum-bus-drivin)"
assert_contains "$info_output" "status:       active" "info drum-bus-drivin reporta active" || exit 1
assert_contains "$info_output" "family:       drum-bus" "info drum-bus-drivin reporta familia" || exit 1

print -- "presets drum-bus tests passed"