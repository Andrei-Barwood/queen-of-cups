function reina_json_escape() {
  emulate -L zsh
  local value="${1:-}"

  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  value="${value//$'\r'/\\r}"
  value="${value//$'\t'/\\t}"

  print -rn -- "$value"
}

function reina_json_bool() {
  emulate -L zsh

  if [[ "${1:-0}" == "1" ]]; then
    print -- "true"
  else
    print -- "false"
  fi
}

function reina_json_aliases() {
  emulate -L zsh
  local aliases="${1:-}"
  local -a alias_list
  local alias_value
  local first=1

  if [[ -z "$aliases" || "$aliases" == "-" ]]; then
    print -rn -- "[]"
    return 0
  fi

  alias_list=("${(@ps:|:)aliases}")
  print -rn -- "["

  for alias_value in "${alias_list[@]}"; do
    [[ -z "$alias_value" || "$alias_value" == "-" ]] && continue

    if (( first )); then
      first=0
    else
      print -rn -- ","
    fi

    print -rn -- "\"$(reina_json_escape "$alias_value")\""
  done

  print -rn -- "]"
}
