function reina_context_storage_json() {
  emulate -L zsh

  print -rn -- "{"
  print -rn -- "\"cache\":\"$(reina_json_escape "$(reina_storage_cache_dir)")\","
  print -rn -- "\"state\":\"$(reina_json_escape "$(reina_storage_state_dir)")\","
  print -rn -- "\"logs\":\"$(reina_json_escape "$(reina_storage_logs_dir)")\","
  print -rn -- "\"history\":\"$(reina_json_escape "$(reina_storage_history_dir)")\","
  print -rn -- "\"snapshots\":\"$(reina_json_escape "$(reina_storage_snapshots_dir)")\""
  print -rn -- "}"
}

function reina_context_json() {
  emulate -L zsh
  local runtime_ready="${1:-0}"

  print -rn -- "{"
  print -rn -- "\"network\":{\"mode\":\"$(reina_json_escape "$(reina_network_mode)")\"},"
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
  print -- "  network: $(reina_network_mode)"
  print -- "  cache:   $(reina_storage_cache_dir)"
  print -- "  state:   $(reina_storage_state_dir)"
  print -- "  logs:    $(reina_storage_logs_dir)"
  print -- "  flags:   $(reina_flags_human_summary)"
  print -- "  runtime_ready: $(reina_json_bool "$runtime_ready")"
}
