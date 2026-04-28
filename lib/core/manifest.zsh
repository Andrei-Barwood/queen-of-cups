function reina_manifest_expected_header() {
  print -r -- $'display_name\tslug\tfamily\tvariant\tstatus\tpriority\taliases\tnotes'
}

function reina_manifest_record_to_preset() {
  emulate -L zsh
  local record="${1:-}"

  IFS=$'\t' read -r \
    REINA_PRESET_DISPLAY_NAME \
    REINA_PRESET_SLUG \
    REINA_PRESET_FAMILY \
    REINA_PRESET_VARIANT \
    REINA_PRESET_STATUS \
    REINA_PRESET_PRIORITY \
    REINA_PRESET_ALIASES \
    REINA_PRESET_NOTES <<< "$record"

  if [[ -z "${REINA_PRESET_SLUG:-}" ]]; then
    reina_fail ERR_MANIFEST_INVALID "no se pudo cargar el preset desde el manifiesto"
    return $?
  fi

  typeset -gx \
    REINA_PRESET_DISPLAY_NAME \
    REINA_PRESET_SLUG \
    REINA_PRESET_FAMILY \
    REINA_PRESET_VARIANT \
    REINA_PRESET_STATUS \
    REINA_PRESET_PRIORITY \
    REINA_PRESET_ALIASES \
    REINA_PRESET_NOTES
}

function reina_preset_json() {
  emulate -L zsh

  print -rn -- "{"
  print -rn -- "\"display_name\":\"$(reina_json_escape "$REINA_PRESET_DISPLAY_NAME")\","
  print -rn -- "\"slug\":\"$(reina_json_escape "$REINA_PRESET_SLUG")\","
  print -rn -- "\"family\":\"$(reina_json_escape "$REINA_PRESET_FAMILY")\","
  print -rn -- "\"variant\":\"$(reina_json_escape "$REINA_PRESET_VARIANT")\","
  print -rn -- "\"status\":\"$(reina_json_escape "$REINA_PRESET_STATUS")\","
  print -rn -- "\"priority\":\"$(reina_json_escape "$REINA_PRESET_PRIORITY")\","
  print -rn -- "\"aliases\":$(reina_json_aliases "$REINA_PRESET_ALIASES"),"
  print -rn -- "\"notes\":\"$(reina_json_escape "$REINA_PRESET_NOTES")\""
  print -rn -- "}"
}

function reina_manifest_record_to_json() {
  emulate -L zsh
  local record="${1:-}"

  reina_manifest_record_to_preset "$record" || return $?
  reina_preset_json
}

function reina_manifest_validate() {
  emulate -L zsh

  if [[ ! -f "$REINA_MANIFEST_PATH" ]]; then
    reina_fail ERR_MANIFEST_MISSING "manifest no encontrado en $REINA_MANIFEST_PATH"
    return $?
  fi

  local header expected reason
  header="$(head -n 1 "$REINA_MANIFEST_PATH")"
  expected="$(reina_manifest_expected_header)"

  if [[ "$header" != "$expected" ]]; then
    reina_fail ERR_MANIFEST_INVALID "header invalido en presets/manifest.tsv"
    return $?
  fi

  if ! reason="$(
    awk -F '\t' '
      NR == 1 { next }
      NF != 8 {
        printf("fila %d: se esperaban 8 columnas y llegaron %d\n", NR, NF) > "/dev/stderr"
        exit 1
      }
      $2 == "" {
        printf("fila %d: slug vacio\n", NR) > "/dev/stderr"
        exit 1
      }
      seen[$2]++ > 0 {
        printf("slug duplicado: %s\n", $2) > "/dev/stderr"
        exit 1
      }
    ' "$REINA_MANIFEST_PATH" 2>&1 >/dev/null
  )"; then
    reina_fail ERR_MANIFEST_INVALID "${reason}"
    return $?
  fi

  return 0
}

function reina_normalize_name() {
  emulate -L zsh
  local value="${1:-}"

  print -rn -- "$value" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9 _-]+//g; s/[ _]+/-/g; s/-+/-/g; s/^-//; s/-$//'
}

function reina_resolve_preset_to_global() {
  emulate -L zsh
  local needle="${1:-}"
  local normalized matches match_count

  typeset -gx REINA_RESOLVED_PRESET_RECORD=""

  [[ -n "$needle" ]] || return 1
  reina_manifest_validate || return $?

  normalized="$(reina_normalize_name "$needle")"
  matches="$(
    awk -F '\t' -v needle="$normalized" '
      function norm(s) {
        s = tolower(s)
        gsub(/[^a-z0-9 _-]+/, "", s)
        gsub(/[ _]+/, "-", s)
        gsub(/-+/, "-", s)
        gsub(/^-/, "", s)
        gsub(/-$/, "", s)
        return s
      }

      NR == 1 { next }
      {
        alias_count = split($7, alias_list, /\|/)

        if (needle == norm($1) || needle == norm($2)) {
          print $0
          exit
        }

        for (i = 1; i <= alias_count; i++) {
          alias_value = alias_list[i]
          if (alias_value != "" && alias_value != "-" && needle == norm(alias_value)) {
            print $0
            exit
          }
        }
      }
    ' "$REINA_MANIFEST_PATH"
  )"

  [[ -n "$matches" ]] || return 1

  match_count="$(print -r -- "$matches" | awk 'END { print NR }')"
  if (( match_count > 1 )); then
    reina_fail ERR_ALIAS_AMBIGUOUS "identificador ambiguo: $needle"
    return $?
  fi

  REINA_RESOLVED_PRESET_RECORD="$matches"
  return 0
}

function reina_resolve_preset() {
  emulate -L zsh

  reina_resolve_preset_to_global "$@" || return $?
  print -r -- "$REINA_RESOLVED_PRESET_RECORD"
}

function reina_manifest_find_by_identifier() {
  reina_resolve_preset "$@"
}

function reina_manifest_print_table() {
  emulate -L zsh

  awk -F '\t' '
    NR == 1 { next }
    {
      printf "%-30s %-30s %-30s %-11s %s\n", $1, $2, $3, $5, $6
    }
  ' "$REINA_MANIFEST_PATH"
}

function reina_manifest_print_json() {
  emulate -L zsh
  local record first=1

  print -- "["
  while IFS= read -r record; do
    [[ -z "$record" ]] && continue

    if (( first )); then
      first=0
    else
      print -- ","
    fi

    print -n -- "  "
    reina_manifest_record_to_json "$record"
  done < <(sed '1d' "$REINA_MANIFEST_PATH")
  print -- ""
  print -- "]"
}
