# Consciencia de red — perfiles remotos, grafo de familia y politica offline-first.
#
# Esquema (Dia 20):
#   cache/network/preset-profile-<slug>.txt     — cuerpo remoto cacheado
#   config/presets/<slug>/remote-profile.txt    — espejo persistido en config
#   config/presets/<slug>/remote-profile-binding.txt — metadata de sincronizacion

function reina_network_consciousness_remote_endpoint() {
  emulate -L zsh
  local slug="${1:-}"
  local base="${REINA_REMOTE_PROFILE_BASE_URL:-https://example.com/reina/presets/}"

  [[ -n "$slug" ]] || return 1
  print -- "${base%/}/${slug}.profile"
}

function reina_network_consciousness_cache_key() {
  emulate -L zsh
  local slug="${1:-}"

  print -- "preset-profile-${slug}"
}

function reina_network_consciousness_remote_profile_config_path() {
  emulate -L zsh
  local slug="${1:-}"

  reina_storage_body_path config remote-profile "$slug"
}

function reina_network_consciousness_remote_profile_cache_path() {
  emulate -L zsh
  local slug="${1:-}"
  local cache_key

  cache_key="$(reina_network_consciousness_cache_key "$slug")"
  reina_network_cache_body_path "$cache_key"
}

function reina_network_consciousness_binding_get() {
  emulate -L zsh
  local slug="${1:-}"
  local key value

  typeset -gA REINA_PRESET_REMOTE_BINDING
  REINA_PRESET_REMOTE_BINDING=()

  reina_storage_config_get remote-profile-binding "$slug" "" >/dev/null 2>&1 || return 1
  [[ "${REINA_STORE_LAST_STATUS:-}" == "ok" ]] || return 1

  while IFS='=' read -r key value; do
    [[ -z "$key" ]] && continue
    REINA_PRESET_REMOTE_BINDING[$key]="$value"
  done <<< "${REINA_STORE_LAST_VALUE}"

  return 0
}

function reina_network_consciousness_recover_optional_fetch() {
  emulate -L zsh
  local slug="${1:-}"
  local endpoint="${2:-}"
  local err_code

  [[ "${REINA_RESULT_STATUS:-ok}" == "failed" ]] || return 0

  err_code="${REINA_ERROR_LAST_CODE:-ERR_NETWORK_UNAVAILABLE}"
  reina_degrade \
    "$err_code" \
    "perfil remoto opcional no disponible; cadena sonora continua" \
    "network-consciousness" \
    "slug=$slug endpoint=$endpoint" \
    "local_only"

  typeset -gx \
    REINA_RESULT_STATUS="degraded" \
    REINA_ERROR_LAST_FATAL=0 \
    REINA_ERROR_LAST_EXIT_CODE=0
}

function reina_network_consciousness_sync_remote_profile() {
  emulate -L zsh
  local slug="${1:-${REINA_PRESET_SLUG:-}}"
  local endpoint cache_key body binding origin

  typeset -gx REINA_PRESET_REMOTE_PROFILE_SOURCE="unavailable"

  [[ -n "$slug" ]] || return 0
  (( REINA_DRY_RUN )) && return 0

  endpoint="$(reina_network_consciousness_remote_endpoint "$slug")"
  cache_key="$(reina_network_consciousness_cache_key "$slug")"

  reina_network_fetch_to_cache "$endpoint" "$cache_key" || true

  case "${REINA_NETWORK_LAST_STATUS:-}:${REINA_NETWORK_LAST_SOURCE:-}" in
    ok:remote|ok:cache|degraded:cache)
      body="${REINA_NETWORK_LAST_BODY:-}"
      [[ -n "$body" ]] || {
        reina_network_consciousness_recover_optional_fetch "$slug" "$endpoint"
        return 0
      }

      origin="${REINA_NETWORK_LAST_SOURCE}"
      reina_storage_put config remote-profile "$body" "$slug" 86400 "$origin" >/dev/null 2>&1 || {
        reina_recover_last_error_as_degradation "remote_profile_mirror_skipped"
        return 0
      }

      binding="source=${origin}"$'\n'
      binding+="endpoint=${endpoint}"$'\n'
      binding+="cache_key=${cache_key}"$'\n'
      binding+="network_status=${REINA_NETWORK_LAST_STATUS:-unknown}"$'\n'
      binding+="synced_at=$(date -u '+%Y-%m-%dT%H:%M:%SZ')"$'\n'
      reina_storage_put config remote-profile-binding "$binding" "$slug" 0 "$origin" >/dev/null 2>&1 || true

      REINA_PRESET_REMOTE_PROFILE_SOURCE="$origin"
      return 0
      ;;
  esac

  reina_storage_config_get remote-profile "$slug" "" >/dev/null 2>&1
  if [[ "${REINA_STORE_LAST_STATUS:-}" == "ok" && -n "${REINA_STORE_LAST_VALUE:-}" ]]; then
    REINA_PRESET_REMOTE_PROFILE_SOURCE="local"
    if [[ "${REINA_RESULT_STATUS:-ok}" == "failed" ]]; then
      typeset -gx REINA_RESULT_STATUS="ok"
      typeset -gx REINA_ERROR_LAST_FATAL=0
      typeset -gx REINA_ERROR_LAST_EXIT_CODE=0
    fi
    return 0
  fi

  reina_network_consciousness_recover_optional_fetch "$slug" "$endpoint"
  return 0
}

