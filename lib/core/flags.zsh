function reina_flags_reset() {
  emulate -L zsh

  typeset -gx REINA_DEBUG=0
  typeset -gx REINA_OFFLINE=0
  typeset -gx REINA_QUIET=0
  typeset -gx REINA_JSON=0
  typeset -gx REINA_DRY_RUN=0
  typeset -ga REINA_POSITIONAL_ARGS
  REINA_POSITIONAL_ARGS=()
}

function reina_parse_global_flags() {
  emulate -L zsh
  reina_flags_reset

  while (( $# > 0 )); do
    case "$1" in
      --debug)
        REINA_DEBUG=1
        ;;
      --offline)
        REINA_OFFLINE=1
        ;;
      --quiet)
        REINA_QUIET=1
        ;;
      --json)
        REINA_JSON=1
        ;;
      --dry-run)
        REINA_DRY_RUN=1
        ;;
      --version)
        REINA_POSITIONAL_ARGS+=("version")
        ;;
      --)
        shift
        REINA_POSITIONAL_ARGS+=("$@")
        break
        ;;
      --*)
        reina_fail ERR_USAGE "flag global no soportada: $1"
        return $?
        ;;
      *)
        REINA_POSITIONAL_ARGS+=("$1")
        ;;
    esac

    shift
  done

  return 0
}

function reina_flags_human_summary() {
  emulate -L zsh

  print -- "debug=$(reina_json_bool "$REINA_DEBUG") offline=$(reina_json_bool "$REINA_OFFLINE") quiet=$(reina_json_bool "$REINA_QUIET") json=$(reina_json_bool "$REINA_JSON") dry_run=$(reina_json_bool "$REINA_DRY_RUN")"
}

function reina_flags_json() {
  emulate -L zsh

  print -rn -- "{"
  print -rn -- "\"debug\":$(reina_json_bool "$REINA_DEBUG"),"
  print -rn -- "\"offline\":$(reina_json_bool "$REINA_OFFLINE"),"
  print -rn -- "\"quiet\":$(reina_json_bool "$REINA_QUIET"),"
  print -rn -- "\"json\":$(reina_json_bool "$REINA_JSON"),"
  print -rn -- "\"dry_run\":$(reina_json_bool "$REINA_DRY_RUN")"
  print -rn -- "}"
}
