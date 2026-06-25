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
    dispatcher.zsh
    family-core.zsh
    implementations/
    families/
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
  errors_service.zsh
  network_service.zsh
  preset_dispatcher.zsh
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

Filosofia:

- Reina de Copas no debe colapsar ruidosamente salvo en fallos realmente fatales.
- Todo resultado se expresa como `ok`, `degraded` o `failed`.
- Un fallback exitoso no se esconde: termina con exit code `0`, pero marca `degraded=true`.
- Warnings y degradaciones van por `stderr` en modo humano; en `--json` se serializan y no contaminan la salida principal.
- `--quiet` oculta warnings/degradaciones no fatales; los errores fatales siguen saliendo.
- `--debug` agrega `source`, `context`, `details`, fallback y exit code.

Interfaz compartida:

- `reina_error_code`
- `reina_error_kind`
- `reina_error_message`
- `reina_error_record`
- `reina_error_json`
- `reina_error_result_json`
- `reina_warn`
- `reina_degrade`
- `reina_recover_last_error_as_degradation`
- `reina_fail`

Contrato de error:

- `code`: clave estable `ERR_*`
- `kind`: `CLI`, `PRESET`, `NETWORK`, `STORAGE`, `INPUT`, `RUNTIME` o `INTERNAL`
- `message`: texto humano corto
- `details`: detalle tecnico opcional, visible con `--debug` o JSON
- `source`: componente que reporta el fallo
- `context`: identificador util para depurar
- `fatal`: `true|false`
- `fallback_applied`: `true|false`
- `exit_code`: codigo numerico estable

Taxonomia:

- CLI: `ERR_CLI_USAGE`, `ERR_CLI_INVALID_COMMAND`, `ERR_CLI_NOT_IMPLEMENTED`
- PRESET: `ERR_PRESET_NOT_FOUND`, `ERR_PRESET_ALIAS_AMBIGUOUS`, `ERR_PRESET_NOT_IMPLEMENTED`
- NETWORK: `ERR_NETWORK_OFFLINE`, `ERR_NETWORK_TIMEOUT`, `ERR_NETWORK_UNREACHABLE`, `ERR_NETWORK_HTTP`, `ERR_NETWORK_EMPTY`, `ERR_NETWORK_INVALID_RESPONSE`, `ERR_NETWORK_DEPENDENCY_MISSING`
- STORAGE: `ERR_STORE_INIT`, `ERR_STORE_NOT_FOUND`, `ERR_STORE_CORRUPT`, `ERR_STORE_WRITE`, `ERR_STORE_READ`, `ERR_STORE_PRUNE`, `ERR_STORE_LOCKED`, `ERR_STORE_RUNTIME_INVALID`
- INPUT: `ERR_INPUT_ARGUMENT_MISSING`, `ERR_INPUT_INVALID_FLAG`
- RUNTIME: `ERR_RUNTIME_VERSION_UNSUPPORTED`, `ERR_RUNTIME_DEPENDENCY_MISSING`, `ERR_RUNTIME_MANIFEST_MISSING`, `ERR_RUNTIME_MANIFEST_INVALID`
- INTERNAL: `ERR_INTERNAL`

Formato JSON fatal minimo:

```json
{
  "ok": false,
  "degraded": false,
  "status": "failed",
  "code": "ERR_PRESET_NOT_FOUND",
  "message": "preset no encontrado: ejemplo",
  "source": "preset",
  "context": "identifier=ejemplo",
  "exit_code": 3,
  "error": {}
}
```

Politica de fallback:

- Si falla network y existe `cache_key`, se intenta cache antes de fallar.
- Si `--offline` encuentra cache local, la operacion termina degradada con `source=cache`.
- Si falta config opcional, se usan defaults sin marcar fallo fatal.
- Si una config opcional esta corrupta, se ignora esa entrada y se registra degradacion.
- Si falla un historial o snapshot no critico, el runner puede continuar y recuperar el fallo como degradacion.
- Ningun fallback debe ocultar fallos graves ni cambiar un `failed` fatal por `ok` sin registrar degradacion.

