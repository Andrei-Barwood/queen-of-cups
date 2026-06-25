# Operaciones CLI — doctor, historial, snapshots y pruning (Dia 21).

typeset -ga REINA_DOCTOR_CHECKS
typeset -gx REINA_DOCTOR_STATUS="ok"

function reina_ops_reset_doctor() {
  emulate -L zsh

  typeset -ga REINA_DOCTOR_CHECKS
  REINA_DOCTOR_CHECKS=()
  typeset -gx REINA_DOCTOR_STATUS="ok"
}

function reina_ops_doctor_record() {
  emulate -L zsh
  local name="${1:-}"
  local check_status="${2:-ok}"
  local detail="${3:-}"

  REINA_DOCTOR_CHECKS+=("${name}|${check_status}|${detail}")

  case "$check_status" in
    failed)
      REINA_DOCTOR_STATUS="failed"
      ;;
    degraded)
      [[ "$REINA_DOCTOR_STATUS" == "failed" ]] || REINA_DOCTOR_STATUS="degraded"
      ;;
  esac
}

function reina_ops_zsh_version_ok() {
  emulate -L zsh
  local major="${ZSH_VERSION%%.*}"
  local minor="${${ZSH_VERSION#*.}%%.*}"

  (( major > 5 || (major == 5 && minor >= 4) ))
}

function reina_ops_check_dependency() {
  emulate -L zsh
  local command_name="${1:-}"
  local required="${2:-1}"

  if command -v "$command_name" >/dev/null 2>&1; then
    reina_ops_doctor_record "dependency:${command_name}" "ok" "disponible"
    return 0
  fi

  if (( required )); then
    reina_ops_doctor_record "dependency:${command_name}" "failed" "no encontrado"
    return 1
  fi

  reina_ops_doctor_record "dependency:${command_name}" "degraded" "no encontrado"
  return 1
}

function reina_ops_check_writable_dir() {
  emulate -L zsh
  local label="${1:-}"
  local dir="${2:-}"
  local probe

  [[ -n "$dir" ]] || {
    reina_ops_doctor_record "$label" "failed" "ruta vacia"
    return 1
  }

  if ! mkdir -p "$dir" 2>/dev/null; then
    reina_ops_doctor_record "$label" "failed" "no se pudo crear $dir"
    return 1
  fi

  probe="${dir}/.reina-doctor-probe"
  if print -n -- "ok" > "$probe" 2>/dev/null; then
    rm -f "$probe"
    reina_ops_doctor_record "$label" "ok" "escribible"
    return 0
  fi

  reina_ops_doctor_record "$label" "failed" "sin permisos de escritura"
  return 1
}

function reina_ops_doctor_run() {
  emulate -L zsh
  local manifest_count

  reina_ops_reset_doctor

  if reina_ops_zsh_version_ok; then
    reina_ops_doctor_record "runtime:zsh" "ok" "version=${ZSH_VERSION}"
  else
    reina_ops_doctor_record "runtime:zsh" "failed" "version=${ZSH_VERSION} minimo=5.4"
  fi

  reina_ops_check_dependency zsh 1 || true
  reina_ops_check_dependency awk 1 || true
  reina_ops_check_dependency sed 1 || true
  reina_ops_check_dependency grep 1 || true
  reina_ops_check_dependency cut 1 || true
  reina_ops_check_dependency tr 1 || true
  reina_ops_check_dependency sort 1 || true
  reina_ops_check_dependency mktemp 1 || true
  reina_ops_check_dependency date 1 || true
  reina_ops_check_dependency curl 0 || true

  if reina_manifest_validate >/dev/null 2>&1; then
    manifest_count="$(awk 'NR > 1 { count++ } END { print count + 0 }' "$REINA_MANIFEST_PATH")"
    reina_ops_doctor_record "manifest:integrity" "ok" "presets=${manifest_count}"
  else
    reina_ops_doctor_record "manifest:integrity" "failed" "presets/manifest.tsv invalido"
  fi

  if reina_storage_init; then
    reina_ops_doctor_record "storage:init" "ok" "runtime inicializado"
  else
    reina_ops_doctor_record "storage:init" "failed" "no se pudo inicializar storage"
  fi

  reina_ops_check_writable_dir "storage:config" "$(reina_storage_config_dir)" || true
  reina_ops_check_writable_dir "storage:cache" "$(reina_storage_cache_dir)" || true
  reina_ops_check_writable_dir "storage:state" "$(reina_storage_state_dir)" || true

  if [[ "${REINA_NETWORK_CLIENT_AVAILABLE:-0}" == "1" ]]; then
    reina_ops_doctor_record "network:client" "ok" "client=${REINA_NETWORK_CLIENT:-curl}"
  else
    reina_ops_doctor_record "network:client" "degraded" "curl no disponible; modo offline/cache"
  fi

  return 0
}