function reina_network_consciousness_family_siblings() {
  emulate -L zsh
  local family="${1:-}"
  local slug="${2:-}"

  [[ -n "$family" && -f "${REINA_MANIFEST_PATH:-}" ]] || return 0

  awk -F '\t' -v family="$family" -v slug="$slug" '
    NR == 1 { next }
    $3 == family && $2 != slug {
      printf "%s\t%s\t%s\n", $2, $4, $5
    }
  ' "$REINA_MANIFEST_PATH"
}

function reina_network_consciousness_siblings_json() {
  emulate -L zsh
  local family="${1:-}"
  local slug="${2:-}"
  local record sibling_slug sibling_variant sibling_status
  local first=1

  print -rn -- "["

  while IFS=$'\t' read -r sibling_slug sibling_variant sibling_status; do
    [[ -z "$sibling_slug" ]] && continue

    if (( first )); then
      first=0
    else
      print -rn -- ","
    fi

    print -rn -- "{"
    print -rn -- "\"slug\":\"$(reina_json_escape "$sibling_slug")\","
    print -rn -- "\"variant\":\"$(reina_json_escape "$sibling_variant")\","
    print -rn -- "\"status\":\"$(reina_json_escape "$sibling_status")\""
    print -rn -- "}"
  done < <(reina_network_consciousness_family_siblings "$family" "$slug")

  print -rn -- "]"
}

