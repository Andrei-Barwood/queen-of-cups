function reina_error_code() {
  emulate -L zsh

  case "${1:-ERR_INTERNAL}" in
    ERR_USAGE|ERR_ARGUMENT_MISSING|ERR_COMMAND_INVALID|ERR_COMMAND_NOT_IMPLEMENTED)
      print -- 2
      ;;
    ERR_PRESET_NOT_FOUND|ERR_ALIAS_AMBIGUOUS)
      print -- 3
      ;;
    ERR_MANIFEST_MISSING|ERR_MANIFEST_INVALID)
      print -- 4
      ;;
    ERR_VERSION_UNSUPPORTED|ERR_NETWORK_UNAVAILABLE|ERR_DEPENDENCY_MISSING)
      print -- 5
      ;;
    ERR_STORAGE_FAILURE)
      print -- 6
      ;;
    *)
      print -- 1
      ;;
  esac
}

function reina_error_message() {
  emulate -L zsh

  case "${1:-ERR_INTERNAL}" in
    ERR_USAGE)
      print -- "uso invalido"
      ;;
    ERR_ARGUMENT_MISSING)
      print -- "falta un argumento requerido"
      ;;
    ERR_COMMAND_INVALID)
      print -- "comando invalido"
      ;;
    ERR_COMMAND_NOT_IMPLEMENTED)
      print -- "comando reconocido pero aun no implementado"
      ;;
    ERR_PRESET_NOT_FOUND)
      print -- "preset no encontrado"
      ;;
    ERR_ALIAS_AMBIGUOUS)
      print -- "alias ambiguo"
      ;;
    ERR_MANIFEST_MISSING)
      print -- "manifest no encontrado"
      ;;
    ERR_MANIFEST_INVALID)
      print -- "manifest invalido"
      ;;
    ERR_VERSION_UNSUPPORTED)
      print -- "version de zsh no soportada"
      ;;
    ERR_NETWORK_UNAVAILABLE)
      print -- "servicio de red no disponible"
      ;;
    ERR_DEPENDENCY_MISSING)
      print -- "dependencia faltante"
      ;;
    ERR_STORAGE_FAILURE)
      print -- "fallo de almacenamiento"
      ;;
    *)
      print -- "fallo interno inesperado"
      ;;
  esac
}

function reina_fail() {
  emulate -L zsh
  local key="${1:-ERR_INTERNAL}"
  local message="${2:-$(reina_error_message "$key")}"

  if whence -w log_error >/dev/null 2>&1; then
    log_error "${message} (${key})"
  else
    print -u2 -- "reina: error: ${message} (${key})"
  fi

  return "$(reina_error_code "$key")"
}
