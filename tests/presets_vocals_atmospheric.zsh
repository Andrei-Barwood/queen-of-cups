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

typeset -a vocal_slugs=(
  dark-vocals
  dreamy-camel-vocals
  sparkley-camel-vocals
  warm-springy-vocals
)

for slug in "${vocal_slugs[@]}"; do
  run_output="$("$REINA_BIN" run "$slug" 2>/dev/null)"
  assert_contains "$run_output" "result_status: ok" "run $slug termina ok" || exit 1
  assert_contains "$run_output" "history_recorded: true" "run $slug registra historial" || exit 1
  assert_contains "$run_output" "runner_kind: family" "run $slug usa runner de familia" || exit 1
  assert_contains "$run_output" "implementation: vocals-atmospheric-family" "run $slug expone implementation" || exit 1
done

dark_output="$("$REINA_BIN" run dark-vocals 2>/dev/null)"
assert_contains "$dark_output" "vocals dark purificados" "dark-vocals aplica semantica dark" || exit 1

dreamy_json="$("$REINA_BIN" --json run dreamy-camel-vocals 2>/dev/null)"
assert_contains "$dreamy_json" "\"ok\":true" "dreamy-camel-vocals --json reporta ok" || exit 1
assert_contains "$dreamy_json" "\"variant\":\"dreamy\"" "dreamy-camel-vocals --json expone variant" || exit 1
assert_contains "$dreamy_json" "\"implementation\":\"vocals-atmospheric-family\"" "dreamy-camel --json expone implementation" || exit 1

sparkley_output="$("$REINA_BIN" run sparkley-camel-vocals 2>/dev/null)"
assert_contains "$sparkley_output" "vocals sparkley-camel purificados" "sparkley-camel-vocals aplica semantica sparkly" || exit 1

warm_output="$("$REINA_BIN" run warm-springy-vocals 2>/dev/null)"
assert_contains "$warm_output" "vocals warm-springy purificados" "warm-springy-vocals aplica semantica warm" || exit 1

dreamy_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/dreamy-camel-vocals/profile.txt"
sparkley_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/sparkley-camel-vocals/profile.txt"
dark_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/dark-vocals/profile.txt"

assert_file "$dreamy_profile_path" "dreamy-camel-vocals crea profile.txt" || exit 1
assert_file "$sparkley_profile_path" "sparkley-camel-vocals crea profile.txt" || exit 1
assert_file "$dark_profile_path" "dark-vocals crea profile.txt" || exit 1

dreamy_profile="$(<"$dreamy_profile_path")"
sparkley_profile="$(<"$sparkley_profile_path")"
dark_profile="$(<"$dark_profile_path")"

assert_contains "$dreamy_profile" "camel_axis=active" "dreamy activa eje camel" || exit 1
assert_contains "$dreamy_profile" "camel_identity=line-of-continuity" "dreamy declara identidad camel" || exit 1
assert_contains "$sparkley_profile" "camel_axis=active" "sparkley activa eje camel" || exit 1
assert_contains "$dark_profile" "camel_axis=latent" "dark mantiene camel latente" || exit 1
assert_contains "$dark_profile" "presence_shape=shadow-forward" "dark perfil de sombra" || exit 1

assert_not_contains "$dark_profile" "camel_line=active" "dark no fuerza linea camel en perfil" || exit 1

dreamy_snapshot_dir="${REINA_STATE_ROOT}/reina-de-copas/snapshots/dreamy-camel-vocals"
dark_snapshot_dir="${REINA_STATE_ROOT}/reina-de-copas/snapshots/dark-vocals"
typeset -a dreamy_snapshots dark_snapshots
dreamy_snapshots=("${dreamy_snapshot_dir}"/*.txt(N))
dark_snapshots=("${dark_snapshot_dir}"/*.txt(N))

if (( ${#dreamy_snapshots[@]} == 0 || ${#dark_snapshots[@]} == 0 )); then
  print -u2 -- "FAIL: se esperaban snapshots para dreamy y dark"
  exit 1
fi

dreamy_snapshot="$(<"${dreamy_snapshots[1]}")"
dark_snapshot="$(<"${dark_snapshots[1]}")"

assert_contains "$dreamy_snapshot" "transform=dreamy-camel-continuum" "snapshot dreamy guarda transform camel" || exit 1
assert_contains "$dreamy_snapshot" "camel_line=active" "snapshot dreamy activa camel_line" || exit 1
assert_contains "$dark_snapshot" "transform=dark-intimate" "snapshot dark guarda transform sombra" || exit 1
assert_not_contains "$dark_snapshot" "camel_line=active" "dark no contamina linea camel" || exit 1

info_output="$("$REINA_BIN" info dreamy-camel-vocals)"
assert_contains "$info_output" "status:       active" "info dreamy-camel reporta active" || exit 1
assert_contains "$info_output" "family:       vocals-atmospheric" "info dreamy-camel reporta familia" || exit 1

print -- "presets vocals-atmospheric tests passed"