function reina_preset_tokenize() {
  emulate -L zsh
  local value="${1:-}"

  print -rn -- "${value//-/_}"
}

function reina_preset_implementations_dir() {
  emulate -L zsh

  if [[ -n "${REINA_PRESET_IMPL_DIR:-}" ]]; then
    print -- "$REINA_PRESET_IMPL_DIR"
  else
    print -- "${REINA_PROJECT_ROOT}/lib/presets/implementations"
  fi
}

function reina_preset_families_dir() {
  emulate -L zsh

  if [[ -n "${REINA_PRESET_FAMILIES_DIR:-}" ]]; then
    print -- "$REINA_PRESET_FAMILIES_DIR"
  else
    print -- "${REINA_PROJECT_ROOT}/lib/presets/families"
  fi
}

function reina_preset_runner_name() {
  emulate -L zsh
  local slug="${1:-}"

  print -- "reina_preset_$(reina_preset_tokenize "$slug")_run"
}

function reina_preset_family_runner_name() {
  emulate -L zsh
  local family="${1:-}"

  print -- "reina_family_$(reina_preset_tokenize "$family")_run"
}

function reina_preset_reset_result() {
  emulate -L zsh

  typeset -gx \
    REINA_PRESET_RESULT_STATUS="ok" \
    REINA_PRESET_RESULT_MESSAGE="" \
    REINA_PRESET_RESULT_IMPLEMENTATION="" \
    REINA_PRESET_RUNNER_KIND=""
}

function reina_preset_validate_context() {
  emulate -L zsh

  if [[ -z "${REINA_PRESET_SLUG:-}" ]]; then
    reina_fail ERR_RUNTIME_MANIFEST_INVALID "contexto de preset incompleto: falta slug" "preset" "field=slug"
    return $?
  fi

  if [[ -z "${REINA_PRESET_FAMILY:-}" ]]; then
    reina_fail ERR_RUNTIME_MANIFEST_INVALID "contexto de preset incompleto: falta family" "preset" "slug=$REINA_PRESET_SLUG field=family"
    return $?
  fi

  if [[ -z "${REINA_PRESET_STATUS:-}" ]]; then
    reina_fail ERR_RUNTIME_MANIFEST_INVALID "contexto de preset incompleto: falta status" "preset" "slug=$REINA_PRESET_SLUG field=status"
    return $?
  fi

  return 0
}

function reina_preset_set_result() {
  emulate -L zsh
  local result_status="${1:-ok}"
  local message="${2:-}"
  local implementation="${3:-}"

  typeset -gx \
    REINA_PRESET_RESULT_STATUS="$result_status" \
    REINA_PRESET_RESULT_MESSAGE="$message" \
    REINA_PRESET_RESULT_IMPLEMENTATION="$implementation"

  case "$result_status" in
    failed)
      REINA_RESULT_STATUS="failed"
      return 1
      ;;
    degraded)
      [[ "${REINA_RESULT_STATUS:-ok}" == "failed" ]] || REINA_RESULT_STATUS="degraded"
      return 0
      ;;
    *)
      [[ "${REINA_RESULT_STATUS:-ok}" == "failed" ]] || REINA_RESULT_STATUS="ok"
      return 0
      ;;
  esac
}

function reina_preset_profile_get() {
  emulate -L zsh
  local key="${1:-profile}"
  local default="${2:-}"

  reina_storage_config_get "$key" "$REINA_PRESET_SLUG" "$default"
}

function reina_preset_profile_put() {
  emulate -L zsh
  local key="${1:-profile}"
  local value="${2:-}"

  if (( REINA_DRY_RUN )); then
    return 0
  fi

  reina_storage_config_put "$key" "$REINA_PRESET_SLUG" "$value"
}

function reina_preset_snapshot_record() {
  emulate -L zsh
  local value="${1:-}"
  local context="${2:-run}"

  if (( REINA_DRY_RUN )); then
    return 0
  fi

  if ! reina_storage_snapshot "$REINA_PRESET_SLUG" "$value" "$context" "preset"; then
    reina_recover_last_error_as_degradation "snapshot_skipped"
    return 0
  fi

  return 0
}

function reina_preset_history_record() {
  emulate -L zsh
  local result="${1:-ok}"
  local exit_code="${2:-0}"
  local flags="${3:-$(reina_flags_human_summary)}"
  local network_mode="${4:-$(reina_network_mode)}"
  local degraded="${5:-false}"
  local error_code="${6:-}"
  local fallback="${7:-}"

  if (( REINA_DRY_RUN )); then
    return 0
  fi

  if reina_storage_record_history \
    "$REINA_PRESET_SLUG" \
    "$result" \
    "$exit_code" \
    "$flags" \
    "$network_mode" \
    "$degraded" \
    "$error_code" \
    "$fallback" >/dev/null 2>&1; then
    return 0
  fi

  reina_recover_last_error_as_degradation "history_skipped"
  return 1
}

function reina_preset_result_json() {
  emulate -L zsh

  print -rn -- "{"
  print -rn -- "\"status\":\"$(reina_json_escape "${REINA_PRESET_RESULT_STATUS:-ok}")\","
  print -rn -- "\"message\":\"$(reina_json_escape "${REINA_PRESET_RESULT_MESSAGE:-}")\","
  print -rn -- "\"implementation\":\"$(reina_json_escape "${REINA_PRESET_RESULT_IMPLEMENTATION:-}")\","
  print -rn -- "\"runner_kind\":\"$(reina_json_escape "${REINA_PRESET_RUNNER_KIND:-}")\""
  print -rn -- "}"
}