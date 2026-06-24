#!/usr/bin/env zsh

setopt NO_UNSET PIPE_FAIL

typeset -r PROJECT_ROOT="${0:A:h:h}"
typeset -r REINA_BIN="${PROJECT_ROOT}/bin/reina"
typeset -r TMP_DIR="$(mktemp -d)"
typeset -r FIXTURE_IMPL_DIR="${TMP_DIR}/implementations"
typeset -r FIXTURE_FAMILY_DIR="${TMP_DIR}/families"

function cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

typeset -gx REINA_CONFIG_ROOT="${TMP_DIR}/config-root"
typeset -gx REINA_CACHE_ROOT="${TMP_DIR}/cache-root"
typeset -gx REINA_STATE_ROOT="${TMP_DIR}/state-root"

mkdir -p "$FIXTURE_IMPL_DIR" "$FIXTURE_FAMILY_DIR"

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

stderr_file="$(mktemp)"
"$REINA_BIN" run kick >/dev/null 2>"$stderr_file"
exit_code=$?
stderr_output="$(<"$stderr_file")"
rm -f "$stderr_file"

assert_eq "3" "$exit_code" "preset planned sin implementacion usa exit code 3" || exit 1
assert_contains "$stderr_output" "ERR_PRESET_NOT_IMPLEMENTED" "run falla con ERR_PRESET_NOT_IMPLEMENTED" || exit 1
assert_contains "$stderr_output" "kick" "error menciona el slug" || exit 1

stderr_file="$(mktemp)"
"$REINA_BIN" run kick --dry-run >/dev/null 2>"$stderr_file"
exit_code=$?
stderr_output="$(<"$stderr_file")"
rm -f "$stderr_file"

assert_eq "3" "$exit_code" "dry-run tampoco finge exito en preset no implementado" || exit 1
assert_contains "$stderr_output" "ERR_PRESET_NOT_IMPLEMENTED" "dry-run reporta no implementado" || exit 1

run_json_output="$("$REINA_BIN" --json run kick 2>/dev/null)"
assert_contains "$run_json_output" "\"code\":\"ERR_PRESET_NOT_IMPLEMENTED\"" "run --json serializa ERR_PRESET_NOT_IMPLEMENTED" || exit 1

typeset -gx REINA_PROJECT_ROOT="$PROJECT_ROOT"
typeset -gx REINA_PRESET_IMPL_DIR="$FIXTURE_IMPL_DIR"
typeset -gx REINA_PRESET_FAMILIES_DIR="$FIXTURE_FAMILY_DIR"
typeset -gx REINA_DEBUG=0
typeset -gx REINA_QUIET=1
typeset -gx REINA_OFFLINE=0
typeset -gx REINA_JSON=0
typeset -gx REINA_DRY_RUN=0

source "$PROJECT_ROOT/lib/core/logging.zsh"
source "$PROJECT_ROOT/lib/core/json.zsh"
source "$PROJECT_ROOT/lib/core/flags.zsh"
source "$PROJECT_ROOT/lib/services/errors.zsh"
source "$PROJECT_ROOT/lib/services/storage.zsh"
source "$PROJECT_ROOT/lib/services/network.zsh"
source "$PROJECT_ROOT/lib/core/bootstrap.zsh"
source "$PROJECT_ROOT/lib/presets/dispatcher.zsh"

cat > "$FIXTURE_IMPL_DIR/test-stub.zsh" <<'EOF'
function reina_preset_test_stub_run() {
  reina_preset_set_result ok "stub ejecutado" "test-stub"
  return 0
}
EOF

typeset -gx \
  REINA_PRESET_DISPLAY_NAME="Test Stub" \
  REINA_PRESET_SLUG="test-stub" \
  REINA_PRESET_FAMILY="test-family" \
  REINA_PRESET_VARIANT="stub" \
  REINA_PRESET_STATUS="beta" \
  REINA_PRESET_PRIORITY="999" \
  REINA_PRESET_ALIASES="-" \
  REINA_PRESET_NOTES="fixture de dispatcher"

reina_storage_init || exit 1
reina_storage_ensure_runtime || exit 1
reina_network_init

reina_preset_dispatch 1
exit_code=$?

assert_eq "0" "$exit_code" "dispatcher ejecuta preset por slug" || exit 1
assert_eq "slug" "$REINA_PRESET_RUNNER_KIND" "runner_kind detecta implementacion por slug" || exit 1
assert_eq "test-stub" "$REINA_PRESET_RESULT_IMPLEMENTATION" "resultado expone implementation" || exit 1
assert_eq "stub ejecutado" "$REINA_PRESET_RESULT_MESSAGE" "resultado expone message" || exit 1

cat > "$FIXTURE_FAMILY_DIR/family-only.zsh" <<'EOF'
function reina_family_family_only_run() {
  reina_preset_set_result ok "family runner ejecutado" "family-only-core"
  return 0
}
EOF

typeset -gx \
  REINA_PRESET_DISPLAY_NAME="Family Only" \
  REINA_PRESET_SLUG="family-only-preset" \
  REINA_PRESET_FAMILY="family-only" \
  REINA_PRESET_VARIANT="base" \
  REINA_PRESET_STATUS="active" \
  REINA_PRESET_PRIORITY="998" \
  REINA_PRESET_ALIASES="-" \
  REINA_PRESET_NOTES="fixture de family runner"

reina_preset_dispatch 1
exit_code=$?

assert_eq "0" "$exit_code" "dispatcher ejecuta preset por family runner" || exit 1
assert_eq "family" "$REINA_PRESET_RUNNER_KIND" "runner_kind detecta implementacion por familia" || exit 1
assert_eq "family-only-core" "$REINA_PRESET_RESULT_IMPLEMENTATION" "family runner expone implementation" || exit 1

print -- "preset dispatcher tests passed"