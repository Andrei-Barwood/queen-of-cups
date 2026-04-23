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
./bin/reina list
zsh tests/smoke_reina.zsh
```

## Decisiones cerradas en Dia 1

- `zsh >= 5.4`
- enfoque shell-first con helpers externos pequenos y ubicuos cuando simplifican el core
- `presets/manifest.tsv` es la fuente de verdad del catalogo
- `network`, `storage` y `errors` viven en servicios compartidos; los presets no reinventan esas capas
- runtime preferido en XDG y fallback local en `.reina/`

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

El Dia 1 no ejecuta presets todavia. La invocacion `reina <preset>` queda reservada para el runner del Dia 2; hoy la prioridad es dejar un suelo estable y verificable.