function reina_network_consciousness_last_snapshot_json() {
  emulate -L zsh
  local slug="${1:-}"
  local snap_dir body_path meta_path key context origin
  local -a snapshots

  [[ -n "$slug" ]] || {
    print -rn -- "null"
    return 0
  }

  snap_dir="$(reina_storage_category_dir snapshots "$slug" 2>/dev/null)" || {
    print -rn -- "null"
    return 0
  }

  snapshots=("${snap_dir}"/*.txt(N))
  if (( ${#snapshots[@]} == 0 )); then
    print -rn -- "null"
    return 0
  fi

  snapshots=("${(@On)snapshots}")
  body_path="${snapshots[1]}"
  meta_path="${body_path:r}.meta"
  key="${body_path:t:r}"
  context="unknown"
  origin="preset"

  if [[ "$key" == *"-${slug}-"* ]]; then
    context="${key#*-${slug}-}"
  fi

  if [[ -f "$meta_path" ]]; then
    origin="$(reina_storage_meta_value "$meta_path" origin)"
    [[ -n "$origin" ]] || origin="preset"
  fi

  print -rn -- "{"
  print -rn -- "\"key\":\"$(reina_json_escape "$key")\","
  print -rn -- "\"path\":\"$(reina_json_escape "$body_path")\","
  print -rn -- "\"context\":\"$(reina_json_escape "$context")\","
  print -rn -- "\"origin\":\"$(reina_json_escape "$origin")\""
  print -rn -- "}"
}

function reina_network_consciousness_remote_profile_json() {
  emulate -L zsh
  local slug="${1:-}"
  local config_path cache_path available="false" source="unavailable" endpoint="" cache_key=""

  [[ -n "$slug" ]] || {
    print -rn -- "null"
    return 0
  }

  config_path="$(reina_network_consciousness_remote_profile_config_path "$slug" 2>/dev/null)"
  cache_path="$(reina_network_consciousness_remote_profile_cache_path "$slug" 2>/dev/null)"

  if reina_network_consciousness_binding_get "$slug"; then
    source="${REINA_PRESET_REMOTE_BINDING[source]:-unavailable}"
    endpoint="${REINA_PRESET_REMOTE_BINDING[endpoint]:-}"
    cache_key="${REINA_PRESET_REMOTE_BINDING[cache_key]:-}"
  elif [[ -n "${REINA_PRESET_REMOTE_PROFILE_SOURCE:-}" ]]; then
    source="$REINA_PRESET_REMOTE_PROFILE_SOURCE"
  fi

  if [[ -f "$config_path" || -f "$cache_path" ]]; then
    available="true"
  fi

  print -rn -- "{"
  print -rn -- "\"available\":$(reina_json_bool "$available"),"
  print -rn -- "\"source\":\"$(reina_json_escape "$source")\","
  print -rn -- "\"endpoint\":\"$(reina_json_escape "$endpoint")\","
  print -rn -- "\"cache_key\":\"$(reina_json_escape "$cache_key")\","
  print -rn -- "\"config_path\":\"$(reina_json_escape "${config_path:-}")\","
  print -rn -- "\"cache_path\":\"$(reina_json_escape "${cache_path:-}")\""
  print -rn -- "}"
}

function reina_network_consciousness_graph_json() {
  emulate -L zsh
  local slug="${1:-${REINA_PRESET_SLUG:-}}"
  local family="${2:-${REINA_PRESET_FAMILY:-}}"
  local variant="${3:-${REINA_PRESET_VARIANT:-}}"

  print -rn -- "{"
  print -rn -- "\"slug\":\"$(reina_json_escape "$slug")\","
  print -rn -- "\"family\":\"$(reina_json_escape "$family")\","
  print -rn -- "\"variant\":\"$(reina_json_escape "$variant")\","
  print -rn -- "\"siblings\":$(reina_network_consciousness_siblings_json "$family" "$slug"),"
  print -rn -- "\"remote_profile\":$(reina_network_consciousness_remote_profile_json "$slug"),"
  print -rn -- "\"last_snapshot\":$(reina_network_consciousness_last_snapshot_json "$slug")"
  print -rn -- "}"
}

function reina_network_consciousness_build_graph() {
  emulate -L zsh
  local slug="${1:-${REINA_PRESET_SLUG:-}}"

  typeset -gx REINA_PRESET_NETWORK_GRAPH_JSON
  REINA_PRESET_NETWORK_GRAPH_JSON="$(reina_network_consciousness_graph_json "$slug" "${REINA_PRESET_FAMILY:-}" "${REINA_PRESET_VARIANT:-}")"
}

function reina_network_consciousness_last_snapshot_key() {
  emulate -L zsh
  local slug="${1:-}"
  local snap_dir body_path key
  local -a snapshots

  [[ -n "$slug" ]] || return 1

  snap_dir="$(reina_storage_category_dir snapshots "$slug" 2>/dev/null)" || return 1
  snapshots=("${snap_dir}"/*.txt(N))
  (( ${#snapshots[@]} > 0 )) || return 1

  snapshots=("${(@On)snapshots}")
  body_path="${snapshots[1]}"
  key="${body_path:t:r}"
  print -- "$key"
}

function reina_network_consciousness_print_human() {
  emulate -L zsh
  local slug="${1:-${REINA_PRESET_SLUG:-}}"
  local family="${2:-${REINA_PRESET_FAMILY:-}}"
  local sibling_slug sibling_variant sibling_status snapshot_key
  local -a sibling_labels

  print -- "Network:"
  print -- "  consciousness: active"
  print -- "  family:        $family"

  sibling_labels=()
  while IFS=$'\t' read -r sibling_slug sibling_variant sibling_status; do
    [[ -z "$sibling_slug" ]] && continue
    sibling_labels+=("${sibling_slug}(${sibling_variant})")
  done < <(reina_network_consciousness_family_siblings "$family" "$slug")

  if (( ${#sibling_labels[@]} > 0 )); then
    print -- "  siblings:      ${(j:, :)sibling_labels}"
  else
    print -- "  siblings:      -"
  fi

  if reina_network_consciousness_binding_get "$slug"; then
    print -- "  remote_source: ${REINA_PRESET_REMOTE_BINDING[source]:-unavailable}"
    print -- "  remote_status: ${REINA_PRESET_REMOTE_BINDING[network_status]:-unknown}"
  elif [[ -n "${REINA_PRESET_REMOTE_PROFILE_SOURCE:-}" ]]; then
    print -- "  remote_source: $REINA_PRESET_REMOTE_PROFILE_SOURCE"
    print -- "  remote_status: -"
  else
    reina_storage_config_get remote-profile "$slug" "" >/dev/null 2>&1
    if [[ "${REINA_STORE_LAST_STATUS:-}" == "ok" ]]; then
      print -- "  remote_source: local"
      print -- "  remote_status: -"
    else
      print -- "  remote_source: unavailable"
      print -- "  remote_status: -"
    fi
  fi

  if snapshot_key="$(reina_network_consciousness_last_snapshot_key "$slug" 2>/dev/null)"; then
    print -- "  last_snapshot: $snapshot_key"
  else
    print -- "  last_snapshot: -"
  fi
}

function reina_network_consciousness_info_json() {
  emulate -L zsh

  print -rn -- "{"
  print -rn -- "\"preset\":$(reina_preset_json),"
  print -rn -- "\"network_graph\":$(reina_network_consciousness_graph_json "${REINA_PRESET_SLUG:-}" "${REINA_PRESET_FAMILY:-}" "${REINA_PRESET_VARIANT:-}")"
  print -rn -- "}"
}

function reina_network_consciousness_graph_print_human() {
  emulate -L zsh
  local slug="${1:-${REINA_PRESET_SLUG:-}}"

  reina_network_consciousness_build_graph "$slug"

  print -- "Graph:"
  print -- "  slug:    $REINA_PRESET_SLUG"
  print -- "  family:  $REINA_PRESET_FAMILY"
  print -- "  variant: $REINA_PRESET_VARIANT"
  print -- ""
  reina_network_consciousness_print_human "$slug" "${REINA_PRESET_FAMILY:-}" 
}

function reina_network_consciousness_graph_print_json() {
  emulate -L zsh
  local slug="${1:-${REINA_PRESET_SLUG:-}}"

  reina_network_consciousness_build_graph "$slug"
  print -- "$REINA_PRESET_NETWORK_GRAPH_JSON"
}