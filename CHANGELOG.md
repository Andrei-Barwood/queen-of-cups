# Changelog

Todos los cambios relevantes de Reina de Copas se documentan aquí.

El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/).
Este proyecto aún no publica versiones estables; la serie `0.x-dev` cubre la fase de infraestructura.

## [Unreleased]

### Pendiente

- Implementación de los presets restantes (Días 11–19).
- Licencia pública explícita.

## [0.9.0-dev] — 2026-06-24 — 🎙️ Día 10: Presencia Frontal Femenina

> *La familia `female-vocal` purifica la voz frontal con cadena de derivación dry → wet → wet-wide, sin duplicar lógica.*

### Añadido

- Familia `female-vocal`: `lib/presets/families/female-vocal.zsh` con core dry y extensiones wet.
- Cadena documentada: `female-vox-1` → `female-vox-1-wet` → `female-vocal-wet`.
- Tres presets `active`.
- Tests: `tests/presets_female_vocal.zsh`.

### Cambiado

- Tests de smoke, dispatcher e instalación usan `pop-lead-vocal` para verificar `ERR_PRESET_NOT_IMPLEMENTED`.
- Quince presets activos en total.

## [0.8.0-dev] — 2026-06-24 — 🌫️ Día 9: Espacio Interior de la Voz

> *La familia `vocals-atmospheric` abre la voz como paisaje: sombra, brillo, continuidad y el eje camel como línea identitaria.*

### Añadido

- Familia `vocals-atmospheric`: `lib/presets/families/vocals-atmospheric.zsh` con matriz de espacio y densidad.
- Cuatro presets `active`: `dark-vocals`, `dreamy-camel-vocals`, `sparkley-camel-vocals`, `warm-springy-vocals`.
- Eje camel documentado como línea de continuidad atmosférica (no gimmick).
- Tests: `tests/presets_vocals_atmospheric.zsh`.

### Cambiado

- Tests de smoke, dispatcher e instalación usan `female-vox-1` para verificar `ERR_PRESET_NOT_IMPLEMENTED`.
- Doce presets activos en total.

## [0.7.0-dev] — 2026-06-24 — 🌊 Día 8: Purificación del Subsuelo Sonoro

> *La familia `low-end` profundiza bajo 120 Hz: organicidad, síntesis e impacto controlado, en diálogo con el core `bass`.*

### Añadido

- Familia `low-end`: `lib/presets/families/low-end.zsh` con política de subgrave, herencia opcional de `bass` y gobernador `808`.
- Tres presets `active`: `upright-bass`, `synth-bass`, `808-boom-control`.
- Tests: `tests/presets_low_end.zsh` con verificación de no-interferencia entre `upright-bass` y `synth-bass`.
- Relación documentada `bass` ↔ `low-end` en `docs/presets.md`.

### Cambiado

- Tests de smoke, dispatcher e instalación usan `dark-vocals` para verificar `ERR_PRESET_NOT_IMPLEMENTED`.

## [0.6.0-dev] — 2026-06-24 — 🌵 Día 7: Primera Respiración del Low-End

> *El portal del Día 6 recibe su primera invocación viva: la familia `bass` purifica el low-end fundacional antes de expandir la red.*

### Añadido

- Familia `bass`: `lib/presets/families/bass.zsh` con core compartido, perfiles, recetas y snapshots.
- Preset fundacional `bass-in-the-desert` como referencia arquitectónica en `lib/presets/implementations/`.
- Variantes activas: `bass`, `put-this-on-bass`, `nice-bass`, `crunchy-bass` vía runner de familia.
- `reina_storage_config_put` para persistir perfiles por preset.
- Tests: `tests/presets_bass.zsh`.
- Nota de diseño de transformación de señal en `docs/presets.md`.

### Cambiado

- Cinco presets de familia `bass` pasan de `planned` a `active` en `presets/manifest.tsv`.
- `reina run bass-in-the-desert` ejecuta lógica real con perfil, snapshot e historial.
- Tests de smoke, dispatcher e instalación usan `upright-bass` para verificar `ERR_PRESET_NOT_IMPLEMENTED`.

## [0.5.0-dev] — 2026-06-24 — 🔺 Día 6: El Portal del Despacho

> *En la geometría espiritual del repo, los Días 1–5 formaron el hexágono del panal; el Día 6 abre la vesica piscis entre sistema y alma sonora. `reina run` es portal, no espejo.*

### Añadido

- Dispatcher de presets: `lib/presets/dispatcher.zsh`, `lib/presets/family-core.zsh`.
- Error `ERR_PRESET_NOT_IMPLEMENTED` con exit code `3`.
- Tests: `tests/preset_dispatcher.zsh`.
- Documentación del contrato de preset y ciclo de vida en `docs/presets.md`.
- Narrativa del Día 6 en `docs/journal.md` (geometría espiritual y mandala del proyecto).

### Cambiado

- `reina run` despacha implementaciones reales; deja de usar placeholder.
- Presets no implementados fallan con honestidad, incluso con `--dry-run`.
- `Makefile` valida sintaxis de `lib/presets/`.
- Lectura de `VERSION` corregida cuando el archivo no termina en newline.

## [0.4.1-dev] — 2026-06-24

### Añadido

- `docs/roadmap.md` — roadmap Días 0–22 con propósito, tareas y criterios de cierre.
- `docs/journal.md` — bitácora viva de lo que ocurre en el repositorio.
- Integración del stack completo (Días 1–5) en `main`.

## [0.4.0-dev] — 2026-04-28

### Añadido

- Sistema formal de errores: taxonomía `ERR_*`, estados `ok`/`degraded`/`failed`, JSON estable, exit codes.
- Tests: `tests/errors_service.zsh`.
- Degradación visible en network (fallback a cache) y storage (config opcional).

### Cambiado

- Runner, network, storage y manifest unificados bajo `lib/services/errors.zsh`.

## [0.3.0-dev] — 2026-04-28

### Añadido

- Scripts de distribución: `scripts/install.zsh`, `scripts/uninstall.zsh`.
- `Makefile` con targets `test`, `install`, `uninstall`, `dist`.
- `VERSION`, comando `reina version` / `--version`.
- `docs/distribution.md`.
- Tests: `tests/distribution_install.zsh`.

## [0.2.0-dev] — 2026-04-28

### Añadido

- Servicio `storage` completo: config, cache, state, historial, snapshots, locks, atomic writes, pruning.
- Tests: `tests/storage_service.zsh`.
- Network persiste cache vía storage para fallback offline.

## [0.1.0-dev] — 2026-04-28

### Añadido

- Servicio `network`: healthcheck, GET, POST, retry, cache, política `--offline`.
- Comando `reina net-check [url]`.
- Tests: `tests/network_service.zsh` con stub de `curl`.

### Añadido (runner — Día 2)

- Flags globales: `--debug`, `--offline`, `--quiet`, `--json`, `--dry-run`.
- Comandos `reina info <preset>`, `reina run <preset>`, forma corta `reina <preset>`.
- Módulos: `lib/core/flags.zsh`, `context.zsh`, `json.zsh`, `logging.zsh`.
- Resolución de presets por slug, alias y display name normalizado.

## [0.0.1-dev] — 2026-04-23

### Añadido

- Estructura inicial del repositorio.
- `bin/reina` con `help` y `list`.
- Manifiesto maestro: `presets/manifest.tsv` (53 presets en `planned`).
- Servicios esqueleto: `network`, `storage`, `errors`.
- Documentación: `docs/architecture.md`, `docs/presets.md`.
- Tests: `tests/smoke_reina.zsh`.