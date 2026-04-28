function reina_storage_runtime_id() {
  print -- "reina-de-copas"
}

function reina_storage_app_dir() {
  emulate -L zsh
  local root="${1:-}"

  [[ -n "$root" ]] || return 1
  print -- "${root}/$(reina_storage_runtime_id)"
}

function reina_storage_config_dir() {
  emulate -L zsh

  if [[ -n "${REINA_CONFIG_ROOT:-}" ]]; then
    reina_storage_app_dir "$REINA_CONFIG_ROOT"
  elif [[ "${REINA_RUNTIME_MODE:-xdg}" == "local" ]]; then
    print -- "${REINA_PROJECT_ROOT}/.reina/config"
  else
    reina_storage_app_dir "${XDG_CONFIG_HOME:-$HOME/.config}"
  fi
}

function reina_storage_cache_dir() {
  emulate -L zsh

  if [[ -n "${REINA_CACHE_ROOT:-}" ]]; then
    reina_storage_app_dir "$REINA_CACHE_ROOT"
  elif [[ "${REINA_RUNTIME_MODE:-xdg}" == "local" ]]; then
    print -- "${REINA_PROJECT_ROOT}/.reina/cache"
  else
    reina_storage_app_dir "${XDG_CACHE_HOME:-$HOME/.cache}"
  fi
}

function reina_storage_state_dir() {
  emulate -L zsh

  if [[ -n "${REINA_STATE_ROOT:-}" ]]; then
    reina_storage_app_dir "$REINA_STATE_ROOT"
  elif [[ "${REINA_RUNTIME_MODE:-xdg}" == "local" ]]; then
    print -- "${REINA_PROJECT_ROOT}/.reina/state"
  else
    reina_storage_app_dir "${XDG_STATE_HOME:-$HOME/.local/state}"
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

function reina_storage_runtime_dir() {
  emulate -L zsh

  print -- "$(reina_storage_state_dir)/runtime"
}

function reina_storage_tmp_dir() {
  emulate -L zsh

  print -- "$(reina_storage_runtime_dir)/tmp"
}

function reina_storage_locks_dir() {
  emulate -L zsh

  print -- "$(reina_storage_runtime_dir)/locks"
}

function reina_storage_network_cache_dir() {
  emulate -L zsh

  print -- "$(reina_storage_cache_dir)/network"
}

function reina_storage_preset_cache_dir() {
  emulate -L zsh

  print -- "$(reina_storage_cache_dir)/presets"
}

function reina_storage_global_config_dir() {
  emulate -L zsh

  print -- "$(reina_storage_config_dir)/global"
}

function reina_storage_preset_config_dir() {
  emulate -L zsh

  print -- "$(reina_storage_config_dir)/presets"
}

function reina_storage_set_error() {
  emulate -L zsh
  local key="${1:-ERR_STORE_FAILURE}"
  local message="${2:-$(reina_error_message "$key")}"
  local context="${3:-category=${REINA_STORE_LAST_CATEGORY:-} key=${REINA_STORE_LAST_KEY:-} scope=${REINA_STORE_LAST_SCOPE:-}}"
  local details="${4:-path=${REINA_STORE_LAST_PATH:-}}"

  typeset -gx REINA_STORE_LAST_STATUS="error"
  typeset -gx REINA_STORE_LAST_ERROR="$key"
  reina_fail "$key" "$message" "storage" "$context" "$details"
}

function reina_storage_reset_result() {
  emulate -L zsh

  typeset -gx REINA_STORE_LAST_STATUS="idle"
  typeset -gx REINA_STORE_LAST_VALUE=""
  typeset -gx REINA_STORE_LAST_PATH=""
  typeset -gx REINA_STORE_LAST_META_PATH=""
  typeset -gx REINA_STORE_LAST_CATEGORY=""
  typeset -gx REINA_STORE_LAST_KEY=""
  typeset -gx REINA_STORE_LAST_SCOPE=""
  typeset -gx REINA_STORE_LAST_SOURCE=""
  typeset -gx REINA_STORE_LAST_ERROR=""
}

function reina_storage_init() {
  emulate -L zsh
  local -a dirs
  dirs=(
    "$(reina_storage_config_dir)"
    "$(reina_storage_global_config_dir)"
    "$(reina_storage_preset_config_dir)"
    "$(reina_storage_cache_dir)"
    "$(reina_storage_network_cache_dir)"
    "$(reina_storage_preset_cache_dir)"
    "$(reina_storage_state_dir)"
    "$(reina_storage_logs_dir)"
    "$(reina_storage_history_dir)"
    "$(reina_storage_snapshots_dir)"
    "$(reina_storage_runtime_dir)"
    "$(reina_storage_tmp_dir)"
    "$(reina_storage_locks_dir)"
  )

  typeset -gx REINA_STORE_INITIALIZED=1
  typeset -gx REINA_STORE_CONFIG_DIR="$(reina_storage_config_dir)"
  typeset -gx REINA_STORE_CACHE_DIR="$(reina_storage_cache_dir)"
  typeset -gx REINA_STORE_STATE_DIR="$(reina_storage_state_dir)"
  typeset -gx REINA_STORE_RUNTIME_DIR="$(reina_storage_runtime_dir)"

  if ! mkdir -p "${dirs[@]}"; then
    reina_storage_set_error ERR_STORE_INIT "no se pudo inicializar el runtime de storage" "runtime=init" "config=$(reina_storage_config_dir) cache=$(reina_storage_cache_dir) state=$(reina_storage_state_dir)"
    return $?
  fi

  reina_storage_reset_result
  log_debug "storage init config=$REINA_STORE_CONFIG_DIR cache=$REINA_STORE_CACHE_DIR state=$REINA_STORE_STATE_DIR"
}

function reina_storage_ensure_runtime() {
  emulate -L zsh

  reina_storage_init
}

function reina_storage_sanitize_key() {
  emulate -L zsh
  local key="${1:-}"

  print -rn -- "$key" | sed -E 's/[^A-Za-z0-9._-]+/_/g; s/^_+//; s/_+$//'
}

function reina_storage_scope_or_global() {
  emulate -L zsh
  local scope="${1:-global}"

  [[ -n "$scope" ]] || scope="global"
  reina_storage_sanitize_key "$scope"
}

function reina_storage_category_dir() {
  emulate -L zsh
  local category="${1:-}"
  local scope="${2:-global}"
  local safe_scope

  safe_scope="$(reina_storage_scope_or_global "$scope")"

  case "$category" in
    config)
      if [[ "$safe_scope" == "global" ]]; then
        print -- "$(reina_storage_global_config_dir)"
      else
        print -- "$(reina_storage_preset_config_dir)/$safe_scope"
      fi
      ;;
    cache)
      print -- "$(reina_storage_cache_dir)/$safe_scope"
      ;;
    history)
      print -- "$(reina_storage_history_dir)/$safe_scope"
      ;;
    snapshots|snapshot)
      print -- "$(reina_storage_snapshots_dir)/$safe_scope"
      ;;
    runtime)
      print -- "$(reina_storage_runtime_dir)/$safe_scope"
      ;;
    locks|lock)
      print -- "$(reina_storage_locks_dir)"
      ;;
    *)
      return 1
      ;;
  esac
}

