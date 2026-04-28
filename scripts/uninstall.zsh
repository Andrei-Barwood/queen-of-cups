#!/usr/bin/env zsh

setopt NO_UNSET PIPE_FAIL

function usage() {
  cat <<'EOF'
Uso:
  scripts/uninstall.zsh [--prefix DIR] [--dest-root DIR] [--force] [--dry-run]

Opciones:
  --prefix DIR     raiz de instalacion; default: $HOME/.local
  --dest-root DIR  arbol instalado; default: <prefix>/lib/reina-de-copas
  --force          remueve bin/reina aunque no apunte al destino esperado
  --dry-run        muestra acciones sin borrar
EOF
}

function fail() {
  print -u2 -- "uninstall: error: $*"
  return 1
}

typeset -r APP_NAME="reina-de-copas"
prefix="${PREFIX:-$HOME/.local}"
dest_root=""
force=0
dry_run=0

while (( $# > 0 )); do
  case "$1" in
    --prefix)
      shift
      [[ $# -gt 0 ]] || fail "falta valor para --prefix" || exit 2
      prefix="$1"
      ;;
    --dest-root)
      shift
      [[ $# -gt 0 ]] || fail "falta valor para --dest-root" || exit 2
      dest_root="$1"
      ;;
    --force)
      force=1
      ;;
    --dry-run)
      dry_run=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "argumento no soportado: $1"
      exit 2
      ;;
  esac

  shift
done

typeset -r BIN_DIR="${prefix}/bin"
dest_root="${dest_root:-${prefix}/lib/${APP_NAME}}"
typeset -r LINK_PATH="${BIN_DIR}/reina"
typeset -r EXPECTED_TARGET="${dest_root}/bin/reina"

case "$dest_root" in
  ""|"/"|"$HOME"|"$prefix")
    fail "dest-root inseguro: $dest_root"
    exit 2
    ;;
esac

print -- "uninstall: dest=$dest_root"
print -- "uninstall: bin=$LINK_PATH"

if (( dry_run )); then
  exit 0
fi

if [[ -L "$LINK_PATH" ]]; then
  link_target="$(readlink "$LINK_PATH")"
  if [[ "$link_target" == "$EXPECTED_TARGET" || "$force" == "1" ]]; then
    rm -f "$LINK_PATH" || exit 6
  else
    fail "$LINK_PATH apunta a $link_target; usa --force si quieres removerlo"
    exit 6
  fi
elif [[ -e "$LINK_PATH" && "$force" == "1" ]]; then
  rm -f "$LINK_PATH" || exit 6
elif [[ -e "$LINK_PATH" ]]; then
  fail "$LINK_PATH existe y no es symlink; usa --force para removerlo"
  exit 6
fi

rm -rf "$dest_root" || exit 6
print -- "uninstall: listo"