Reglas:

- Todo error controlado usa una clave `ERR_*`.
- El mensaje por defecto es corto y humano.
- El detalle fino queda reservado para `--debug` y JSON.
- Los exit codes expresan categoria; la clave `ERR_*` expresa semantica.
- Runner, network, storage y futuros presets deben usar este modulo como unica salida de errores controlados.

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
- `--json` afecta la salida principal del comando y serializa errores controlados como JSON.
- `--offline` modifica el contexto compartido de `network`.
- `--dry-run` prepara el flujo de ejecucion sin escribir historial ni snapshots.

## Resolucion de presets

El runner resuelve presets mediante `reina_resolve_preset`, usando este orden conceptual:

- `slug`
- alias explicito registrado en el manifiesto
- `display_name` normalizado cuando no introduce ambiguedad

Si un identificador coincide con mas de una entrada, el runner responde con `ERR_PRESET_ALIAS_AMBIGUOUS`. Si no coincide con ninguna, responde con `ERR_PRESET_NOT_FOUND`.

## Contexto de ejecucion

`reina run <preset>` ya construye el contexto comun que recibiran los presets reales:

- `network`: modo, estado, cliente HTTP, timeout, reintentos y cache de red
- `storage`: rutas oficiales de config, cache, state, history, snapshots, runtime, locks y cache por servicio
- `flags`: valores globales parseados
- `errors`: contrato compartido
- `preset`: metadata resuelta desde `presets/manifest.tsv`

Desde el Dia 6, `run` despacha presets reales via `lib/presets/dispatcher.zsh`. Si no existe implementacion, responde con `ERR_PRESET_NOT_IMPLEMENTED`. Cuando un preset corre con exito y no se usa `--dry-run`, el runner registra historial mediante `reina_preset_history_record`.

## Politica base de exit codes

| Codigo | Categoria |
| --- | --- |
| `0` | exito |
| `1` | fallo generico controlado |
| `2` | uso invalido, input invalido o argumentos incorrectos |
| `3` | preset o recurso no encontrado |
| `4` | fallo de red |
| `5` | fallo de almacenamiento |
| `6` | dependencia faltante o entorno invalido |
| `7` | estado interno inconsistente |

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

## Nota de implementacion del Dia 5

Errors queda como contrato formal para runner, network y storage. `reina_fail` emite fallos fatales con exit codes estables, `reina_warn` registra advertencias recuperables y `reina_degrade` marca fallbacks visibles. Network degrada a cache cuando corresponde, storage diferencia config opcional de fallo fatal, y `--json`, `--quiet` y `--debug` tienen comportamiento definido frente a errores.

## Nota de implementacion del Dia 6

Preset dispatch queda como puerta unica de ejecucion:

- `reina_preset_resolve_runner` carga implementaciones por slug o familia sin usar subshells
- `reina_preset_dispatch` ejecuta el runner resuelto
- `family-core.zsh` concentra helpers de perfil, snapshot y resultado
- `reina run` ya no usa placeholder: o ejecuta o declara `ERR_PRESET_NOT_IMPLEMENTED`

## Nota de implementacion del Dia 7

La familia `bass` es la primera invocacion viva del portal:

- `lib/presets/families/bass.zsh` concentra perfiles, recetas y `reina_family_bass_run`
- `lib/presets/implementations/bass-in-the-desert.zsh` documenta el patron slug + core de familia
- `reina_storage_config_put` completa el contrato de `reina_preset_profile_put`
- cinco presets pasan a `active`; el resto del catalogo sigue en `planned`

## Nota de implementacion del Dia 8

La familia `low-end` profundiza el subsuelo sonoro:

- `lib/presets/families/low-end.zsh` define politica de subgrave y `reina_family_low_end_run`
- `upright-bass` hereda opcionalmente el core `bass`; `synth-bass` y `upright-bass` declaran aislamiento mutuo
- `808-boom-control` actua como gobernador de subgrave dominante con headroom reservado
- tres presets pasan a `active`; ocho presets activos en total

