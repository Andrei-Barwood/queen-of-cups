# Reina de Copas

Reina de Copas es un CLI shell-first para convertir un catalogo de presets en comandos utilitarios de `zsh`, con un core compartido para `network`, `storage` y `errors`.

El cierre del Dia 1 deja lista la base del sistema:

- estructura oficial del repo
- manifiesto maestro de presets
- `bin/reina` con `help` y `list`
- estrategia de runtime XDG con fallback local
- politica de nombres, aliases y variantes

## Quick Start

```sh
./bin/reina help
./bin/reina version
./bin/reina list
./bin/reina info bass-in-the-desert
./bin/reina run bass-in-the-desert --dry-run
./bin/reina net-check --offline
make test
zsh tests/smoke_reina.zsh
zsh tests/errors_service.zsh
zsh tests/network_service.zsh
zsh tests/storage_service.zsh
zsh tests/distribution_install.zsh
```

## Instalacion local

```sh
make install PREFIX="$HOME/.local"
reina version
```

La instalacion copia el arbol del proyecto a `$PREFIX/lib/reina-de-copas` y crea el comando `$PREFIX/bin/reina`. Para desinstalar:

```sh
make uninstall PREFIX="$HOME/.local"
```

## Decisiones cerradas en Dia 1

- `zsh >= 5.4`
- enfoque shell-first con helpers externos pequenos y ubicuos cuando simplifican el core
- `presets/manifest.tsv` es la fuente de verdad del catalogo
- el runner resuelve presets por `slug`, alias explicito o nombre visible normalizado
- `network`, `storage` y `errors` viven en servicios compartidos; los presets no reinventan esas capas
- `network` usa `curl` como cliente primario y respeta `--offline` como politica real
- `storage` separa config, cache, state, historial, snapshots, temporales y locks
- `errors` formaliza estados `ok`, `degraded` y `failed` con JSON estable y exit codes consistentes
- runtime preferido en XDG, fallback local en `.reina/` y raices configurables con `REINA_CONFIG_ROOT`, `REINA_CACHE_ROOT` y `REINA_STATE_ROOT`
- distribucion local mediante `scripts/install.zsh`, `scripts/uninstall.zsh`, `make install` y `make dist`

## Convenciones de desarrollo

- funciones shell con prefijo `reina_`
- slugs en ASCII y `kebab-case`
- familias y variantes definidas en el manifiesto, no dispersas en scripts
- `shellcheck` y `shfmt` son herramientas recomendadas cuando estan instaladas

## Estructura base

```text
bin/
docs/
lib/
  core/
  presets/
  services/
presets/
tests/
```

## Estado actual

El Dia 5 deja `errors` como contrato formal para runner, network y storage: fallos fatales, warnings recuperables, degradaciones por fallback, JSON estructurado y exit codes estables. `run` todavia ejecuta un placeholder mientras prepara contexto real para presets futuros.

Mas detalles en `docs/distribution.md`.
