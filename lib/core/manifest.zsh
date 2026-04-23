function reina_manifest_expected_header() {
  print -r -- $'display_name\tslug\tfamily\tvariant\tstatus\tpriority\taliases\tnotes'
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

function reina_manifest_find_by_identifier() {
  emulate -L zsh
  local needle="${1:-}"
  local normalized record

  [[ -n "$needle" ]] || return 1
  reina_manifest_validate >/dev/null || return $?

  normalized="$(reina_normalize_name "$needle")"
  record="$(
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

  [[ -n "$record" ]] || return 1
  print -r -- "$record"
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
