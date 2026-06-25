source "$REINA_PROJECT_ROOT/lib/presets/family-core.zsh"
source "$REINA_PROJECT_ROOT/lib/presets/network-consciousness.zsh"

function reina_preset_load_slug_implementation() {
  emulate -L zsh
  local slug="${1:-}"
  local impl_file

  [[ -n "$slug" ]] || return 1

  impl_file="$(reina_preset_implementations_dir)/${slug}.zsh"
  if [[ ! -f "$impl_file" ]]; then
    return 1
  fi

  source "$impl_file"
  return 0
}

function reina_preset_load_family_implementation() {
  emulate -L zsh
  local family="${1:-}"
  local family_file

  [[ -n "$family" ]] || return 1

  family_file="$(reina_preset_families_dir)/${family}.zsh"
  if [[ ! -f "$family_file" ]]; then
    return 1
  fi

  source "$family_file"
  return 0
}

function reina_preset_resolve_runner() {
  emulate -L zsh
  local slug="${1:-}"
  local family="${2:-}"
  local runner family_runner

  typeset -gx REINA_PRESET_RUNNER_KIND="" REINA_PRESET_RUNNER_NAME=""

  runner="$(reina_preset_runner_name "$slug")"
  if whence -w "$runner" >/dev/null; then
    REINA_PRESET_RUNNER_KIND="slug"
    REINA_PRESET_RUNNER_NAME="$runner"
    return 0
  fi

  if reina_preset_load_slug_implementation "$slug" && whence -w "$runner" >/dev/null; then
    REINA_PRESET_RUNNER_KIND="slug"
    REINA_PRESET_RUNNER_NAME="$runner"
    return 0
  fi

  family_runner="$(reina_preset_family_runner_name "$family")"
  if whence -w "$family_runner" >/dev/null; then
    REINA_PRESET_RUNNER_KIND="family"
    REINA_PRESET_RUNNER_NAME="$family_runner"
    return 0
  fi

  if reina_preset_load_family_implementation "$family" && whence -w "$family_runner" >/dev/null; then
    REINA_PRESET_RUNNER_KIND="family"
    REINA_PRESET_RUNNER_NAME="$family_runner"
    return 0
  fi

  return 1
}

function reina_preset_dispatch() {
  emulate -L zsh
  local runtime_ready="${1:-0}"
  local runner_name status_code=0

  reina_preset_reset_result
  reina_preset_validate_context || return $?

  if ! reina_preset_resolve_runner "$REINA_PRESET_SLUG" "$REINA_PRESET_FAMILY"; then
    reina_fail \
      ERR_PRESET_NOT_IMPLEMENTED \
      "preset aun no implementado: $REINA_PRESET_SLUG (status=${REINA_PRESET_STATUS})" \
      "preset" \
      "slug=$REINA_PRESET_SLUG status=$REINA_PRESET_STATUS family=$REINA_PRESET_FAMILY variant=$REINA_PRESET_VARIANT"
    return $?
  fi

  runner_name="$REINA_PRESET_RUNNER_NAME"

  log_debug "dispatch slug=$REINA_PRESET_SLUG runner=$runner_name kind=$REINA_PRESET_RUNNER_KIND runtime_ready=$runtime_ready"

  "$runner_name"
  status_code=$?

  if (( status_code != 0 )); then
    [[ "${REINA_RESULT_STATUS:-ok}" == "failed" ]] || REINA_RESULT_STATUS="failed"
    return "$status_code"
  fi

  if [[ "${REINA_PRESET_RESULT_STATUS:-ok}" == "failed" ]]; then
    REINA_RESULT_STATUS="failed"
    return 1
  fi

  if [[ "${REINA_PRESET_RESULT_STATUS:-ok}" == "degraded" ]]; then
    [[ "${REINA_RESULT_STATUS:-ok}" == "failed" ]] || REINA_RESULT_STATUS="degraded"
  fi

  return 0
}

function reina_preset_run_json() {
  emulate -L zsh
  local runtime_ready="${1:-0}"
  local history_recorded="${2:-0}"

  print -rn -- "{"
  print -rn -- "\"ok\":$(reina_error_json_bool "$([[ "${REINA_RESULT_STATUS:-ok}" != "failed" ]] && print 1 || print 0)"),"
  print -rn -- "\"degraded\":$(reina_error_json_bool "$([[ "${REINA_RESULT_STATUS:-ok}" == "degraded" ]] && print 1 || print 0)"),"
  print -rn -- "\"status\":\"$(reina_error_json_escape "${REINA_RESULT_STATUS:-ok}")\","
  print -rn -- "\"command\":\"run\","
  print -rn -- "\"dry_run\":$(reina_json_bool "$REINA_DRY_RUN"),"
  print -rn -- "\"history_recorded\":$(reina_json_bool "$history_recorded"),"
  print -rn -- "\"preset\":$(reina_preset_json),"
  print -rn -- "\"result\":$(reina_preset_result_json),"
  print -rn -- "\"context\":$(reina_context_json "$runtime_ready"),"
  print -rn -- "\"network_graph\":${REINA_PRESET_NETWORK_GRAPH_JSON:-null},"
  print -rn -- "\"warnings\":$(reina_error_records_json warnings),"
  print -rn -- "\"degradations\":$(reina_error_records_json degradations)"
  if [[ -n "${REINA_PRESET_RESULT_MESSAGE:-}" ]]; then
    print -rn -- ",\"message\":\"$(reina_json_escape "$REINA_PRESET_RESULT_MESSAGE")\""
  fi
  print -- "}"
}

function reina_preset_run_print_human() {
  emulate -L zsh
  local runtime_ready="${1:-0}"
  local history_recorded="${2:-0}"

  if (( REINA_QUIET )); then
    print -- "$REINA_PRESET_SLUG ${REINA_PRESET_RESULT_STATUS:-ok}"
    return 0
  fi

  print -- "Run:"
  print -- "  preset:  $REINA_PRESET_DISPLAY_NAME"
  print -- "  slug:    $REINA_PRESET_SLUG"
  print -- "  family:  $REINA_PRESET_FAMILY"
  print -- "  variant: $REINA_PRESET_VARIANT"
  print -- "  status:  $REINA_PRESET_STATUS"
  print -- ""
  reina_context_print_human "$runtime_ready"
  print -- ""
  reina_network_consciousness_print_human
  print -- "  runner_kind: ${REINA_PRESET_RUNNER_KIND:-}"
  print -- "  implementation: ${REINA_PRESET_RESULT_IMPLEMENTATION:-}"
  print -- "  history_recorded: $(reina_json_bool "$history_recorded")"
  print -- "  result_status: ${REINA_PRESET_RESULT_STATUS:-ok}"
  print -- "  status: ${REINA_RESULT_STATUS:-ok}"
  if [[ -n "${REINA_PRESET_RESULT_MESSAGE:-}" ]]; then
    print -- ""
    print -- "${REINA_PRESET_RESULT_MESSAGE}"
  fi
}