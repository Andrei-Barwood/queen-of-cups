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

typeset -a utility_slugs=(
  pop-lead-vocal
  vocal-help
  give-backgrounds-some-life
)

for slug in "${utility_slugs[@]}"; do
  run_output="$("$REINA_BIN" run "$slug" 2>/dev/null)"
  assert_contains "$run_output" "result_status: ok" "run $slug termina ok" || exit 1
  assert_contains "$run_output" "history_recorded: true" "run $slug registra historial" || exit 1
  assert_contains "$run_output" "runner_kind: family" "run $slug usa runner de familia" || exit 1
done

lead_output="$("$REINA_BIN" run pop-lead-vocal 2>/dev/null)"
assert_contains "$lead_output" "vocal-utility lead purificados" "pop-lead-vocal aplica semantica lead" || exit 1
assert_contains "$lead_output" "implementation: vocal-utility-family" "pop-lead-vocal expone implementation familia" || exit 1

help_output="$("$REINA_BIN" run vocal-help 2>/dev/null)"
assert_contains "$help_output" "implementation: vocal-help-diagnostic" "vocal-help usa implementation diagnostica" || exit 1
assert_contains "$help_output" "Vocal Help Diagnostic" "vocal-help reporta diagnostico en humano" || exit 1
assert_contains "$help_output" "network_mode:" "vocal-help expone network_mode" || exit 1
assert_contains "$help_output" "recommendation:" "vocal-help expone recomendacion" || exit 1
assert_contains "$help_output" "assist_mode: diagnostic" "vocal-help declara modo diagnostico" || exit 1

help_json="$("$REINA_BIN" --json run vocal-help 2>/dev/null)"
assert_contains "$help_json" "\"ok\":true" "vocal-help --json reporta ok" || exit 1
assert_contains "$help_json" "\"implementation\":\"vocal-help-diagnostic\"" "vocal-help --json expone implementation" || exit 1
assert_contains "$help_json" "Vocal Help Diagnostic" "vocal-help --json incluye diagnostico" || exit 1
assert_contains "$help_json" "network_mode" "vocal-help --json serializa network_mode" || exit 1
assert_contains "$help_json" "recommendation" "vocal-help --json serializa recomendacion" || exit 1

background_output="$("$REINA_BIN" run give-backgrounds-some-life 2>/dev/null)"
assert_contains "$background_output" "vocal-utility background purificados" "give-backgrounds-some-life aplica semantica background" || exit 1

help_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/vocal-help/profile.txt"
lead_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/pop-lead-vocal/profile.txt"
assert_file "$help_profile_path" "vocal-help crea profile.txt" || exit 1
assert_file "$lead_profile_path" "pop-lead-vocal crea profile.txt" || exit 1

help_profile="$(<"$help_profile_path")"
lead_profile="$(<"$lead_profile_path")"

assert_contains "$help_profile" "diagnostic_mode=active" "vocal-help perfil diagnostico" || exit 1
assert_contains "$help_profile" "operational_mode=assist" "vocal-help modo assist" || exit 1
assert_contains "$lead_profile" "operational_mode=lead" "pop-lead-vocal modo lead" || exit 1
assert_contains "$lead_profile" "lead_presence=forward" "pop-lead-vocal foco frontal" || exit 1

help_snapshot_dir="${REINA_STATE_ROOT}/reina-de-copas/snapshots/vocal-help"
typeset -a help_snapshots
help_snapshots=("${help_snapshot_dir}"/*.txt(N))
if (( ${#help_snapshots[@]} == 0 )); then
  print -u2 -- "FAIL: se esperaba snapshot para vocal-help"
  exit 1
fi
help_snapshot="$(<"${help_snapshots[1]}")"
assert_contains "$help_snapshot" "transform=vocal-help-diagnostic" "snapshot vocal-help guarda transform diagnostico" || exit 1
assert_contains "$help_snapshot" "diagnostic_report<<EOF" "snapshot vocal-help incluye reporte" || exit 1

info_output="$("$REINA_BIN" info vocal-help)"
assert_contains "$info_output" "status:       active" "info vocal-help reporta active" || exit 1
assert_contains "$info_output" "family:       vocal-utility" "info vocal-help reporta familia" || exit 1

print -- "presets vocal-utility tests passed"