## Nota de implementacion del Dia 9

La familia `vocals-atmospheric` abre la voz como paisaje:

- `lib/presets/families/vocals-atmospheric.zsh` define matriz de espacio/densidad y `reina_family_vocals_atmospheric_run`
- el eje camel es linea identitaria del bloque (`dreamy-camel-vocals`, `sparkley-camel-vocals`)
- `dark-vocals` y `warm-springy-vocals` comparten la matriz sin activar camel
- cuatro presets pasan a `active`; doce presets activos en total

## Nota de implementacion del Dia 10

La familia `female-vocal` modela derivacion sin duplicacion:

- `lib/presets/families/female-vocal.zsh` concentra core dry y extensiones wet/wet-wide
- cadena `female-vox-1` → `female-vox-1-wet` → `female-vocal-wet` documentada en perfiles y snapshots
- tres presets pasan a `active`; quince presets activos en total

## Nota de implementacion del Dia 11

La familia `vocal-utility` eleva consciencia operativa:

- `lib/presets/families/vocal-utility.zsh` define roles lead/assist/background
- `vocal-help` produce diagnostico util via `REINA_PRESET_RESULT_MESSAGE` en humano y `--json`
- tres presets pasan a `active`; dieciocho presets activos en total

## Nota de implementacion del Dia 12

La familia `drum-bus` purifica el colectivo ritmico:

- `lib/presets/families/drum-bus.zsh` define matriz de compresion, espacio y cohesion
- cuatro variantes: drive, spaced, wild, glue
- cuatro presets pasan a `active`; veintidos presets activos en total

## Nota de implementacion del Dia 13

La familia `drum-experimental` eleva capas paralelas con degradacion segura:

- `lib/presets/families/drum-experimental.zsh` define texturas parallel y gated
- fallback local via `reina_degrade` si faltan `curl`, red o `awk`
- cuatro presets pasan a `active`; veintiseis presets activos en total

## Nota de implementacion del Dia 14

La familia `drum-pieces-core` purifica anclas del pulso:

- `lib/presets/families/drum-pieces-core.zsh` define kick/snare con variantes semanticas
- politica `semantic-only` sin series numericas abiertas
- cinco presets pasan a `active`; treinta y un presets activos en total

## Nota de implementacion del Dia 15

La familia `drum-detail-and-space` eleva aire y detalle alrededor del kit:

- `lib/presets/families/drum-detail-and-space.zsh` define matriz de espacio y politica de independencia
- `ohs` mantiene preset propio (`overheads-compact`), no alias de `drums-overheads` (`overheads-wide`)
- seis presets pasan a `active`; treinta y siete presets activos en total

## Nota de implementacion del Dia 16

La familia `guitar-heavy-and-electric` purifica drive electrico y cuerpo metalico:

- `lib/presets/families/guitar-heavy-and-electric.zsh` define matriz de drive y linea camel en variante wild
- `gtr` (base) y `el-gtr-driver` (driver) mantienen perfiles y transforms distintos
- cinco presets pasan a `active`; cuarenta y dos presets activos en total

## Nota de implementacion del Dia 17

La familia `guitar-acoustic-and-plucked` purifica cuerda resonante y ataque natural:

- `lib/presets/families/guitar-acoustic-and-plucked.zsh` define matriz de resonancia y derivacion muted-wet
- alias `ac-gtr` resuelve a `acoustic-gtr` en `run` e `info` sin crear preset nuevo
- cuatro presets pasan a `active`; cuarenta y seis presets activos en total

## Nota de implementacion del Dia 18

La familia `keys-and-piano` eleva consciencia armonica:

- `lib/presets/families/keys-and-piano.zsh` define matriz armonica y eje camel en `keys-riding-a-camel`
- politica `read-not-fix`: las teclas son territorio de lectura, no de correccion
- cuatro presets pasan a `active`; cincuenta presets activos en total

