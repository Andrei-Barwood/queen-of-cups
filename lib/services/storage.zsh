function reina_storage_runtime_id() {
  print -- "reina-de-copas"
}

function reina_storage_cache_dir() {
  emulate -L zsh

  if [[ "${REINA_RUNTIME_MODE:-xdg}" == "local" ]]; then
    print -- "${REINA_PROJECT_ROOT}/.reina/cache"
  else
    print -- "${XDG_CACHE_HOME:-$HOME/.cache}/$(reina_storage_runtime_id)"
  fi
}

function reina_storage_state_dir() {
  emulate -L zsh

  if [[ "${REINA_RUNTIME_MODE:-xdg}" == "local" ]]; then
    print -- "${REINA_PROJECT_ROOT}/.reina/state"
  else
    print -- "${XDG_STATE_HOME:-$HOME/.local/state}/$(reina_storage_runtime_id)"
  fi
}

function reina_storage_logs_dir() {
  emulate -L zsh

  print -- "$(reina_storage_state_dir)/logs"
}

function reina_storage_history_dir() {
  emulate -L zsh

  print -- "$(reina_storage_state_dir)/history"
}

function reina_storage_snapshots_dir() {
  emulate -L zsh

  print -- "$(reina_storage_state_dir)/snapshots"
}

function reina_storage_ensure_runtime() {
  emulate -L zsh

  mkdir -p \
    "$(reina_storage_cache_dir)" \
    "$(reina_storage_state_dir)" \
    "$(reina_storage_logs_dir)" \
    "$(reina_storage_history_dir)" \
    "$(reina_storage_snapshots_dir)"
}
