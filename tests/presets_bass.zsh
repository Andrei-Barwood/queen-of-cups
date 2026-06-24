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

typeset -a bass_slugs=(
  bass-in-the-desert
  bass
  put-this-on-bass
  nice-bass
  crunchy-bass
)

for slug in "${bass_slugs[@]}"; do
  run_output="$("$REINA_BIN" run "$slug" 2>/dev/null)"
  assert_contains "$run_output" "result_status: ok" "run $slug termina ok" || exit 1
  assert_contains "$run_output" "history_recorded: true" "run $slug registra historial" || exit 1
done

desert_output="$("$REINA_BIN" run bass-in-the-desert 2>/dev/null)"
assert_contains "$desert_output" "runner_kind: slug" "bass-in-the-desert usa runner por slug" || exit 1
assert_contains "$desert_output" "implementation: bass-in-the-desert" "bass-in-the-desert expone implementation propia" || exit 1
assert_contains "$desert_output" "bass desert purificado" "bass-in-the-desert describe transformacion desert" || exit 1

family_output="$("$REINA_BIN" run bass 2>/dev/null)"
assert_contains "$family_output" "runner_kind: family" "bass usa runner de familia" || exit 1
assert_contains "$family_output" "implementation: bass-family" "bass expone implementation de familia" || exit 1

crunchy_json="$("$REINA_BIN" --json run crunchy-bass 2>/dev/null)"
assert_contains "$crunchy_json" "\"ok\":true" "crunchy-bass --json reporta ok" || exit 1
assert_contains "$crunchy_json" "\"history_recorded\":true" "crunchy-bass --json registra historial" || exit 1
assert_contains "$crunchy_json" "\"implementation\":\"bass-family\"" "crunchy-bass --json expone implementation" || exit 1
assert_contains "$crunchy_json" "\"variant\":\"aggressive\"" "crunchy-bass --json expone variant" || exit 1

info_output="$("$REINA_BIN" info bass-in-the-desert)"
assert_contains "$info_output" "status:       active" "info bass-in-the-desert reporta active" || exit 1

dry_run_output="$("$REINA_BIN" run bass-in-the-desert --dry-run 2>/dev/null)"
assert_contains "$dry_run_output" "history_recorded: false" "dry-run no registra historial" || exit 1
assert_contains "$dry_run_output" "result_status: ok" "dry-run ejecuta preset real sin persistir" || exit 1

profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/bass-in-the-desert/profile.txt"
assert_file "$profile_path" "run crea profile.txt para bass-in-the-desert" || exit 1
profile_body="$(<"$profile_path")"
assert_contains "$profile_body" "desert_mode=true" "profile fundacional incluye desert_mode" || exit 1

snapshot_dir="${REINA_STATE_ROOT}/reina-de-copas/snapshots/bass-in-the-desert"
typeset -a snapshot_files
snapshot_files=("${snapshot_dir}"/*.txt(N))
if (( ${#snapshot_files[@]} == 0 )); then
  print -u2 -- "FAIL: se esperaba al menos un snapshot para bass-in-the-desert"
  exit 1
fi
snapshot_body="$(<"${snapshot_files[1]}")"
assert_contains "$snapshot_body" "transform=desert-purify" "snapshot guarda transformacion desert" || exit 1

history_dir="${REINA_STATE_ROOT}/reina-de-copas/history/bass-in-the-desert"
typeset -a history_files
history_files=("${history_dir}"/*.txt(N))
if (( ${#history_files[@]} == 0 )); then
  print -u2 -- "FAIL: se esperaba historial para bass-in-the-desert"
  exit 1
fi

nice_output="$("$REINA_BIN" run nice-bass 2>/dev/null)"
assert_contains "$nice_output" "bass nice purificado" "nice-bass aplica semantica smooth" || exit 1

print -- "presets bass tests passed"