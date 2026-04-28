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
Makefile
VERSION
bin/
  reina
docs/
  architecture.md
  distribution.md
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
scripts/
  install.zsh
  uninstall.zsh
tests/
  distribution_install.zsh
  network_service.zsh
  storage_service.zsh
  smoke_reina.zsh
```

## Runtime

### Modo preferido: XDG

- cache: `${XDG_CACHE_HOME:-$HOME/.cache}/reina-de-copas`
- config: `${XDG_CONFIG_HOME:-$HOME/.config}/reina-de-copas`
- state: `${XDG_STATE_HOME:-$HOME/.local/state}/reina-de-copas`
- logs: `${state}/logs`
- history: `${state}/history`
- snapshots: `${state}/snapshots`

### Modo alternativo: local e ignorado

- cache: `.reina/cache`
- config: `.reina/config`
- state: `.reina/state`
- logs: `.reina/state/logs`
- history: `.reina/state/history`
- snapshots: `.reina/state/snapshots`

### Politica

- El runtime por defecto es XDG.
- `REINA_RUNTIME_MODE=local` fuerza el modo local dentro del repo.
- `REINA_CONFIG_ROOT`, `REINA_CACHE_ROOT` y `REINA_STATE_ROOT` permiten redirigir raices de runtime, especialmente en tests o integraciones.
- Ningun dato temporal debe escribirse dentro de `bin/`, `lib/`, `docs/` o `presets/`.
- Cache es descartable; state, history y snapshots son persistentes.
- Los logs viven bajo `state`, no mezclados con cache.
- El directorio `runtime/` dentro de state contiene temporales y locks.

## Contrato inicial de servicios

### Network

Interfaz compartida prevista:

- `reina_network_init`
- `reina_network_check`
- `reina_network_get`
- `reina_network_post`
- `reina_network_fetch_to_cache`
- `reina_network_retry`
- `reina_network_fail`

Aliases cortos disponibles para roadmap y presets futuros:

- `net_init`
- `net_check`
- `net_get`
- `net_post`
- `net_fetch_to_cache`
- `net_retry`
- `net_fail`

Reglas:

- Ningun preset debe invocar `curl` o un fetch ad hoc directamente.
- La red siempre debe poder degradar a cache o defaults locales.
- `--offline` debe cortar trafico remoto desde la capa comun.
- La ausencia de red no puede bloquear el caso de uso basico de un preset.

Alcance del Dia 3:

- healthcheck de conectividad o reachability
- fetch de recursos remotos por GET
- POST minimo para completar contrato
- descarga de metadata o perfiles remotos
- enriquecimiento opcional de contexto de ejecucion

Queda fuera por ahora:

- autenticacion compleja
- sesiones persistentes
- flujos remotos multipaso
- sincronizacion automatica agresiva

Cliente HTTP:

- dependencia primaria: `curl`
- deteccion: `command -v ${REINA_NETWORK_CURL_BIN:-curl}`
- error controlado si falta: `ERR_NETWORK_DEPENDENCY_MISSING`

Politica por defecto:

- timeout: `5` segundos
- reintentos: `2`
- backoff: `150ms * intento`
- healthcheck default: `https://example.com/`
- cache preparada en `${cache}/network`

Resultados de red:

- `status`: `ok`, `available`, `degraded`, `offline` o `error`
- `source`: `remote`, `cache` u `offline`
- `body`: respuesta remota o cacheada
- `headers`: headers remotos o metadata de cache
- `elapsed_ms`: duracion aproximada reportada por `curl`
- `error`: clave `ERR_NETWORK_*` si aplica

`--offline` es una politica de primera clase. Si una operacion pide red en modo offline, el servicio intenta leer cache cuando se entrega `cache_key`; si no existe fallback, responde con `ERR_NETWORK_OFFLINE`. `reina run` no hace fetch remoto todavia, pero ya recibe contexto de red completo.

### Storage

Interfaz compartida:

- `reina_storage_init`
- `reina_storage_get`
- `reina_storage_put`
- `reina_storage_exists`
- `reina_storage_delete`
- `reina_storage_list`
- `reina_storage_prune`
- `reina_storage_snapshot`
- `reina_storage_lock`
- `reina_storage_unlock`
- `reina_storage_cache_dir`
- `reina_storage_config_dir`
- `reina_storage_state_dir`
- `reina_storage_logs_dir`
- `reina_storage_history_dir`
- `reina_storage_snapshots_dir`
- `reina_storage_ensure_runtime`

Aliases cortos disponibles para roadmap y presets futuros:

- `store_init`
- `store_get`
- `store_put`
- `store_exists`
- `store_delete`
- `store_list`
- `store_prune`
- `store_snapshot`
- `store_lock`
- `store_unlock`