function reina_ops_doctor_checks_json() {
  emulate -L zsh
  local record name check_status detail
  local first=1

  print -rn -- "["

  for record in "${REINA_DOCTOR_CHECKS[@]}"; do
    IFS='|' read -r name check_status detail <<< "$record"

    if (( first )); then
      first=0
    else
      print -rn -- ","
    fi

    print -rn -- "{"
    print -rn -- "\"name\":\"$(reina_json_escape "$name")\","
    print -rn -- "\"status\":\"$(reina_json_escape "$check_status")\","
    print -rn -- "\"detail\":\"$(reina_json_escape "$detail")\""
    print -rn -- "}"
  done

  print -rn -- "]"
}

function reina_ops_doctor_print_human() {
  emulate -L zsh
  local record name check_status detail

  print -- "Doctor:"
  print -- "  status: $REINA_DOCTOR_STATUS"

  for record in "${REINA_DOCTOR_CHECKS[@]}"; do
    IFS='|' read -r name check_status detail <<< "$record"
    print -- "  [$check_status] $name — $detail"
  done
}

function reina_ops_doctor_print_json() {
  emulate -L zsh

  print -rn -- "{"
  print -rn -- "\"ok\":$(reina_error_json_bool "$([[ "$REINA_DOCTOR_STATUS" != "failed" ]] && print 1 || print 0)"),"
  print -rn -- "\"degraded\":$(reina_error_json_bool "$([[ "$REINA_DOCTOR_STATUS" == "degraded" ]] && print 1 || print 0)"),"
  print -rn -- "\"status\":\"$(reina_error_json_escape "$REINA_DOCTOR_STATUS")\","
  print -rn -- "\"command\":\"doctor\","
  print -rn -- "\"checks\":$(reina_ops_doctor_checks_json)"
  print -- "}"
}

