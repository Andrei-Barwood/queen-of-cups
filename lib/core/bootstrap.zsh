function reina_bootstrap() {
  emulate -L zsh
  setopt NO_UNSET PIPE_FAIL

  autoload -Uz is-at-least
  if ! is-at-least 5.4; then
    reina_fail ERR_VERSION_UNSUPPORTED "Reina de Copas requiere zsh 5.4 o superior"
    return $?
  fi

  typeset -gx REINA_MANIFEST_PATH="${REINA_PROJECT_ROOT}/presets/manifest.tsv"
  typeset -gx REINA_ALIASES_PATH="${REINA_PROJECT_ROOT}/presets/aliases.tsv"
  typeset -gx REINA_RUNTIME_MODE="${REINA_RUNTIME_MODE:-xdg}"

  return 0
}