Estructura de runtime:

- config global: `${config}/global`
- config por preset: `${config}/presets/<preset>/`
- cache de red: `${cache}/network`
- cache de presets: `${cache}/presets`
- history: `${state}/history/<preset>/`
- snapshots: `${state}/snapshots/<preset>/`
- temporales: `${state}/runtime/tmp`
- locks: `${state}/runtime/locks`

Formatos:

- entradas simples: cuerpo en `.txt` y metadata en `.meta`
- metadata: `KEY=VALUE` legible a mano
- historial: texto plano con claves por linea
- snapshots: texto plano con metadata paralela
- estructuras mas ricas podran usar JSON cuando el preset lo justifique

Reglas:

- Toda persistencia pasa por la capa de storage.
- Los presets no inventan subdirectorios propios fuera de la jerarquia de runtime.
- Config, cache y state se mantienen separados.
- Historial, snapshots, temporales y locks viven en `state`.
- Cache remota y datos derivados descartables viven en `cache`.
- Las escrituras usan archivo temporal + `mv` para reducir corrupcion por escrituras parciales.
- Los locks son directorios atomicos bajo `runtime/locks` y tienen TTL para retirar bloqueos obsoletos.
- `store_prune` elimina entradas vencidas por TTL sin tocar datos vigentes.
- Network usa storage para cache y fallback offline; ningun preset cachea respuestas remotas por su cuenta.

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
- `reina version`
- `reina list`
- `reina info <preset>`
- `reina run <preset>`
- `reina net-check [url]`
- `reina <preset>` como forma corta de `reina run <preset>`

Flags globales:

- `--debug`
- `--version`
- `--offline`
- `--quiet`
- `--json`
- `--dry-run`

Precedencia:

- `--quiet` reduce logs no esenciales.
- `--debug` sigue mostrando logs de debug en `stderr` aunque `--quiet` este activo.
- `--version` se normaliza al comando `version`.
- `--json` afecta la salida principal del comando, no los errores controlados.
- `--offline` modifica el contexto compartido de `network`.
- `--dry-run` prepara el flujo de ejecucion sin escribir historial ni snapshots.

## Resolucion de presets

El runner resuelve presets mediante `reina_resolve_preset`, usando este orden conceptual:

- `slug`
- alias explicito registrado en el manifiesto
- `display_name` normalizado cuando no introduce ambiguedad

Si un identificador coincide con mas de una entrada, el runner responde con `ERR_ALIAS_AMBIGUOUS`. Si no coincide con ninguna, responde con `ERR_PRESET_NOT_FOUND`.

## Contexto de ejecucion

`reina run <preset>` ya construye el contexto comun que recibiran los presets reales:

- `network`: modo, estado, cliente HTTP, timeout, reintentos y cache de red
- `storage`: rutas oficiales de config, cache, state, history, snapshots, runtime, locks y cache por servicio
- `flags`: valores globales parseados
- `errors`: contrato compartido
- `preset`: metadata resuelta desde `presets/manifest.tsv`

En el Dia 4, `run` sigue ejecutando un placeholder estable. La logica especifica de presets empieza despues, pero ya tiene un punto oficial de entrada, contexto de red completo y storage inicializado. Cuando no se usa `--dry-run`, el runner registra una entrada simple de historial.

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
reina version
reina --version
reina list
reina list --json
reina info bass-in-the-desert
reina info ac-gtr
reina run bass-in-the-desert --dry-run
reina ac-gtr --offline --dry-run
reina net-check
reina net-check --offline
reina net-check --json
```

## Nota de implementacion del Dia 3

`bin/reina` ya responde a `help`, `list`, `info`, `run` y `net-check`. La ejecucion real de cada preset sigue pendiente, pero el runner ya carga el manifiesto, resuelve aliases y prepara contexto compartido con red inicializada.

## Nota de implementacion del Dia 4

Storage queda como memoria compartida del sistema: crea runtime, lee/escribe config, cache, historial y snapshots, y ofrece locks, atomic writes y pruning basico. Network ya persiste cache a traves de storage, por lo que `--offline` puede usar respuestas locales cuando existe una clave de cache.

## Distribucion

El repo se instala como arbol completo, no como archivo unico, porque `bin/reina` carga modulos desde `lib/` y datos desde `presets/`.

- version del paquete: `VERSION`
- instalador: `scripts/install.zsh`
- desinstalador: `scripts/uninstall.zsh`
- comando instalado: `$PREFIX/bin/reina`
- arbol instalado: `$PREFIX/lib/reina-de-copas`
- tarball local: `make dist`

La politica de licencia queda pendiente de decision explicita antes de una distribucion publica estable. Ver `docs/distribution.md`.