function reina_ops_history_entries() {
  emulate -L zsh
  setopt local_options extended_glob null_glob
  local slug="${1:-}"
  local history_dir
  local -a entries

  history_dir="$(reina_storage_category_dir history "$slug" 2>/dev/null)" || return 0
  [[ -d "$history_dir" ]] || return 0

  entries=("${history_dir}"/*.txt(N))
  (( ${#entries[@]} > 0 )) && entries=("${(@On)entries}")
  printf '%s\n' "${entries[@]}"
}

function reina_ops_history_collect_entries() {
  emulate -L zsh
  typeset -ga REINA_OPS_HISTORY_ENTRIES
  local slug="${1:-}"
  local history_dir entry_path
  local -a entries

  history_dir="$(reina_storage_category_dir history "$slug" 2>/dev/null)" || return 0
  [[ -d "$history_dir" ]] || return 0

  entries=()
  while IFS= read -r entry_path; do
    [[ -z "$entry_path" ]] && continue
    [[ "$entry_path" != /* ]] && entry_path="${history_dir}/${entry_path}"
    [[ -f "$entry_path" && "${entry_path:e}" == txt ]] && entries+=("$entry_path")
  done < <(/bin/ls -1 "$history_dir" 2>/dev/null)

  (( ${#entries[@]} > 0 )) && entries=("${(@On)entries}")
  REINA_OPS_HISTORY_ENTRIES=("${entries[@]}")
}

function reina_ops_history_print_human() {
  emulate -L zsh
  local slug="${1:-}"
  local entry_path body index=0
  local -a entries

  typeset -ga REINA_OPS_HISTORY_ENTRIES
  REINA_OPS_HISTORY_ENTRIES=()
  reina_ops_history_collect_entries "$slug"
  entries=("${REINA_OPS_HISTORY_ENTRIES[@]}")

  print -- "History:"
  print -- "  preset: $slug"

  for entry_path in "${entries[@]}"; do
    [[ -f "$entry_path" ]] || continue
    body="$(<"$entry_path")"
    index=$(( index + 1 ))
    print -- ""
    print -- "  [$index] ${entry_path:t:r}"
    print -- "$body" | sed 's/^/    /'
  done

  if (( index == 0 )); then
    print -- ""
    print -- "  (sin entradas)"
  fi
}

function reina_ops_history_print_json() {
  emulate -L zsh
  local slug="${1:-}"
  local entry_path body key
  local first=1
  local -a entries

  typeset -ga REINA_OPS_HISTORY_ENTRIES
  REINA_OPS_HISTORY_ENTRIES=()
  reina_ops_history_collect_entries "$slug"
  entries=("${REINA_OPS_HISTORY_ENTRIES[@]}")

  print -rn -- "{"
  print -rn -- "\"preset\":\"$(reina_json_escape "$slug")\","
  print -rn -- "\"entries\":["

  for entry_path in "${entries[@]}"; do
    [[ -f "$entry_path" ]] || continue
    body="$(<"$entry_path")"
    key="${entry_path:t:r}"

    if (( first )); then
      first=0
    else
      print -rn -- ","
    fi

    print -rn -- "{"
    print -rn -- "\"key\":\"$(reina_json_escape "$key")\","
    print -rn -- "\"path\":\"$(reina_json_escape "$entry_path")\","
    print -rn -- "\"body\":\"$(reina_json_escape "$body")\""
    print -rn -- "}"
  done

  print -rn -- "]"
  print -- "}"
}

function reina_ops_snapshot_entries() {
  emulate -L zsh
  setopt local_options extended_glob null_glob
  local slug="${1:-}"
  local snap_dir
  local -a entries

  snap_dir="$(reina_storage_category_dir snapshots "$slug" 2>/dev/null)" || return 0
  [[ -d "$snap_dir" ]] || return 0

  entries=("${snap_dir}"/*.txt(N))
  (( ${#entries[@]} > 0 )) && entries=("${(@On)entries}")
  printf '%s\n' "${entries[@]}"
}

function reina_ops_snapshot_latest_path() {
  emulate -L zsh
  local slug="${1:-}"
  local -a entries

  typeset -ga REINA_OPS_SNAPSHOT_ENTRIES
  REINA_OPS_SNAPSHOT_ENTRIES=()
  reina_ops_snapshot_collect_entries "$slug"
  entries=("${REINA_OPS_SNAPSHOT_ENTRIES[@]}")
  (( ${#entries[@]} > 0 )) || return 1

  print -- "${entries[1]}"
}

function reina_ops_snapshot_resolve_path() {
  emulate -L zsh
  local slug="${1:-}"
  local key="${2:-}"
  local snap_dir candidate

  if [[ -z "$key" ]]; then
    reina_ops_snapshot_latest_path "$slug"
    return $?
  fi

  snap_dir="$(reina_storage_category_dir snapshots "$slug")"
  candidate="${snap_dir}/${key}.txt"
  [[ -f "$candidate" ]] || candidate="${snap_dir}/$(reina_storage_sanitize_key "$key").txt"
  [[ -f "$candidate" ]] || return 1

  print -- "$candidate"
}

function reina_ops_snapshot_collect_entries() {
  emulate -L zsh
  typeset -ga REINA_OPS_SNAPSHOT_ENTRIES
  local slug="${1:-}"
  local snap_dir entry_path
  local -a entries

  snap_dir="$(reina_storage_category_dir snapshots "$slug" 2>/dev/null)" || return 0
  [[ -d "$snap_dir" ]] || return 0

  entries=()
  while IFS= read -r entry_path; do
    [[ -z "$entry_path" ]] && continue
    [[ "$entry_path" != /* ]] && entry_path="${snap_dir}/${entry_path}"
    [[ -f "$entry_path" && "${entry_path:e}" == txt ]] && entries+=("$entry_path")
  done < <(/bin/ls -1 "$snap_dir" 2>/dev/null)

  (( ${#entries[@]} > 0 )) && entries=("${(@On)entries}")
  REINA_OPS_SNAPSHOT_ENTRIES=("${entries[@]}")
}

function reina_ops_snapshot_print_list_human() {
  emulate -L zsh
  local slug="${1:-}"
  local entry_path index=0
  local -a entries

  typeset -ga REINA_OPS_SNAPSHOT_ENTRIES
  REINA_OPS_SNAPSHOT_ENTRIES=()
  reina_ops_snapshot_collect_entries "$slug"
  entries=("${REINA_OPS_SNAPSHOT_ENTRIES[@]}")

  print -- "Snapshots:"
  print -- "  preset: $slug"

  for entry_path in "${entries[@]}"; do
    [[ -f "$entry_path" ]] || continue
    index=$(( index + 1 ))
    print -- "  [$index] ${entry_path:t:r}"
  done

  if (( index == 0 )); then
    print -- "  (sin snapshots)"
  fi
}

function reina_ops_snapshot_print_list_json() {
  emulate -L zsh
  local slug="${1:-}"
  local entry_path key
  local first=1
  local -a entries

  typeset -ga REINA_OPS_SNAPSHOT_ENTRIES
  REINA_OPS_SNAPSHOT_ENTRIES=()
  reina_ops_snapshot_collect_entries "$slug"
  entries=("${REINA_OPS_SNAPSHOT_ENTRIES[@]}")

  print -rn -- "{"
  print -rn -- "\"preset\":\"$(reina_json_escape "$slug")\","
  print -rn -- "\"snapshots\":["

  for entry_path in "${entries[@]}"; do
    [[ -f "$entry_path" ]] || continue
    key="${entry_path:t:r}"

    if (( first )); then
      first=0
    else
      print -rn -- ","
    fi

    print -rn -- "{"
    print -rn -- "\"key\":\"$(reina_json_escape "$key")\","
    print -rn -- "\"path\":\"$(reina_json_escape "$entry_path")\""
    print -rn -- "}"
  done

  print -rn -- "]"
  print -- "}"
}

function reina_ops_snapshot_restore() {
  emulate -L zsh
  local slug="${1:-}"
  local key="${2:-}"
  local snapshot_path body

  snapshot_path="$(reina_ops_snapshot_resolve_path "$slug" "$key")" || {
    reina_fail ERR_STORE_NOT_FOUND "snapshot no encontrado para $slug" "storage" "slug=$slug key=${key:-latest}"
    return $?
  }

  body="$(<"$snapshot_path")"
  reina_storage_config_put profile "$slug" "$body" || return $?

  typeset -gx REINA_OPS_SNAPSHOT_RESTORED_KEY="${snapshot_path:t:r}"
  typeset -gx REINA_OPS_SNAPSHOT_RESTORED_PATH="$snapshot_path"
  return 0
}

function reina_ops_snapshot_print_restore_human() {
  emulate -L zsh
  local slug="${1:-}"

  print -- "Snapshot restore:"
  print -- "  preset:  $slug"
  print -- "  key:     ${REINA_OPS_SNAPSHOT_RESTORED_KEY:-}"
  print -- "  profile: $(reina_storage_body_path config profile "$slug")"
  print -- "  status:  ok"
}

function reina_ops_snapshot_print_restore_json() {
  emulate -L zsh
  local slug="${1:-}"

  print -rn -- "{"
  print -rn -- "\"ok\":true,"
  print -rn -- "\"command\":\"snapshot\","
  print -rn -- "\"action\":\"restore\","
  print -rn -- "\"preset\":\"$(reina_json_escape "$slug")\","
  print -rn -- "\"key\":\"$(reina_json_escape "${REINA_OPS_SNAPSHOT_RESTORED_KEY:-}")\","
  print -rn -- "\"profile_path\":\"$(reina_json_escape "$(reina_storage_body_path config profile "$slug")")\""
  print -- "}"
}

function reina_ops_prune_runtime_tmp() {
  emulate -L zsh
  setopt local_options extended_glob null_glob
  local tmp_dir="${1:-$(reina_storage_tmp_dir)}"
  local -a tmp_files

  [[ -d "$tmp_dir" ]] || return 0
  tmp_files=("${tmp_dir}"/*(N))
  (( ${#tmp_files[@]} > 0 )) && rm -rf "${tmp_files[@]}"
}

function reina_ops_prune_expired_locks() {
  emulate -L zsh
  setopt local_options extended_glob null_glob
  local locks_dir="${1:-$(reina_storage_locks_dir)}"
  local lock_dir created now age ttl=300

  [[ -d "$locks_dir" ]] || return 0

  for lock_dir in "$locks_dir"/*.lock(N/); do
    created="$(reina_storage_meta_value "$lock_dir/meta" created_epoch)"
    [[ -n "$created" && "$created" == <-> ]] || continue
    now="$(date +%s)"
    age=$(( now - created ))
    (( age > ttl )) && rm -rf "$lock_dir"
  done
}

function reina_ops_prune_cache() {
  emulate -L zsh
  local ttl="${1:-86400}"

  reina_storage_prune cache network "$ttl" || return $?
  reina_storage_prune cache presets "$ttl" || return $?
  return 0
}

function reina_ops_prune_all() {
  emulate -L zsh
  local ttl="${1:-86400}"

  reina_ops_prune_cache "$ttl" || return $?
  reina_ops_prune_runtime_tmp
  reina_ops_prune_expired_locks
  return 0
}

function reina_ops_prune_print_human() {
  emulate -L zsh
  local mode="${1:-cache}"

  print -- "Prune:"
  print -- "  mode:   $mode"
  print -- "  status: ok"
  print -- "  policy: cache_ttl=86400s; --all incluye tmp y locks vencidos"
}

function reina_ops_prune_print_json() {
  emulate -L zsh
  local mode="${1:-cache}"

  print -rn -- "{"
  print -rn -- "\"ok\":true,"
  print -rn -- "\"command\":\"prune\","
  print -rn -- "\"mode\":\"$(reina_json_escape "$mode")\","
  print -rn -- "\"cache_ttl_seconds\":86400"
  print -- "}"
}