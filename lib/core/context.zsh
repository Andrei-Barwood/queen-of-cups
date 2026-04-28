function reina_context_storage_json() {
  emulate -L zsh

  reina_storage_context_json
}

function reina_context_json() {
  emulate -L zsh
  local runtime_ready="${1:-0}"

  print -rn -- "{"
  print -rn -- "\"network\":$(reina_network_context_json),"
  print -rn -- "\"storage\":$(reina_context_storage_json),"
  print -rn -- "\"flags\":$(reina_flags_json),"
  print -rn -- "\"errors\":{\"contract\":\"shared\"},"
  print -rn -- "\"runtime_ready\":$(reina_json_bool "$runtime_ready")"
  print -rn -- "}"
}

function reina_context_print_human() {
  emulate -L zsh
  local runtime_ready="${1:-0}"

  print -- "Contexto:"
  print -- "  network: $(reina_network_status) ($(reina_network_mode))"
  print -- "  network_client: ${REINA_NETWORK_CLIENT:-curl} available=$(reina_json_bool "${REINA_NETWORK_CLIENT_AVAILABLE:-0}")"
  print -- "  network_policy: timeout=${REINA_NETWORK_TIMEOUT:-5}s retries=${REINA_NETWORK_RETRIES:-2}"
  print -- "  config:  $(reina_storage_config_dir)"
  print -- "  cache:   $(reina_storage_cache_dir)"
  print -- "  state:   $(reina_storage_state_dir)"
  print -- "  runtime: $(reina_storage_runtime_dir)"
  print -- "  logs:    $(reina_storage_logs_dir)"
  print -- "  flags:   $(reina_flags_human_summary)"
  print -- "  runtime_ready: $(reina_json_bool "$runtime_ready")"
}
