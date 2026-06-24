# Changelog

Todos los cambios relevantes de Reina de Copas se documentan aquí.

El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/).
Este proyecto aún no publica versiones estables; la serie `0.x-dev` cubre la fase de infraestructura.

## [Unreleased]

### Añadido

- `docs/roadmap.md` — roadmap Días 0–22 con propósito, tareas y criterios de cierre.
- `docs/journal.md` — bitácora viva de lo que ocurre en el repositorio.
- Integración del stack completo (Días 1–5) en `main`.

### Pendiente

- Dispatcher real de presets (Día 6).
- Implementación de los 53 presets catalogados (Días 7–19).
- Licencia pública explícita.

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