## Nota de implementacion del Dia 19

La familia `utility-texture-and-master` cierra el ciclo del catalogo:

- `lib/presets/families/utility-texture-and-master.zsh` define refresh, lofi y master
- `camels-need-water` emite recovery report operativo
- tres presets pasan a `active`; **53/53 presets activos**

## Consciencia de red (Dia 20)

Un preset deja de ser un nodo aislado: `reina run`, `reina info` y `reina graph` exponen su lugar en la red.

### Esquema de perfiles remotos

| Ubicacion | Rol |
| --- | --- |
| `${cache}/network/preset-profile-<slug>.txt` | cuerpo remoto cacheado por `reina_network_fetch_to_cache` |
| `${config}/presets/<slug>/remote-profile.txt` | espejo persistido en config |
| `${config}/presets/<slug>/remote-profile-binding.txt` | metadata de sincronizacion (`source`, `endpoint`, `cache_key`, `network_status`) |

Endpoint por defecto: `${REINA_REMOTE_PROFILE_BASE_URL:-https://example.com/reina/presets/}<slug>.profile`

### Politica offline-first

- `reina run` invoca `reina_network_consciousness_sync_remote_profile` antes del dispatch
- en `--offline`, network lee cache si existe y marca `degraded` sin romper la cadena sonora
- si no hay cache ni espejo local, el preset sigue ejecutandose con `remote_source=unavailable`

### Grafo de dependencias

`lib/presets/network-consciousness.zsh` construye `network_graph` con:

- `family` y `variant` del manifiesto
- `siblings`: variantes hermanas de la misma familia
- `remote_profile`: fuente (`remote`, `cache`, `local`, `unavailable`) y rutas
- `last_snapshot`: clave, ruta, contexto y origen del ultimo snapshot

El grafo se serializa en `reina run --json` como `network_graph` y se imprime en humano bajo `Network:`.

### Comandos

- `reina graph <preset>` — vista exploratoria del grafo
- `reina info <preset>` — metadata del manifiesto + seccion `Network:`
- `reina run <preset> --json` — resultado de ejecucion + `network_graph`

## Purificacion operativa (Dia 21)

El sistema se autoexamina antes de abrir sesion. Modulo: `lib/core/operations.zsh`.

### Comandos

| Comando | Rol |
| --- | --- |
| `reina doctor` | revisa zsh, helpers, curl, manifiesto, storage y permisos |
| `reina history <preset>` | lectura del historial en `${state}/history/<preset>/` |
| `reina snapshot <preset> list` | lista snapshots en `${state}/snapshots/<preset>/` |
| `reina snapshot <preset> restore [key]` | restaura snapshot a `${config}/presets/<slug>/profile.txt` |
| `reina prune [--cache\|--all]` | limpia cache vencida |

### Politica de pruning

| Modo | Alcance |
| --- | --- |
| `prune` / `prune --cache` | cache `network` y `presets` con TTL 86400s |
| `prune --all` | cache vencida + temporales en `runtime/tmp` + locks obsoletos (>300s) |

Reglas:

- `doctor` reporta `ok`, `degraded` o `failed`; exit code `3` solo en `failed`
- `curl` ausente degrada, no falla el doctor
- `snapshot restore` sin `key` usa el snapshot mas reciente
- historial y snapshots nunca se podan automaticamente en Dia 21

## Distribucion

El repo se instala como arbol completo, no como archivo unico, porque `bin/reina` carga modulos desde `lib/` y datos desde `presets/`.

- version del paquete: `VERSION`
- instalador: `scripts/install.zsh`
- desinstalador: `scripts/uninstall.zsh`
- comando instalado: `$PREFIX/bin/reina`
- arbol instalado: `$PREFIX/lib/reina-de-copas`
- tarball local: `make dist`

La politica de licencia queda pendiente de decision explicita antes de una distribucion publica estable. Ver `docs/distribution.md`.
