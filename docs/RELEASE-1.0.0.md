# Release 1.0.0 — Reina de Copas

**Fecha:** 2026-06-24  
**Día del mandala:** 22 — Integración, licencia y release  
**Licencia:** [MIT](../LICENSE)

---

## Resumen

Primera release estable de Reina de Copas: CLI shell-first en `zsh` con **53/53 presets activos**, servicios compartidos (`network`, `storage`, `errors`), consciencia de red, purificación operativa y distribución instalable.

El ciclo kundalini del roadmap (Días 0–22) cierra aquí: lo purificado se sostiene; lo elevado se comparte con responsabilidad.

---

## Qué incluye 1.0.0

### Catálogo completo (53 presets, 13 familias)

| Familia | Presets |
| --- | ---: |
| `bass` | 5 |
| `low-end` | 3 |
| `vocals-atmospheric` | 4 |
| `female-vocal` | 3 |
| `vocal-utility` | 3 |
| `drum-bus` | 4 |
| `drum-experimental` | 4 |
| `drum-pieces-core` | 5 |
| `drum-detail-and-space` | 6 |
| `guitar-heavy-and-electric` | 5 |
| `guitar-acoustic-and-plucked` | 4 |
| `keys-and-piano` | 4 |
| `utility-texture-and-master` | 3 |

### CLI y operaciones

- `reina run`, `info`, `list`, `version`, `net-check`
- `reina graph <preset>` — grafo de familia, hermanos y perfil remoto
- `reina doctor` — autoexamen de runtime, dependencias y manifiesto
- `reina history <preset>`, `reina snapshot <preset> list|restore`
- `reina prune [--cache|--all]`
- Flags globales: `--debug`, `--offline`, `--quiet`, `--json`, `--dry-run`

### Infraestructura

- Dispatcher con contrato honesto (`ok`, `degraded`, `failed`)
- Storage XDG con historial, snapshots y cache
- Network offline-first con perfiles remotos opcionales
- Sistema de errores estable con JSON serializable

---

## Instalación

```sh
# Desde el repositorio
zsh scripts/install.zsh --prefix "$HOME/.local"

# O con make
make install PREFIX="$HOME/.local"
```

Desde tarball:

```sh
tar -xzf reina-de-copas-1.0.0.tar.gz
cd reina-de-copas-1.0.0
zsh scripts/install.zsh --prefix "$HOME/.local"
```

Verificar:

```sh
reina version          # reina-de-copas 1.0.0
reina doctor
reina run bass-in-the-desert --dry-run
```

---

## Validación de release

```sh
make test
make dist
zsh tests/distribution_install.zsh
./bin/reina list --json | jq 'map(select(.status != "active")) | length'  # debe ser 0
```

---

## Artefacto

```sh
make dist
# → dist/reina-de-copas-1.0.0.tar.gz
```

El tarball incluye `bin/`, `lib/`, `presets/`, `docs/`, `scripts/`, `tests/`, `LICENSE`, `CHANGELOG.md`, `README.md` y `VERSION`.

---

## Notas de migración desde `0.x-dev`

- `VERSION` pasa de `0.20.0-dev` a `1.0.0` sin sufijo `-dev`.
- No hay cambios breaking en slugs ni en el manifiesto: los 53 presets conservan nombre y familia.
- La licencia MIT aplica a partir de esta release; versiones anteriores sin `LICENSE` deben tratarse como código sin licencia pública explícita.

---

## Documentación

- [`README.md`](../README.md) — puerta de entrada
- [`docs/architecture.md`](architecture.md) — contratos técnicos
- [`docs/distribution.md`](distribution.md) — instalación y empaquetado
- [`CHANGELOG.md`](../CHANGELOG.md) — historial completo