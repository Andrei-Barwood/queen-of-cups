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

## Nota de implementacion del Dia 1

`bin/reina` existe y ya responde a `help` y `list`. La ejecucion real de presets queda intencionalmente reservada para el Dia 2 para no mezclar fundaciones con el runner.