function reina_storage_body_path() {
  emulate -L zsh
  local category="${1:-}"
  local key="${2:-}"
  local scope="${3:-global}"
  local dir safe_key

  dir="$(reina_storage_category_dir "$category" "$scope")" || return 1
  safe_key="$(reina_storage_sanitize_key "$key")"
  [[ -n "$safe_key" ]] || return 1

  print -- "${dir}/${safe_key}.txt"
}

function reina_storage_meta_path() {
  emulate -L zsh
  local category="${1:-}"
  local key="${2:-}"
  local scope="${3:-global}"
  local dir safe_key

  dir="$(reina_storage_category_dir "$category" "$scope")" || return 1
  safe_key="$(reina_storage_sanitize_key "$key")"
  [[ -n "$safe_key" ]] || return 1

  print -- "${dir}/${safe_key}.meta"
}

function reina_storage_atomic_write() {
  emulate -L zsh
  local target_path="${1:-}"
  local value="${2:-}"
  local dir tmp

  [[ -n "$target_path" ]] || return 1
  dir="${target_path:h}"
  mkdir -p "$dir" || return 1
  tmp="$(mktemp "${dir}/.tmp.XXXXXX")" || return 1

  if ! print -rn -- "$value" > "$tmp"; then
    rm -f "$tmp"
    return 1
  fi

  mv -f "$tmp" "$target_path"
}

function reina_storage_meta_text() {
  emulate -L zsh
  local category="${1:-}"
  local key="${2:-}"
  local scope="${3:-global}"
  local ttl="${4:-0}"
  local origin="${5:-local}"
  local now

  now="$(date +%s)"
  print -- "key=$key"
  print -- "category=$category"
  print -- "scope=$scope"
  print -- "origin=$origin"
  print -- "created_epoch=$now"
  print -- "ttl_seconds=$ttl"
}

