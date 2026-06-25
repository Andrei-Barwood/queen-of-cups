#!/usr/bin/env zsh

setopt NO_UNSET PIPE_FAIL

typeset -r PROJECT_ROOT="${0:A:h:h}"
typeset -r REINA_BIN="${PROJECT_ROOT}/bin/reina"
typeset -r TMP_DIR="$(mktemp -d)"
typeset -r STUB_CURL="${TMP_DIR}/curl-stub"

function cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

cat > "$STUB_CURL" <<'EOF'
#!/usr/bin/env zsh

body_file=""
headers_file=""
endpoint=""

while (( $# > 0 )); do
  case "$1" in
    -o)
      shift
      body_file="$1"
      ;;
    -D)
      shift
      headers_file="$1"
      ;;
    http://*|https://*)
      endpoint="$1"
      ;;
  esac
  shift
done

[[ -n "$headers_file" ]] && print -- "HTTP/1.1 200 OK" > "$headers_file"

slug="${endpoint:t}"
slug="${slug%.profile}"

[[ -n "$body_file" ]] && cat > "$body_file" <<BODY
remote_profile_source=network
slug=${slug}
family=remote-sync
synced=true
BODY

print -rn -- "200 0.042"
exit 0
EOF

chmod +x "$STUB_CURL"

typeset -gx REINA_CONFIG_ROOT="${TMP_DIR}/config-root"
typeset -gx REINA_CACHE_ROOT="${TMP_DIR}/cache-root"
typeset -gx REINA_STATE_ROOT="${TMP_DIR}/state-root"
typeset -gx REINA_REMOTE_PROFILE_BASE_URL="https://example.test/reina/presets"
typeset -gx REINA_NETWORK_CURL_BIN="$STUB_CURL"
typeset -gx REINA_NETWORK_TIMEOUT=1
typeset -gx REINA_NETWORK_RETRIES=0
typeset -gx REINA_NETWORK_BACKOFF_MS=1

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

help_output="$("$REINA_BIN" help)"
assert_contains "$help_output" "reina graph <preset>" "help expone graph" || exit 1

run_output="$("$REINA_BIN" run bass-in-the-desert 2>/dev/null)"
assert_contains "$run_output" "result_status: ok" "run con consciencia de red termina ok" || exit 1
assert_contains "$run_output" "Network:" "run expone seccion network" || exit 1
assert_contains "$run_output" "siblings:" "run expone hermanos de familia" || exit 1
assert_contains "$run_output" "last_snapshot:" "run expone ultimo snapshot" || exit 1

remote_config_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/bass-in-the-desert/remote-profile.txt"
remote_binding_path="${REINA_CONFIG_ROOT}/reina-de-copas/presets/bass-in-the-desert/remote-profile-binding.txt"
remote_cache_path="${REINA_CACHE_ROOT}/reina-de-copas/network/preset-profile-bass-in-the-desert.txt"

assert_file "$remote_config_path" "sync remoto crea remote-profile.txt en config" || exit 1
assert_file "$remote_binding_path" "sync remoto crea remote-profile-binding.txt" || exit 1
assert_file "$remote_cache_path" "sync remoto cachea perfil en network" || exit 1

remote_profile="$(<"$remote_config_path")"
assert_contains "$remote_profile" "remote_profile_source=network" "perfil remoto contiene metadata" || exit 1
assert_contains "$remote_profile" "slug=bass-in-the-desert" "perfil remoto conserva slug" || exit 1

run_json="$("$REINA_BIN" --json run bass-in-the-desert 2>/dev/null)"
assert_contains "$run_json" "\"network_graph\":" "run --json expone network_graph" || exit 1
assert_contains "$run_json" "\"family\":\"bass\"" "network_graph incluye familia" || exit 1
assert_contains "$run_json" "\"siblings\":" "network_graph incluye siblings" || exit 1
assert_contains "$run_json" "\"last_snapshot\":" "network_graph incluye last_snapshot" || exit 1
assert_contains "$run_json" "\"remote_profile\":" "network_graph incluye remote_profile" || exit 1
assert_contains "$run_json" "\"source\":\"remote\"" "perfil remoto reporta source remote" || exit 1

offline_json="$("$REINA_BIN" --offline --json run bass-in-the-desert 2>/dev/null)"
assert_contains "$offline_json" "\"ok\":true" "offline mantiene cadena sonora" || exit 1
assert_contains "$offline_json" "\"source\":\"cache\"" "offline degrada a cache" || exit 1
assert_contains "$offline_json" "ERR_NETWORK_OFFLINE" "offline serializa degradacion" || exit 1

info_output="$("$REINA_BIN" info bass-in-the-desert)"
assert_contains "$info_output" "Network:" "info expone seccion network" || exit 1
assert_contains "$info_output" "family:        bass" "info reporta familia en red" || exit 1
assert_contains "$info_output" "nice-bass" "info lista hermanos de familia bass" || exit 1

info_json="$("$REINA_BIN" --json info bass-in-the-desert 2>/dev/null)"
assert_contains "$info_json" "\"network_graph\":" "info --json expone network_graph" || exit 1
assert_contains "$info_json" "\"slug\":\"nice-bass\"" "info graph incluye hermanos" || exit 1

graph_output="$("$REINA_BIN" graph bass-in-the-desert)"
assert_contains "$graph_output" "Graph:" "graph imprime encabezado" || exit 1
assert_contains "$graph_output" "crunchy-bass" "graph lista hermanos bass" || exit 1

graph_json="$("$REINA_BIN" --json graph bass-in-the-desert 2>/dev/null)"
assert_contains "$graph_json" "\"slug\":\"bass-in-the-desert\"" "graph --json ancla slug" || exit 1
assert_contains "$graph_json" "\"variant\":\"foundational\"" "graph --json expone variant" || exit 1

print -- "network consciousness tests passed"