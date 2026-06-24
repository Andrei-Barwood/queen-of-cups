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

typeset -a core_slugs=(
  kick
  kick-2
  snare
  urban-snare
  urban-snare-tighter
)

for slug in "${core_slugs[@]}"; do
  run_output="$("$REINA_BIN" run "$slug" 2>/dev/null)"
  assert_contains "$run_output" "result_status: ok" "run $slug termina ok" || exit 1
  assert_contains "$run_output" "history_recorded: true" "run $slug registra historial" || exit 1
  assert_contains "$run_output" "runner_kind: family" "run $slug usa runner de familia" || exit 1
  assert_contains "$run_output" "implementation: drum-pieces-core-family" "run $slug expone implementation" || exit 1
done

kick_output="$("$REINA_BIN" run kick 2>/dev/null)"
assert_contains "$kick_output" "drum-pieces-core kick anchor purificado" "kick aplica semantica anchor" || exit 1

kick2_output="$("$REINA_BIN" run kick-2 2>/dev/null)"
assert_contains "$kick2_output" "drum-pieces-core kick anchor-tight purificado" "kick-2 aplica semantica anchor-tight" || exit 1

snare_json="$("$REINA_BIN" --json run snare 2>/dev/null)"
assert_contains "$snare_json" "\"ok\":true" "snare --json reporta ok" || exit 1
assert_contains "$snare_json" "\"variant\":\"accent\"" "snare --json expone variant accent" || exit 1

urban_output="$("$REINA_BIN" run urban-snare 2>/dev/null)"
assert_contains "$urban_output" "drum-pieces-core snare accent-dry purificado" "urban-snare aplica accent-dry" || exit 1

tighter_output="$("$REINA_BIN" run urban-snare-tighter 2>/dev/null)"
assert_contains "$tighter_output" "drum-pieces-core snare accent-tight purificado" "urban-snare-tighter aplica accent-tight" || exit 1

kick_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/kick/profile.txt"
kick2_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/kick-2/profile.txt"
snare_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/snare/profile.txt"
urban_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/urban-snare/profile.txt"

assert_file "$kick_profile_path" "kick crea profile.txt" || exit 1
assert_file "$kick2_profile_path" "kick-2 crea profile.txt" || exit 1
assert_file "$snare_profile_path" "snare crea profile.txt" || exit 1
assert_file "$urban_profile_path" "urban-snare crea profile.txt" || exit 1

kick_profile="$(<"$kick_profile_path")"
kick2_profile="$(<"$kick2_profile_path")"
snare_profile="$(<"$snare_profile_path")"
urban_profile="$(<"$urban_profile_path")"

assert_contains "$kick_profile" "variant_policy=semantic-only" "kick declara politica semantica" || exit 1
assert_contains "$kick_profile" "pulse_role=anchor" "kick perfil ancla" || exit 1
assert_contains "$kick2_profile" "allowed_numeric_suffix=kick-2" "kick-2 unico sufijo numerico permitido" || exit 1
assert_contains "$kick2_profile" "pulse_role=anchor-tight" "kick-2 perfil anchor-tight" || exit 1
assert_contains "$snare_profile" "pulse_role=accent" "snare perfil accent" || exit 1
assert_contains "$urban_profile" "pulse_role=accent-dry" "urban-snare perfil accent-dry" || exit 1

assert_not_contains "$kick_profile" "pulse_role=anchor-tight" "kick no mezcla anchor-tight" || exit 1
assert_not_contains "$snare_profile" "pulse_role=accent-dry" "snare no mezcla accent-dry" || exit 1

kick_snapshot_dir="${REINA_STATE_ROOT}/reina-de-copas/snapshots/kick"
snare_snapshot_dir="${REINA_STATE_ROOT}/reina-de-copas/snapshots/snare"
typeset -a kick_snapshots snare_snapshots
kick_snapshots=("${kick_snapshot_dir}"/*.txt(N))
snare_snapshots=("${snare_snapshot_dir}"/*.txt(N))

if (( ${#kick_snapshots[@]} == 0 || ${#snare_snapshots[@]} == 0 )); then
  print -u2 -- "FAIL: se esperaban snapshots para kick y snare"
  exit 1
fi

kick_snapshot="$(<"${kick_snapshots[1]}")"
snare_snapshot="$(<"${snare_snapshots[1]}")"
assert_contains "$kick_snapshot" "transform=kick-anchor" "snapshot kick guarda transform anchor" || exit 1
assert_contains "$snare_snapshot" "transform=snare-accent" "snapshot snare guarda transform accent" || exit 1
assert_contains "$kick_snapshot" "semantic_policy=anchor" "snapshot kick declara politica semantica" || exit 1

info_output="$("$REINA_BIN" info kick)"
assert_contains "$info_output" "status:       active" "info kick reporta active" || exit 1
assert_contains "$info_output" "family:       drum-pieces-core" "info kick reporta familia" || exit 1
assert_contains "$info_output" "variant:      anchor" "info kick reporta variant anchor" || exit 1

print -- "presets drum-pieces-core tests passed"