function reina_storage_put() {
  emulate -L zsh
  local category="${1:-}"
  local key="${2:-}"
  local value="${3:-}"
  local scope="${4:-global}"
  local ttl="${5:-0}"
  local origin="${6:-local}"
  local body_path meta_path meta_text

  reina_storage_init || return $?
  reina_storage_reset_result

  body_path="$(reina_storage_body_path "$category" "$key" "$scope")" || {
    reina_storage_set_error ERR_STORE_RUNTIME_INVALID "categoria de storage invalida: $category" "category=$category key=$key scope=$scope"
    return $?
  }
  meta_path="$(reina_storage_meta_path "$category" "$key" "$scope")" || return $?
  meta_text="$(reina_storage_meta_text "$category" "$key" "$scope" "$ttl" "$origin")"

  if ! reina_storage_atomic_write "$body_path" "$value"; then
    reina_storage_set_error ERR_STORE_WRITE "no se pudo escribir $body_path" "category=$category key=$key scope=$scope" "path=$body_path"
    return $?
  fi

  if ! reina_storage_atomic_write "$meta_path" "$meta_text"; then
    reina_storage_set_error ERR_STORE_WRITE "no se pudo escribir metadata de $body_path" "category=$category key=$key scope=$scope" "path=$meta_path"
    return $?
  fi

  REINA_STORE_LAST_STATUS="ok"
  REINA_STORE_LAST_PATH="$body_path"
  REINA_STORE_LAST_META_PATH="$meta_path"
  REINA_STORE_LAST_CATEGORY="$category"
  REINA_STORE_LAST_KEY="$key"
  REINA_STORE_LAST_SCOPE="$scope"
  REINA_STORE_LAST_SOURCE="$origin"
}

function reina_storage_get() {
  emulate -L zsh
  local category="${1:-}"
  local key="${2:-}"
  local scope="${3:-global}"
  local body_path meta_path

  reina_storage_init || return $?
  reina_storage_reset_result

  body_path="$(reina_storage_body_path "$category" "$key" "$scope")" || {
    reina_storage_set_error ERR_STORE_RUNTIME_INVALID "categoria de storage invalida: $category" "category=$category key=$key scope=$scope"
    return $?
  }
  meta_path="$(reina_storage_meta_path "$category" "$key" "$scope")" || return $?

  if [[ -d "$body_path" || -d "$meta_path" ]]; then
    reina_storage_set_error ERR_STORE_CORRUPT "entrada corrupta en storage: $category/$key" "category=$category key=$key scope=$scope" "path=$body_path meta=$meta_path"
    return $?
  fi

  if [[ ! -f "$body_path" ]]; then
    reina_storage_set_error ERR_STORE_NOT_FOUND "entrada no encontrada: $category/$key" "category=$category key=$key scope=$scope" "path=$body_path"
    return $?
  fi

  if ! REINA_STORE_LAST_VALUE="$(<"$body_path")"; then
    reina_storage_set_error ERR_STORE_READ "no se pudo leer $body_path" "category=$category key=$key scope=$scope" "path=$body_path"
    return $?
  fi

  REINA_STORE_LAST_STATUS="ok"
  REINA_STORE_LAST_PATH="$body_path"
  REINA_STORE_LAST_META_PATH="$meta_path"
  REINA_STORE_LAST_CATEGORY="$category"
  REINA_STORE_LAST_KEY="$key"
  REINA_STORE_LAST_SCOPE="$scope"
  REINA_STORE_LAST_SOURCE="storage"
}

function reina_storage_exists() {
  emulate -L zsh
  local category="${1:-}"
  local key="${2:-}"
  local scope="${3:-global}"
  local body_path

  body_path="$(reina_storage_body_path "$category" "$key" "$scope")" || return 1
  [[ -f "$body_path" ]]
}

function reina_storage_delete() {
  emulate -L zsh
  local category="${1:-}"
  local key="${2:-}"
  local scope="${3:-global}"
  local body_path meta_path

  reina_storage_init || return $?
  body_path="$(reina_storage_body_path "$category" "$key" "$scope")" || return $?
  meta_path="$(reina_storage_meta_path "$category" "$key" "$scope")" || return $?

  rm -f "$body_path" "$meta_path" || {
    reina_storage_set_error ERR_STORE_WRITE "no se pudo borrar $category/$key" "category=$category key=$key scope=$scope" "path=$body_path"
    return $?
  }
}

