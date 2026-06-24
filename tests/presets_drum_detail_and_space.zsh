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

typeset -a detail_slugs=(
  hats
  drums-overheads
  ohs
  trash-drum-room
  drum-room-smash
  fill-kollin
)

for slug in "${detail_slugs[@]}"; do
  run_output="$("$REINA_BIN" run "$slug" 2>/dev/null)"
  assert_contains "$run_output" "result_status: ok" "run $slug termina ok" || exit 1
  assert_contains "$run_output" "history_recorded: true" "run $slug registra historial" || exit 1
  assert_contains "$run_output" "runner_kind: family" "run $slug usa runner de familia" || exit 1
  assert_contains "$run_output" "implementation: drum-detail-and-space-family" "run $slug expone implementation" || exit 1
done

hats_output="$("$REINA_BIN" run hats 2>/dev/null)"
assert_contains "$hats_output" "drum-detail-and-space detail purificado" "hats aplica semantica detail" || exit 1

ohs_json="$("$REINA_BIN" --json run ohs 2>/dev/null)"
assert_contains "$ohs_json" "\"ok\":true" "ohs --json reporta ok" || exit 1
assert_contains "$ohs_json" "\"variant\":\"overheads-compact\"" "ohs --json expone variant compact" || exit 1

wide_output="$("$REINA_BIN" run drums-overheads 2>/dev/null)"
assert_contains "$wide_output" "drum-detail-and-space overheads-wide purificado" "drums-overheads aplica wide" || exit 1

fill_output="$("$REINA_BIN" run fill-kollin 2>/dev/null)"
assert_contains "$fill_output" "drum-detail-and-space fill purificado" "fill-kollin aplica semantica fill" || exit 1

ohs_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/ohs/profile.txt"
wide_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/drums-overheads/profile.txt"
trash_profile_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/trash-drum-room/profile.txt"

assert_file "$ohs_profile_path" "ohs crea profile.txt" || exit 1
assert_file "$wide_profile_path" "drums-overheads crea profile.txt" || exit 1
assert_file "$trash_profile_path" "trash-drum-room crea profile.txt" || exit 1

ohs_profile="$(<"$ohs_profile_path")"
wide_profile="$(<"$wide_profile_path")"
trash_profile="$(<"$trash_profile_path")"

assert_contains "$ohs_profile" "overheads_relation=compact-not-alias" "ohs declara independencia" || exit 1
assert_contains "$ohs_profile" "perspective=compact-focus" "ohs perspectiva compacta" || exit 1
assert_contains "$wide_profile" "perspective=wide-panorama" "drums-overheads perspectiva wide" || exit 1
assert_contains "$wide_profile" "paired_compact_preset=ohs" "wide referencia ohs como par" || exit 1
assert_contains "$trash_profile" "room_character=trash-aggressive" "trash room agresivo" || exit 1

assert_not_contains "$ohs_profile" "perspective=wide-panorama" "ohs no usa perfil wide" || exit 1
assert_not_contains "$wide_profile" "overheads_relation=compact-not-alias" "wide no usa perfil compact" || exit 1

ohs_snapshot_dir="${REINA_STATE_ROOT}/reina-de-copas/snapshots/ohs"
wide_snapshot_dir="${REINA_STATE_ROOT}/reina-de-copas/snapshots/drums-overheads"
typeset -a ohs_snapshots wide_snapshots
ohs_snapshots=("${ohs_snapshot_dir}"/*.txt(N))
wide_snapshots=("${wide_snapshot_dir}"/*.txt(N))

if (( ${#ohs_snapshots[@]} == 0 || ${#wide_snapshots[@]} == 0 )); then
  print -u2 -- "FAIL: se esperaban snapshots para ohs y drums-overheads"
  exit 1
fi

ohs_snapshot="$(<"${ohs_snapshots[1]}")"
wide_snapshot="$(<"${wide_snapshots[1]}")"

assert_contains "$ohs_snapshot" "transform=ohs-compact" "snapshot ohs guarda transform propio" || exit 1
assert_contains "$ohs_snapshot" "independence=not-alias-of-drums-overheads" "snapshot ohs declara no-alias" || exit 1
assert_contains "$wide_snapshot" "transform=drums-overheads-wide" "snapshot wide guarda transform wide" || exit 1
assert_not_contains "$ohs_snapshot" "transform=drums-overheads-wide" "ohs no contamina transform wide" || exit 1

info_ohs="$("$REINA_BIN" info ohs)"
assert_contains "$info_ohs" "status:       active" "info ohs reporta active" || exit 1
assert_contains "$info_ohs" "slug:         ohs" "info ohs mantiene slug propio" || exit 1
assert_contains "$info_ohs" "family:       drum-detail-and-space" "info ohs reporta familia" || exit 1

info_wide="$("$REINA_BIN" info drums-overheads)"
assert_contains "$info_wide" "slug:         drums-overheads" "info drums-overheads slug distinto de ohs" || exit 1

print -- "presets drum-detail-and-space tests passed"