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
    ERR_VERSION_UNSUPPORTED|ERR_NETWORK_UNAVAILABLE|ERR_DEPENDENCY_MISSING|ERR_NETWORK_OFFLINE|ERR_NETWORK_TIMEOUT|ERR_NETWORK_UNREACHABLE|ERR_NETWORK_HTTP|ERR_NETWORK_EMPTY|ERR_NETWORK_INVALID_RESPONSE|ERR_NETWORK_DEPENDENCY_MISSING)
      print -- 5
      ;;
    ERR_STORAGE_FAILURE|ERR_STORE_INIT|ERR_STORE_NOT_FOUND|ERR_STORE_CORRUPT|ERR_STORE_WRITE|ERR_STORE_READ|ERR_STORE_PRUNE|ERR_STORE_LOCKED|ERR_STORE_RUNTIME_INVALID)
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
    ERR_NETWORK_OFFLINE)
      print -- "network desactivado por modo offline"
      ;;
    ERR_NETWORK_TIMEOUT)
      print -- "timeout de red"
      ;;
    ERR_NETWORK_UNREACHABLE)
      print -- "endpoint de red inaccesible"
      ;;
    ERR_NETWORK_HTTP)
      print -- "respuesta HTTP no exitosa"
      ;;
    ERR_NETWORK_EMPTY)
      print -- "respuesta de red vacia"
      ;;
    ERR_NETWORK_INVALID_RESPONSE)
      print -- "respuesta de red invalida"
      ;;
    ERR_NETWORK_DEPENDENCY_MISSING)
      print -- "dependencia de red faltante"
      ;;
    ERR_DEPENDENCY_MISSING)
      print -- "dependencia faltante"
      ;;
    ERR_STORAGE_FAILURE)
      print -- "fallo de almacenamiento"
      ;;
    ERR_STORE_INIT)
      print -- "no se pudo inicializar storage"
      ;;
    ERR_STORE_NOT_FOUND)
      print -- "entrada de storage no encontrada"
      ;;
    ERR_STORE_CORRUPT)
      print -- "entrada de storage corrupta"
      ;;
    ERR_STORE_WRITE)
      print -- "no se pudo escribir storage"
      ;;
    ERR_STORE_READ)
      print -- "no se pudo leer storage"
      ;;
    ERR_STORE_PRUNE)
      print -- "no se pudo limpiar storage"
      ;;
    ERR_STORE_LOCKED)
      print -- "storage bloqueado"
      ;;
    ERR_STORE_RUNTIME_INVALID)
      print -- "runtime de storage invalido"
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
