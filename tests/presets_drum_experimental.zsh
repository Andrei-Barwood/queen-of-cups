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

typeset -a experimental_slugs=(
  parallel-processing-drums
  myon-pop-parallel-magic
  wildin-camel-drums
  wierdly-gated-drums
)

for slug in "${experimental_slugs[@]}"; do
  run_output="$("$REINA_BIN" run "$slug" 2>/dev/null)"
  assert_contains "$run_output" "result_status: ok" "run $slug termina ok" || exit 1
  assert_contains "$run_output" "history_recorded: true" "run $slug registra historial" || exit 1
  assert_contains "$run_output" "runner_kind: family" "run $slug usa runner de familia" || exit 1
  assert_contains "$run_output" "implementation: drum-experimental-family" "run $slug expone implementation" || exit 1
done

parallel_output="$("$REINA_BIN" run parallel-processing-drums 2>/dev/null)"
assert_contains "$parallel_output" "drum-experimental parallel purificado" "parallel-processing-drums aplica semantica parallel" || exit 1

pop_json="$("$REINA_BIN" --json run myon-pop-parallel-magic 2>/dev/null)"
assert_contains "$pop_json" "\"ok\":true" "myon-pop-parallel-magic --json reporta ok" || exit 1
assert_contains "$pop_json" "\"variant\":\"parallel-pop\"" "myon-pop --json expone variant" || exit 1

wild_output="$("$REINA_BIN" run wildin-camel-drums 2>/dev/null)"
assert_contains "$wild_output" "drum-experimental parallel-wild purificado" "wildin-camel-drums aplica semantica wild" || exit 1

gated_output="$("$REINA_BIN" run wierdly-gated-drums 2>/dev/null)"
assert_contains "$gated_output" "drum-experimental gated purificado" "wierdly-gated-drums aplica semantica gated" || exit 1

offline_output="$("$REINA_BIN" --offline run parallel-processing-drums 2>/dev/null)"
assert_contains "$offline_output" "result_status: degraded" "offline degrada capa parallel sin fallar" || exit 1
assert_contains "$offline_output" "fallback local" "offline usa fallback local" || exit 1

offline_json="$("$REINA_BIN" --offline --json run parallel-processing-drums 2>/dev/null)"
assert_contains "$offline_json" "\"ok\":true" "offline parallel --json termina ok degradado" || exit 1
assert_contains "$offline_json" "\"degraded\":true" "offline parallel --json marca degraded" || exit 1
assert_contains "$offline_json" "fallback local" "offline parallel --json incluye fallback" || exit 1

parallel_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/parallel-processing-drums/profile.txt"
gated_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/wierdly-gated-drums/profile.txt"
assert_file "$parallel_profile_path" "parallel-processing-drums crea profile.txt" || exit 1
assert_file "$gated_profile_path" "wierdly-gated-drums crea profile.txt" || exit 1

parallel_profile="$(<"$parallel_profile_path")"
gated_profile="$(<"$gated_profile_path")"
assert_contains "$parallel_profile" "texture_mode=parallel-base" "parallel perfil base" || exit 1
assert_contains "$gated_profile" "texture_mode=gated" "gated perfil de gating" || exit 1
assert_contains "$gated_profile" "gate_shape=deliberate-cuts" "gated cortes deliberados" || exit 1

parallel_snapshot_dir="${REINA_STATE_ROOT}/reina-de-copas/snapshots/parallel-processing-drums"
typeset -a parallel_snapshots
parallel_snapshots=("${parallel_snapshot_dir}"/*.txt(N))
if (( ${#parallel_snapshots[@]} == 0 )); then
  print -u2 -- "FAIL: se esperaba snapshot para parallel-processing-drums"
  exit 1
fi
parallel_snapshot="$(<"${parallel_snapshots[1]}")"
assert_contains "$parallel_snapshot" "transform=parallel-processing" "snapshot parallel guarda transform" || exit 1

info_output="$("$REINA_BIN" info wildin-camel-drums)"
assert_contains "$info_output" "status:       active" "info wildin-camel-drums reporta active" || exit 1
assert_contains "$info_output" "family:       drum-experimental" "info wildin-camel reporta familia" || exit 1

print -- "presets drum-experimental tests passed"