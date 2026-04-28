# Arquitectura

## Decisiones cerradas en Dia 1

- Version minima soportada: `zsh 5.4`.
- Estilo de implementacion: shell-first con helpers externos pequenos y ubicuos cuando simplifican el core.
- Fuente de verdad del catalogo: `presets/manifest.tsv`.
- Servicios obligatorios y compartidos desde el inicio: `network`, `storage`, `errors`.

Helpers externos admitidos desde el arranque:

- `awk`
- `sed`
- `grep`
- `cut`
- `tr`
- `sort`
- `uniq`
- `mktemp`
- `dirname`
- `basename`
- `date`

Regla base: un preset puede apoyarse en helpers comunes, pero nunca debe saltarse los servicios compartidos para hablar con la red, escribir runtime o emitir errores por su cuenta.

## Estructura oficial del repo

```text
bin/
  reina
docs/
  architecture.md
  presets.md
lib/
  core/
    bootstrap.zsh
    manifest.zsh
  presets/
  services/
    errors.zsh
    network.zsh
    storage.zsh
presets/
  aliases.tsv
  manifest.tsv
tests/
  smoke_reina.zsh
```

## Runtime

### Modo preferido: XDG

- cache: `${XDG_CACHE_HOME:-$HOME/.cache}/reina-de-copas`
- state: `${XDG_STATE_HOME:-$HOME/.local/state}/reina-de-copas`
- logs: `${state}/logs`
- history: `${state}/history`
- snapshots: `${state}/snapshots`

### Modo alternativo: local e ignorado

- cache: `.reina/cache`
- state: `.reina/state`
- logs: `.reina/state/logs`
- history: `.reina/state/history`
- snapshots: `.reina/state/snapshots`

### Politica

- El runtime por defecto es XDG.
- `REINA_RUNTIME_MODE=local` fuerza el modo local dentro del repo.
- Ningun dato temporal debe escribirse dentro de `bin/`, `lib/`, `docs/` o `presets/`.
- Cache es descartable; state, history y snapshots son persistentes.
- Los logs viven bajo `state`, no mezclados con cache.

## Contrato inicial de servicios

### Network

Interfaz compartida prevista:

- `reina_network_check`
- `reina_network_get`
- `reina_network_post`
- `reina_network_fetch_profile`

Reglas:

- Ningun preset debe invocar `curl` o un fetch ad hoc directamente.
- La red siempre debe poder degradar a cache o defaults locales.
- `--offline` debe cortar trafico remoto desde la capa comun.
- La ausencia de red no puede bloquear el caso de uso basico de un preset.

### Storage

Interfaz compartida prevista:

- `reina_storage_cache_dir`
- `reina_storage_state_dir`
- `reina_storage_logs_dir`
- `reina_storage_history_dir`
- `reina_storage_snapshots_dir`
- `reina_storage_ensure_runtime`

Reglas:

- Toda persistencia pasa por la capa de storage.
- Los presets no inventan subdirectorios propios fuera de la jerarquia de runtime.
- Historial y snapshots viven en `state`.
- Cache remota y artefactos temporales viven en `cache`.

### Errors

Interfaz compartida prevista:

- `reina_error_code`
- `reina_error_message`
- `reina_fail`

Reglas:

- Todo error controlado usa una clave `ERR_*`.
- El mensaje por defecto es corto y humano.
- El detalle fino queda reservado para niveles futuros de debug.
- Los exit codes expresan categoria; la clave `ERR_*` expresa semantica.

## Runner CLI

Desde el Dia 2, `bin/reina` es el entrypoint oficial del sistema. El script carga utilidades desde `lib/`, parsea flags globales, valida el manifiesto y despacha subcomandos sin contener la logica profunda de cada preset.

Comandos disponibles:

- `reina help`
- `reina list`
- `reina info <preset>`
- `reina run <preset>`
- `reina <preset>` como forma corta de `reina run <preset>`

Flags globales:

- `--debug`
- `--offline`
- `--quiet`
- `--json`
- `--dry-run`

Precedencia:

- `--quiet` reduce logs no esenciales.
- `--debug` sigue mostrando logs de debug en `stderr` aunque `--quiet` este activo.
- `--json` afecta la salida principal del comando, no los errores controlados.
- `--offline` modifica el contexto compartido de `network`.
- `--dry-run` prepara el flujo de ejecucion sin crear runtime.

## Resolucion de presets

El runner resuelve presets mediante `reina_resolve_preset`, usando este orden conceptual:

- `slug`
- alias explicito registrado en el manifiesto
- `display_name` normalizado cuando no introduce ambiguedad

Si un identificador coincide con mas de una entrada, el runner responde con `ERR_ALIAS_AMBIGUOUS`. Si no coincide con ninguna, responde con `ERR_PRESET_NOT_FOUND`.

## Contexto de ejecucion

`reina run <preset>` ya construye el contexto comun que recibiran los presets reales:

- `network`: modo `online` u `offline`
- `storage`: rutas oficiales de cache, state, logs, history y snapshots
- `flags`: valores globales parseados
- `errors`: contrato compartido
- `preset`: metadata resuelta desde `presets/manifest.tsv`

En el Dia 2, `run` ejecuta un placeholder estable. La logica especifica de presets empieza despues, pero ya tiene un punto oficial de entrada.

## Politica base de exit codes

| Codigo | Categoria |
| --- | --- |
| `0` | exito |
| `1` | fallo interno no clasificado |
| `2` | uso invalido, comando invalido o comando aun no habilitado |
| `3` | preset no encontrado o alias ambiguo |
| `4` | manifiesto o dato estructurado invalido |
| `5` | version, dependencia o red no disponible |
| `6` | fallo de storage o filesystem |
| `10-19` | reservado para errores controlados especificos de presets |

## Ejemplos minimos

```sh
reina help
reina list
reina list --json
reina info bass-in-the-desert
reina info ac-gtr
reina run bass-in-the-desert --dry-run
reina ac-gtr --offline --dry-run
```

## Nota de implementacion del Dia 2

`bin/reina` ya responde a `help`, `list`, `info` y `run`. La ejecucion real de cada preset sigue pendiente, pero el runner ya carga el manifiesto, resuelve aliases y prepara contexto compartido.
