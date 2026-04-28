# Distribucion

Reina de Copas se distribuye como un arbol shell-first. `bin/reina` no se copia solo: necesita `lib/`, `presets/` y `VERSION` a su lado para resolver el manifiesto y cargar servicios compartidos.

## Requisitos

- `zsh >= 5.4`
- helpers base de Unix ya documentados en `docs/architecture.md`
- `curl` solo para operaciones de red; `--offline` permite uso base sin red

## Instalacion local

```sh
zsh scripts/install.zsh --prefix "$HOME/.local"
```

Esto instala:

- arbol de aplicacion: `$HOME/.local/lib/reina-de-copas`
- comando: `$HOME/.local/bin/reina`

Si `$HOME/.local/bin` no esta en `PATH`, agregalo desde tu shell profile.

Tambien se puede usar `make`:

```sh
make install PREFIX="$HOME/.local"
```

## Desinstalacion

```sh
zsh scripts/uninstall.zsh --prefix "$HOME/.local"
```

o:

```sh
make uninstall PREFIX="$HOME/.local"
```

## Tarball

```sh
make dist
```

El artefacto queda en `dist/reina-de-copas-<version>.tar.gz`. El tarball incluye source, docs, scripts de instalacion y tests, pero excluye runtime local y metadata de git.

## Version

La version vive en `VERSION` y el CLI la expone con:

```sh
reina version
reina --version
reina --json version
```

Durante desarrollo se usa el sufijo `-dev`. Las releases deberian quitarlo y agregar una nota breve de cambios.

## Runtime instalado

La instalacion del codigo no cambia la estrategia de runtime:

- config: `${XDG_CONFIG_HOME:-$HOME/.config}/reina-de-copas`
- cache: `${XDG_CACHE_HOME:-$HOME/.cache}/reina-de-copas`
- state: `${XDG_STATE_HOME:-$HOME/.local/state}/reina-de-copas`

Para tests, paquetes o entornos aislados se pueden redirigir raices con:

```sh
REINA_CONFIG_ROOT=/tmp/reina-config \
REINA_CACHE_ROOT=/tmp/reina-cache \
REINA_STATE_ROOT=/tmp/reina-state \
reina list
```

## Politica de licencia

La licencia todavia no esta definida en el repo. Antes de una distribucion publica estable conviene elegir explicitamente una licencia, por ejemplo MIT, Apache-2.0, GPL o una politica cerrada. Hasta entonces, el proyecto debe tratarse como codigo sin licencia publica explicita.
