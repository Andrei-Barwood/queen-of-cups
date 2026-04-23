function reina_network_mode() {
  emulate -L zsh

  if [[ "${REINA_OFFLINE:-0}" == "1" ]]; then
    print -- "offline"
  else
    print -- "online"
  fi
}

function reina_network_check() {
  emulate -L zsh

  [[ "${REINA_OFFLINE:-0}" == "1" ]] && return 1
  return 0
}
