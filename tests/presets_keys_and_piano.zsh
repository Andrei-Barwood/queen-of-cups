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

typeset -a keys_slugs=(
  keys-riding-a-camel
  jazz-piano
  rock-piano
  piano-beef
)

for slug in "${keys_slugs[@]}"; do
  run_output="$("$REINA_BIN" run "$slug" 2>/dev/null)"
  assert_contains "$run_output" "result_status: ok" "run $slug termina ok" || exit 1
  assert_contains "$run_output" "history_recorded: true" "run $slug registra historial" || exit 1
  assert_contains "$run_output" "runner_kind: family" "run $slug usa runner de familia" || exit 1
  assert_contains "$run_output" "implementation: keys-and-piano-family" "run $slug expone implementation" || exit 1
done

base_output="$("$REINA_BIN" run keys-riding-a-camel 2>/dev/null)"
assert_contains "$base_output" "keys-and-piano keys purificado" "keys-riding-a-camel aplica semantica base" || exit 1

jazz_output="$("$REINA_BIN" run jazz-piano 2>/dev/null)"
assert_contains "$jazz_output" "keys-and-piano jazz purificado" "jazz-piano aplica semantica jazz" || exit 1

rock_output="$("$REINA_BIN" run rock-piano 2>/dev/null)"
assert_contains "$rock_output" "keys-and-piano rock purificado" "rock-piano aplica semantica rock" || exit 1

beef_output="$("$REINA_BIN" run piano-beef 2>/dev/null)"
assert_contains "$beef_output" "keys-and-piano beef purificado" "piano-beef aplica semantica beef" || exit 1

base_json="$("$REINA_BIN" --json run keys-riding-a-camel 2>/dev/null)"
assert_contains "$base_json" "\"ok\":true" "keys-riding-a-camel --json reporta ok" || exit 1
assert_contains "$base_json" "\"variant\":\"base\"" "keys-riding-a-camel --json expone variant base" || exit 1

base_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/keys-riding-a-camel/profile.txt"
jazz_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/jazz-piano/profile.txt"
rock_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/rock-piano/profile.txt"
beef_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/piano-beef/profile.txt"

assert_file "$base_profile_path" "keys-riding-a-camel crea profile.txt" || exit 1
assert_file "$jazz_profile_path" "jazz-piano crea profile.txt" || exit 1
assert_file "$rock_profile_path" "rock-piano crea profile.txt" || exit 1
assert_file "$beef_profile_path" "piano-beef crea profile.txt" || exit 1

base_profile="$(<"$base_profile_path")"
jazz_profile="$(<"$jazz_profile_path")"
rock_profile="$(<"$rock_profile_path")"
beef_profile="$(<"$beef_profile_path")"

assert_contains "$base_profile" "camel_axis=active" "base perfil activa eje camel" || exit 1
assert_contains "$base_profile" "correction_policy=read-not-fix" "base perfil declara lectura no correccion" || exit 1
assert_contains "$jazz_profile" "harmonic_mode=jazz-flexible" "jazz perfil flexible" || exit 1
assert_contains "$rock_profile" "harmonic_mode=rock-drive" "rock perfil con empuje" || exit 1
assert_contains "$beef_profile" "piano_body=beef" "beef perfil reforzado" || exit 1

assert_not_contains "$jazz_profile" "camel_axis=active" "jazz no fuerza eje camel" || exit 1
assert_not_contains "$rock_profile" "piano_body=beef" "rock no usa perfil beef" || exit 1
assert_not_contains "$beef_profile" "harmonic_mode=jazz-flexible" "beef no usa perfil jazz" || exit 1

base_snapshot_dir="${REINA_STATE_ROOT}/reina-de-copas/snapshots/keys-riding-a-camel"
beef_snapshot_dir="${REINA_STATE_ROOT}/reina-de-copas/snapshots/piano-beef"
typeset -a base_snapshots beef_snapshots
base_snapshots=("${base_snapshot_dir}"/*.txt(N))
beef_snapshots=("${beef_snapshot_dir}"/*.txt(N))

if (( ${#base_snapshots[@]} == 0 || ${#beef_snapshots[@]} == 0 )); then
  print -u2 -- "FAIL: se esperaban snapshots para keys-riding-a-camel y piano-beef"
  exit 1
fi

base_snapshot="$(<"${base_snapshots[1]}")"
beef_snapshot="$(<"${beef_snapshots[1]}")"

assert_contains "$base_snapshot" "transform=keys-riding-a-camel" "snapshot base guarda transform propio" || exit 1
assert_contains "$beef_snapshot" "transform=piano-beef" "snapshot beef guarda transform propio" || exit 1
assert_not_contains "$base_snapshot" "transform=piano-beef" "base no contamina transform beef" || exit 1

info_base="$("$REINA_BIN" info keys-riding-a-camel)"
assert_contains "$info_base" "status:       active" "info keys-riding-a-camel reporta active" || exit 1
assert_contains "$info_base" "family:       keys-and-piano" "info keys-riding-a-camel reporta familia" || exit 1

info_jazz="$("$REINA_BIN" info jazz-piano)"
assert_contains "$info_jazz" "variant:      jazz" "info jazz-piano reporta variant" || exit 1

print -- "presets keys-and-piano tests passed"