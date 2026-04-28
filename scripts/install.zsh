#!/usr/bin/env zsh

setopt NO_UNSET PIPE_FAIL

function usage() {
  cat <<'EOF'
Uso:
  scripts/install.zsh [--prefix DIR] [--dest-root DIR] [--force] [--dry-run]

Opciones:
  --prefix DIR     raiz de instalacion; default: $HOME/.local
  --dest-root DIR  destino del arbol del proyecto; default: <prefix>/lib/reina-de-copas
  --force          reemplaza un bin/reina existente aunque no sea symlink esperado
  --dry-run        muestra acciones sin escribir
EOF
}

function fail() {
  print -u2 -- "install: error: $*"
  return 1
}

typeset -r SOURCE_ROOT="${0:A:h:h}"
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
typeset -r TMP_ROOT="${dest_root}.tmp.$$"

case "$dest_root" in
  ""|"/"|"$HOME"|"$prefix")
    fail "dest-root inseguro: $dest_root"
    exit 2
    ;;
esac

if [[ -e "$LINK_PATH" && ! -L "$LINK_PATH" && "$force" != "1" ]]; then
  fail "$LINK_PATH ya existe y no es symlink; usa --force para reemplazar"
  exit 6
fi

print -- "install: source=$SOURCE_ROOT"
print -- "install: dest=$dest_root"
print -- "install: bin=$LINK_PATH"

if (( dry_run )); then
  exit 0
fi

rm -rf "$TMP_ROOT" || exit 6
mkdir -p "$TMP_ROOT" "$BIN_DIR" || exit 6

cp -R "$SOURCE_ROOT/bin" "$TMP_ROOT/bin" || exit 6
cp -R "$SOURCE_ROOT/lib" "$TMP_ROOT/lib" || exit 6
cp -R "$SOURCE_ROOT/presets" "$TMP_ROOT/presets" || exit 6
cp -R "$SOURCE_ROOT/docs" "$TMP_ROOT/docs" || exit 6
cp "$SOURCE_ROOT/README.md" "$TMP_ROOT/README.md" || exit 6
cp "$SOURCE_ROOT/VERSION" "$TMP_ROOT/VERSION" || exit 6

rm -rf "$dest_root" || exit 6
mv "$TMP_ROOT" "$dest_root" || exit 6
chmod +x "$dest_root/bin/reina" || exit 6
ln -sfn "$dest_root/bin/reina" "$LINK_PATH" || exit 6

print -- "install: listo"
print -- "install: agrega $BIN_DIR a PATH si todavia no esta disponible"
