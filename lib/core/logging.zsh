function log_info() {
  emulate -L zsh
  (( ${REINA_QUIET:-0} )) && return 0

  print -u2 -- "reina: info: $*"
}

function log_warn() {
  emulate -L zsh
  (( ${REINA_QUIET:-0} )) && return 0

  print -u2 -- "reina: warn: $*"
}

function log_error() {
  emulate -L zsh

  print -u2 -- "reina: error: $*"
}

function log_debug() {
  emulate -L zsh
  (( ${REINA_DEBUG:-0} )) || return 0

  print -u2 -- "reina: debug: $*"
}