function reina_storage_list() {
  emulate -L zsh
  local category="${1:-}"
  local scope="${2:-global}"
  local dir
  local -a body_paths

  dir="$(reina_storage_category_dir "$category" "$scope")" || {
    reina_storage_set_error ERR_STORE_RUNTIME_INVALID "categoria de storage invalida: $category" "category=$category scope=$scope"
    return $?
  }

  [[ -d "$dir" ]] || return 0
  body_paths=("$dir"/*.txt(N.))

  if (( ${#body_paths[@]} > 0 )); then
    printf '%s\n' "${body_paths[@]}" | sort
  fi
}

function reina_storage_meta_value() {
  emulate -L zsh
  local meta_path="${1:-}"
  local key="${2:-}"

  [[ -f "$meta_path" ]] || return 1
  awk -F '=' -v key="$key" '$1 == key { print substr($0, index($0, "=") + 1); exit }' "$meta_path"
}

function reina_storage_prune() {
  emulate -L zsh
  local category="${1:-cache}"
  local scope="${2:-global}"
  local ttl="${3:-86400}"
  local dir now body_path meta_path created age
  local -a body_paths

  reina_storage_init || return $?
  dir="$(reina_storage_category_dir "$category" "$scope")" || {
    reina_storage_set_error ERR_STORE_RUNTIME_INVALID "categoria de storage invalida: $category" "category=$category scope=$scope"
    return $?
  }
  [[ -d "$dir" ]] || return 0

  now="$(date +%s)"
  body_paths=("$dir"/*.txt(N.))

  for body_path in "${body_paths[@]}"; do
    meta_path="${body_path:r}.meta"
    created="$(reina_storage_meta_value "$meta_path" created_epoch)"
    [[ -n "$created" ]] || continue
    [[ "$created" == <-> ]] || continue

    age=$(( now - created ))
    if (( age > ttl )); then
      rm -f "$body_path" "$meta_path" || {
        reina_storage_set_error ERR_STORE_PRUNE "no se pudo limpiar $body_path" "category=$category scope=$scope" "path=$body_path"
        return $?
      }
    fi
  done
}

function reina_storage_snapshot() {
  emulate -L zsh
  local preset="${1:-global}"
  local value="${2:-}"
  local context="${3:-manual}"
  local origin="${4:-local}"
  local timestamp key

  timestamp="$(date -u '+%Y%m%dT%H%M%SZ')"
  key="${timestamp}-${preset}-${context}"
  reina_storage_put snapshots "$key" "$value" "$preset" 0 "$origin"
}

function reina_storage_record_history() {
  emulate -L zsh
  local preset="${1:-global}"
  local result="${2:-unknown}"
  local exit_code="${3:-0}"
  local flags="${4:-}"
  local network_mode="${5:-unknown}"
  local degraded="${6:-false}"
  local error_code="${7:-}"
  local fallback="${8:-}"
  local timestamp key value

  timestamp="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  key="$(date -u '+%Y%m%dT%H%M%SZ')-${preset}"
  value=$'timestamp='"$timestamp"$'\n'
  value+=$'preset='"$preset"$'\n'
  value+=$'flags='"$flags"$'\n'
  value+=$'network='"$network_mode"$'\n'
  value+=$'result='"$result"$'\n'
  value+=$'exit_code='"$exit_code"$'\n'
  value+=$'degraded='"$degraded"$'\n'
  value+=$'error_code='"$error_code"$'\n'
  value+=$'fallback='"$fallback"$'\n'

  reina_storage_put history "$key" "$value" "$preset" 0 "runner"
}

function reina_storage_lock_path() {
  emulate -L zsh
  local key
  key="$(reina_storage_sanitize_key "${1:-lock}")"

  print -- "$(reina_storage_locks_dir)/${key}.lock"
}

function reina_storage_lock() {
  emulate -L zsh
  local key="${1:-lock}"
  local ttl="${2:-300}"
  local lock_dir created now age

  reina_storage_init || return $?
  lock_dir="$(reina_storage_lock_path "$key")"

  if [[ -d "$lock_dir" ]]; then
    created="$(reina_storage_meta_value "$lock_dir/meta" created_epoch)"
    now="$(date +%s)"

    if [[ -n "$created" && "$created" == <-> ]]; then
      age=$(( now - created ))
      if (( age > ttl )); then
        rm -rf "$lock_dir"
      fi
    fi
  fi

  if ! mkdir "$lock_dir" 2>/dev/null; then
    reina_storage_set_error ERR_STORE_LOCKED "storage bloqueado: $key" "lock=$key" "path=$lock_dir"
    return $?
  fi

  {
    print -- "key=$key"
    print -- "pid=$$"
    print -- "created_epoch=$(date +%s)"
    print -- "ttl_seconds=$ttl"
  } > "$lock_dir/meta" || {
    rm -rf "$lock_dir"
    reina_storage_set_error ERR_STORE_WRITE "no se pudo escribir lock $key" "lock=$key" "path=$lock_dir/meta"
    return $?
  }

  REINA_STORE_LAST_STATUS="ok"
  REINA_STORE_LAST_PATH="$lock_dir"
}

function reina_storage_unlock() {
  emulate -L zsh
  local key="${1:-lock}"
  local lock_dir

  lock_dir="$(reina_storage_lock_path "$key")"
  rm -rf "$lock_dir"
}

function reina_storage_config_get() {
  emulate -L zsh
  local key="${1:-}"
  local preset="${2:-}"
  local default="${3:-}"
  local scope body_path meta_path

  reina_storage_init || return $?
  reina_storage_reset_result

  for scope in "$preset" global; do
    [[ -n "$scope" ]] || continue

    body_path="$(reina_storage_body_path config "$key" "$scope")" || continue
    meta_path="$(reina_storage_meta_path config "$key" "$scope")" || continue

    if [[ -d "$body_path" || -d "$meta_path" ]]; then
      reina_degrade ERR_STORE_CORRUPT "config corrupta ignorada; usando fallback" "storage" "key=$key scope=$scope" "config_fallback" "path=$body_path"
      continue
    fi

    [[ -f "$body_path" ]] || continue

    if ! REINA_STORE_LAST_VALUE="$(<"$body_path")"; then
      reina_degrade ERR_STORE_READ "config ilegible ignorada; usando fallback" "storage" "key=$key scope=$scope" "config_fallback" "path=$body_path"
      continue
    fi

    REINA_STORE_LAST_STATUS="ok"
    REINA_STORE_LAST_PATH="$body_path"
    REINA_STORE_LAST_META_PATH="$meta_path"
    REINA_STORE_LAST_CATEGORY="config"
    REINA_STORE_LAST_KEY="$key"
    REINA_STORE_LAST_SCOPE="$scope"
    REINA_STORE_LAST_SOURCE="storage"
    return 0
  done

  REINA_STORE_LAST_STATUS="default"
  REINA_STORE_LAST_KEY="$key"
  REINA_STORE_LAST_SCOPE="${preset:-global}"
  REINA_STORE_LAST_VALUE="$default"
}

function reina_storage_context_json() {
  emulate -L zsh

  print -rn -- "{"
  print -rn -- "\"config\":\"$(reina_json_escape "$(reina_storage_config_dir)")\","
  print -rn -- "\"cache\":\"$(reina_json_escape "$(reina_storage_cache_dir)")\","
  print -rn -- "\"state\":\"$(reina_json_escape "$(reina_storage_state_dir)")\","
  print -rn -- "\"logs\":\"$(reina_json_escape "$(reina_storage_logs_dir)")\","
  print -rn -- "\"history\":\"$(reina_json_escape "$(reina_storage_history_dir)")\","
  print -rn -- "\"snapshots\":\"$(reina_json_escape "$(reina_storage_snapshots_dir)")\","
  print -rn -- "\"runtime\":\"$(reina_json_escape "$(reina_storage_runtime_dir)")\","
  print -rn -- "\"tmp\":\"$(reina_json_escape "$(reina_storage_tmp_dir)")\","
  print -rn -- "\"locks\":\"$(reina_json_escape "$(reina_storage_locks_dir)")\","
  print -rn -- "\"network_cache\":\"$(reina_json_escape "$(reina_storage_network_cache_dir)")\","
  print -rn -- "\"preset_cache\":\"$(reina_json_escape "$(reina_storage_preset_cache_dir)")\""
  print -rn -- "}"
}

function store_init() { reina_storage_init "$@" }
function store_get() { reina_storage_get "$@" }
function store_put() { reina_storage_put "$@" }
function store_exists() { reina_storage_exists "$@" }
function store_delete() { reina_storage_delete "$@" }
function store_list() { reina_storage_list "$@" }
function store_prune() { reina_storage_prune "$@" }
function store_snapshot() { reina_storage_snapshot "$@" }
function store_lock() { reina_storage_lock "$@" }
function store_unlock() { reina_storage_unlock "$@" }
