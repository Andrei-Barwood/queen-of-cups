# Roadmap de implementaciones — Reina de Copas

## Propósito

Reina de Copas no es solo un catálogo de presets ni un CLI de conveniencia. Su propósito es análogo al del **kundalini yoga** en el ser humano: **purificar la mente y elevar la consciencia**.

Trasladado al dominio del sonido:

| Yoga (ser humano) | Reina de Copas (red del sonido) |
| --- | --- |
| Purificar la mente | Purificar la **mente de la fuente de sonido** — quitar ruido mental, hábito automático, decisión reactiva y confusión en la cadena de procesamiento |
| Elevar la consciencia | Elevar la **consciencia de la red del sonido** — hacer visible cómo fluye la señal, qué relaciones existen entre nodos, qué degradaciones ocurren y qué intención sostiene cada preset |

En la práctica, cada día de este roadmap debe acercar el sistema a ese doble movimiento:

1. **Purificación** — menos caos, menos acoplamiento oculto, menos dependencia ciega de herramientas externas; decisiones explícitas, errores honestos, runtime limpio.
2. **Elevación** — más contexto compartido, más memoria útil, más claridad sobre el estado de la red sonora; el operador escucha mejor porque el sistema ve mejor.

El manifiesto poético (`dreamy-camel-vocals`, `camels-need-water`, `Bass in the Desert`) no es decoración: nombra **estados de consciencia sonora** que el código debe poder invocar con intención.

---

## Estado actual

### Completado (Días 1–5)

La infraestructura base vive en ramas apiladas (`day-01` → `day-05-errors-system`). `main` aún no integra ese trabajo.

| Día | Entrega | Estado |
| --- | --- | --- |
| 1 | Estructura del repo, manifiesto, `help`/`list`, contratos de servicios | Hecho en rama |
| 2 | Runner CLI, flags globales, `info`/`run`, resolución de presets | Hecho en rama |
| 3 | Servicio `network` compartido, `net-check`, política offline | Hecho en rama |
| 4 | Servicio `storage` compartido, runtime XDG, historial, snapshots, locks | Hecho en rama |
| 5 | Sistema formal de `errors`, degradaciones, JSON estable | Hecho en rama |
| — | Distribución: `install`/`uninstall`, `Makefile`, `VERSION`, tests | Hecho en rama |

### Pendiente de inmediato

- Integrar el stack de PRs en `main`.
- Sustituir el placeholder de `reina run` por ejecución real de presets.
- Implementar los **53 presets** catalogados en `presets/manifest.tsv` (todos en `planned`).
- Definir licencia antes de una distribución pública estable.

---

## Convenciones del roadmap

Cada día incluye:

- **Intención** — qué aspecto de purificación o elevación se trabaja.
- **Tareas** — trabajo concreto.
- **Entregables** — artefactos verificables.
- **Validación** — comandos o tests que deben pasar.
- **Cierre** — condición para considerar el día terminado.

Los presets se implementan por **familias**, respetando la prioridad del manifiesto. Un preset solo pasa a `active` cuando su lógica es real, testeada y coherente con el core de su familia.

---

## Día 0 — Integración del cuerpo (merge a `main`)

### Intención

Antes de seguir elevando la red, el cuerpo del proyecto debe habitar un solo tronco. Un `main` vacío es mente dispersa: el conocimiento existe, pero no circula.

### Tareas

- [ ] Revisar y mergear PR #1 → `main` (foundations).
- [ ] Mergear en cadena PRs #2–#6, resolviendo conflictos si aparecen.
- [ ] Verificar que `make test` pasa en `main` después de cada merge.
- [ ] Etiquetar `0.4.0-dev` como baseline de infraestructura en `main`.
- [ ] Actualizar `README.md` para reflejar que los Días 1–5 ya viven en `main`.

### Entregables

- `main` con árbol completo: `bin/`, `lib/`, `presets/`, `tests/`, `docs/`, `scripts/`.
- Historial lineal o stack mergeado sin ramas huérfanas críticas.

### Validación

```sh
make test
./bin/reina version
./bin/reina list
```

### Cierre

Cualquier clon de `main` reproduce el CLI funcional sin checkout manual de ramas.

---

## Día 6 — Contrato de preset y despacho real

### Intención

Purificar el punto de entrada: `reina run` deja de ser promesa y se convierte en ritual. La mente de la fuente encuentra un canal único.

### Tareas

- [x] Crear `lib/presets/dispatcher.zsh` con `reina_preset_dispatch`.
- [x] Definir contrato mínimo de preset:
  - `reina_preset_<slug>_run` o convención por familia `reina_family_<family>_run`.
  - Entrada: contexto compartido (`network`, `storage`, `flags`, `errors`, metadata del preset).
  - Salida: `ok`, `degraded` o `failed` con mensaje humano y JSON opcional.
- [x] Crear `lib/presets/family-core.zsh` con helpers comunes (lectura de perfil, snapshot, validación de entrada).
- [x] Reemplazar el placeholder en `reina_cmd_run` por despacho real vía dispatcher.
- [x] Si el preset está en `planned` sin implementación, responder con `ERR_PRESET_NOT_IMPLEMENTED` (nueva clave) en lugar de fingir éxito.
- [x] Documentar el contrato en `docs/presets.md`.
- [x] Añadir `tests/preset_dispatcher.zsh`.

### Entregables

- Dispatcher operativo.
- `reina run <preset-no-implementado>` falla con claridad.
- Documentación del ciclo de vida: `planned` → `beta` → `active` → `deprecated`.

### Validación

```sh
zsh tests/preset_dispatcher.zsh
zsh tests/smoke_reina.zsh
./bin/reina run bass-in-the-desert   # debe indicar no implementado o ejecutar si ya existe stub
```

### Cierre

`run` ya no miente: o ejecuta lógica real o declara ausencia con contrato de error estable.

---

## Día 7 — Familia `bass` y preset fundacional

### Intención

`Bass in the Desert` es la raíz kundalini del sistema: el primer contacto con la fuente. Purificar el low-end fundacional antes de expandir la red.

### Presets del día

| Prioridad | Slug | Variante |
| --- | --- | --- |
| 010 | `bass-in-the-desert` | foundational |
| 020 | `bass` | base |
| 030 | `put-this-on-bass` | utility |
| 040 | `nice-bass` | smooth |
| 050 | `crunchy-bass` | aggressive |

### Tareas

- [ ] Crear `lib/presets/families/bass.zsh` con core compartido de la familia.
- [ ] Implementar `bass-in-the-desert` como referencia arquitectónica documentada.
- [ ] Implementar `bass`, `put-this-on-bass`, `nice-bass`, `crunchy-bass` como variantes del core.
- [ ] Definir perfiles por preset en `${config}/presets/<slug>/` (aunque sean `.txt` iniciales).
- [ ] Registrar historial y snapshot en ejecuciones reales (sin `--dry-run`).
- [ ] Actualizar `status` a `active` solo para presets con lógica real.
- [ ] Añadir `tests/presets_bass.zsh`.

### Entregables

- 5 presets `active` en familia `bass`.
- Nota de diseño: qué significa “desert”, “nice”, “crunchy” en términos de transformación de señal.

### Validación

```sh
zsh tests/presets_bass.zsh
./bin/reina run bass-in-the-desert
./bin/reina run crunchy-bass --json
./bin/reina info bass-in-the-desert
```

### Cierre

La familia `bass` demuestra el patrón que todas las demás familias repetirán.

---

## Día 8 — Familia `low-end`

### Intención

Profundizar la purificación del subsuelo sonoro: organicidad, síntesis e impacto controlado. Elevar la consciencia de lo que ocurre bajo 120 Hz.

### Presets del día

| Prioridad | Slug | Variante |
| --- | --- | --- |
| 060 | `upright-bass` | organic |
| 070 | `synth-bass` | synthetic |
| 080 | `808-boom-control` | impact |

### Tareas

- [ ] Crear `lib/presets/families/low-end.zsh`.
- [ ] Implementar los 3 presets con herencia opcional del core `bass` donde aplique.
- [ ] Definir política de subgrave: contención, headroom, relación con `808-boom-control`.
- [ ] Tests de no-interferencia entre `synth-bass` y `upright-bass`.
- [ ] Añadir `tests/presets_low_end.zsh`.

### Validación

```sh
zsh tests/presets_low_end.zsh
./bin/reina run 808-boom-control --dry-run
```

### Cierre

3 presets `active`; documentada la relación `bass` ↔ `low-end`.

---

## Día 9 — Familia `vocals-atmospheric`

### Intención

Abrir el espacio interior de la voz: sombra, brillo, continuidad. Elevar la percepción de la voz como paisaje, no como señal aislada.

### Presets del día

| Prioridad | Slug | Variante |
| --- | --- | --- |
| 090 | `dark-vocals` | dark |
| 100 | `dreamy-camel-vocals` | dreamy |
| 110 | `sparkley-camel-vocals` | sparkly |
| 120 | `warm-springy-vocals` | warm |

### Tareas

- [ ] Crear `lib/presets/families/vocals-atmospheric.zsh`.
- [ ] Implementar matriz de variantes atmosféricas con parámetros compartidos de espacio y densidad.
- [ ] Documentar el eje “camel” como línea identitaria del bloque (no como gimmick).
- [ ] Añadir `tests/presets_vocals_atmospheric.zsh`.

### Validación

```sh
zsh tests/presets_vocals_atmospheric.zsh
./bin/reina run dreamy-camel-vocals --json
```

### Cierre

4 presets `active`; familia con identidad poética y técnica explícita.

---

## Día 10 — Familia `female-vocal`

### Intención

Purificar la presencia frontal de la voz femenina: seca, húmeda, amplia. Menos máscara, más verdad timbral.

### Presets del día

| Prioridad | Slug | Variante |
| --- | --- | --- |
| 130 | `female-vox-1` | dry |
| 140 | `female-vox-1-wet` | wet |
| 150 | `female-vocal-wet` | wet-wide |

### Tareas

- [ ] Crear `lib/presets/families/female-vocal.zsh`.
- [ ] Modelar derivación: `female-vox-1` → `female-vox-1-wet` → `female-vocal-wet`.
- [ ] Evitar duplicar lógica: la variante wet debe extender, no copiar.
- [ ] Añadir `tests/presets_female_vocal.zsh`.

### Cierre

3 presets `active` con cadena de derivación documentada.

---

## Día 11 — Familia `vocal-utility`

### Intención

Elevar la consciencia operativa: diagnóstico, liderazgo, fondos con vida. La red aprende a asistir, no solo a embellecer.

### Presets del día

| Prioridad | Slug | Variante |
| --- | --- | --- |
| 160 | `pop-lead-vocal` | lead |
| 170 | `vocal-help` | assist |
| 180 | `give-backgrounds-some-life` | background |

### Tareas

- [ ] Crear `lib/presets/families/vocal-utility.zsh`.
- [ ] Implementar `vocal-help` como preset diagnóstico (reporta estado, no solo procesa).
- [ ] Implementar `pop-lead-vocal` y `give-backgrounds-some-life`.
- [ ] Añadir `tests/presets_vocal_utility.zsh`.

### Cierre

3 presets `active`; `vocal-help` produce salida útil en modo humano y `--json`.

---

## Día 12 — Familia `drum-bus`

### Intención

Purificar el colectivo rítmico: empuje, espacio, wildness, glue. La batería como organismo, no como suma de golpes.

### Presets del día

| Prioridad | Slug | Variante |
| --- | --- | --- |
| 190 | `drum-bus-drivin` | drive |
| 200 | `drum-bus-island` | spaced |
| 210 | `drum-bus-wild-spring-camel` | wild |
| 220 | `drum-bus-magic` | glue |

### Tareas

- [ ] Crear `lib/presets/families/drum-bus.zsh`.
- [ ] Implementar los 4 presets de bus con semántica distinta de compresión/espacio/cohesión.
- [ ] Añadir `tests/presets_drum_bus.zsh`.

### Cierre

4 presets `active` en el bloque de buses.

---

## Día 13 — Familia `drum-experimental`

### Intención

Elevar la consciencia de capas paralelas y texturas no lineales. Purificar el miedo al riesgo controlado.

### Presets del día

| Prioridad | Slug | Variante |
| --- | --- | --- |
| 230 | `parallel-processing-drums` | parallel |
| 240 | `myon-pop-parallel-magic` | parallel-pop |
| 250 | `wildin-camel-drums` | parallel-wild |
| 260 | `wierdly-gated-drums` | gated |

### Tareas

- [ ] Crear `lib/presets/families/drum-experimental.zsh`.
- [ ] Implementar paralelos y gating con degradación segura si faltan dependencias.
- [ ] Añadir `tests/presets_drum_experimental.zsh`.

### Cierre

4 presets `active`; fallos no fatales cuando una capa experimental no puede aplicarse.

---

## Día 14 — Familia `drum-pieces-core`

### Intención

Volver al pulso primario: kick, snare, acento. Purificar los anclas antes de los adornos.

### Presets del día

| Prioridad | Slug | Variante |
| --- | --- | --- |
| 270 | `kick` | anchor |
| 280 | `kick-2` | anchor-tight |
| 290 | `snare` | accent |
| 300 | `urban-snare` | accent-dry |
| 310 | `urban-snare-tighter` | accent-tight |

### Tareas

- [ ] Crear `lib/presets/families/drum-pieces-core.zsh`.
- [ ] Implementar familia semántica kick/snare sin series numéricas abiertas.
- [ ] Añadir `tests/presets_drum_pieces_core.zsh`.

### Cierre

5 presets `active`; política de variantes semánticas verificada en código.

---

## Día 15 — Familia `drum-detail-and-space`

### Intención

Elevar la consciencia del espacio y el detalle: overheads, room, fills. La red percibe el aire alrededor del kit.

### Presets del día

| Prioridad | Slug | Variante |
| --- | --- | --- |
| 320 | `hats` | detail |
| 330 | `drums-overheads` | overheads-wide |
| 340 | `ohs` | overheads-compact |
| 350 | `trash-drum-room` | room-trash |
| 360 | `drum-room-smash` | room-smash |
| 370 | `fill-kollin` | fill |

### Tareas

- [ ] Crear `lib/presets/families/drum-detail-and-space.zsh`.
- [ ] Mantener `ohs` como preset propio (no alias de `drums-overheads`).
- [ ] Implementar los 7 presets.
- [ ] Añadir `tests/presets_drum_detail_and_space.zsh`.

### Cierre

7 presets `active`; bloque de batería completo en todas sus capas.

---

## Día 16 — Familia `guitar-heavy-and-electric`

### Intención

Purificar el drive eléctrico: brillo, reverb, salvajismo, empuje. Consciencia del cuerpo metálico en la red.

### Presets del día

| Prioridad | Slug | Variante |
| --- | --- | --- |
| 380 | `heavy-bright-guitar` | bright |
| 390 | `heavy-guitar-with-reverb` | reverb |
| 400 | `wildin-camel-guitar` | wild |
| 410 | `el-gtr-driver` | driver |
| 420 | `gtr` | base |

### Tareas

- [ ] Crear `lib/presets/families/guitar-heavy-and-electric.zsh`.
- [ ] Implementar los 5 presets.
- [ ] Añadir `tests/presets_guitar_heavy_electric.zsh`.

### Cierre

5 presets `active`.

---

## Día 17 — Familia `guitar-acoustic-and-plucked`

### Intención

Purificar la cuerda resonante: acústica, muteada, húmeda. Elevar la consciencia del ataque y la cola natural.

### Presets del día

| Prioridad | Slug | Variante |
| --- | --- | --- |
| 430 | `acoustic-guitar-wet` | wet |
| 440 | `acoustic-gtr` | base |
| 450 | `muted-cuatro` | muted |
| 460 | `muted-cuatro-wet` | muted-wet |

### Tareas

- [ ] Crear `lib/presets/families/guitar-acoustic-and-plucked.zsh`.
- [ ] Confirmar alias `ac-gtr` → `acoustic-gtr` en runtime.
- [ ] Implementar los 4 presets.
- [ ] Añadir `tests/presets_guitar_acoustic.zsh`.

### Validación

```sh
./bin/reina run ac-gtr
./bin/reina info ac-gtr
```

### Cierre

4 presets `active`; alias `ac-gtr` funcional en ejecución real.

---

## Día 18 — Familia `keys-and-piano`

### Intención

Elevar la consciencia armónica: jazz, rock, cuerpo reforzado. Las teclas como territorio de lectura, no de corrección.

### Presets del día

| Prioridad | Slug | Variante |
| --- | --- | --- |
| 470 | `keys-riding-a-camel` | base |
| 480 | `jazz-piano` | jazz |
| 490 | `rock-piano` | rock |
| 500 | `piano-beef` | beef |

### Tareas

- [ ] Crear `lib/presets/families/keys-and-piano.zsh`.
- [ ] Implementar los 4 presets.
- [ ] Añadir `tests/presets_keys_and_piano.zsh`.

### Cierre

4 presets `active`.

---

## Día 19 — Familia `utility-texture-and-master`

### Intención

Cierre del ciclo: refresco, memoria lofi, sonrisa final. Purificar el máster; elevar la consciencia del conjunto.

### Presets del día

| Prioridad | Slug | Variante |
| --- | --- | --- |
| 510 | `camels-need-water` | refresh |
| 520 | `lofi-looper` | lofi |
| 530 | `master-smiley-face` | master |

### Tareas

- [ ] Crear `lib/presets/families/utility-texture-and-master.zsh`.
- [ ] Implementar `camels-need-water` como preset de recuperación/reset útil.
- [ ] Implementar `lofi-looper` y `master-smiley-face`.
- [ ] Añadir `tests/presets_utility_master.zsh`.

### Cierre

3 presets `active`; **53/53 presets implementados**.

---

## Día 20 — Consciencia de red y perfiles remotos

### Intención

Elevar la consciencia de la red del sonido más allá del preset aislado: la fuente conversa con contexto, memoria y entorno.

### Tareas

- [ ] Definir esquema de perfiles remotos en `${cache}/network` y `${config}/presets/`.
- [ ] Implementar fetch opcional de metadata/perfil por preset vía `reina_network_fetch_to_cache`.
- [ ] En `--offline`, degradar a cache sin romper la cadena sonora.
- [ ] Exponer en `reina run --json` el grafo de dependencias: familia, variantes hermanas, último snapshot.
- [ ] Comando exploratorio: `reina graph <preset>` o sección en `info` con relaciones de familia.
- [ ] Documentar en `docs/architecture.md` la noción de “consciencia de red”.
- [ ] Añadir `tests/network_consciousness.zsh`.

### Entregables

- La ejecución de un preset muestra su lugar en la red (familia, historial, fuente remota/local).
- Política offline-first demostrada con perfiles reales.

### Cierre

El operador no solo corre un preset: **ve** la red que lo sostiene.

---

## Día 21 — Purificación operativa y diagnóstico

### Intención

Purificar la mente de la fuente en uso diario: menos fricción, menos sorpresas, más claridad al abrir una sesión.

### Tareas

- [ ] Comando `reina doctor` — revisa runtime, permisos, dependencias (`zsh`, `curl`, helpers), integridad del manifiesto.
- [ ] Comando `reina history <preset>` — lectura humana del historial desde storage.
- [ ] Comando `reina snapshot <preset> list|restore` — gestión mínima de snapshots.
- [ ] Política de pruning documentada y comando `reina prune [--cache|--all]`.
- [ ] Añadir `tests/cli_doctor.zsh`.

### Cierre

El sistema se autoexamina y reporta con honestidad (`ok`, `degraded`, `failed`).

---

## Día 22 — Integración, licencia y release

### Intención

Cerrar un ciclo kundalini: lo purificado se sostiene; lo elevado se comparte con responsabilidad.

### Tareas

- [ ] Decidir licencia (MIT, Apache-2.0, GPL u otra) y añadir archivo `LICENSE`.
- [ ] Actualizar `docs/distribution.md` con política final.
- [ ] Cambiar `VERSION` de `0.4.0-dev` a `1.0.0`.
- [ ] Ejecutar `make dist` y verificar tarball.
- [ ] Ejecutar suite completa: `make test`.
- [ ] Revisar que los 53 presets están en `active` o justificar excepciones en el manifiesto.
- [ ] Redactar notas de release (`docs/RELEASE-1.0.0.md` o sección en README).

### Validación

```sh
make test
make dist
zsh tests/distribution_install.zsh
./bin/reina list --json | jq 'map(select(.status != "active")) | length'  # debe ser 0
```

### Cierre

Release `1.0.0` instalable, documentada y coherente con el propósito del proyecto.

---

## Resumen por fases

| Fase | Días | Foco | Presets |
| --- | --- | --- | --- |
| Integración | 0 | Merge a `main` | 0 |
| Infraestructura de preset | 6 | Dispatcher y contrato | 0 |
| Cuerpo sonoro | 7–19 | Familias del manifiesto | 53 |
| Consciencia de red | 20 | Perfiles, grafo, contexto | — |
| Purificación operativa | 21 | Doctor, historial, snapshots | — |
| Release | 22 | Licencia, 1.0.0 | — |

---

## Mapa de familias y presets

| Familia | Presets | Día |
| --- | ---: | ---: |
| `bass` | 5 | 7 |
| `low-end` | 3 | 8 |
| `vocals-atmospheric` | 4 | 9 |
| `female-vocal` | 3 | 10 |
| `vocal-utility` | 3 | 11 |
| `drum-bus` | 4 | 12 |
| `drum-experimental` | 4 | 13 |
| `drum-pieces-core` | 5 | 14 |
| `drum-detail-and-space` | 7 | 15 |
| `guitar-heavy-and-electric` | 5 | 16 |
| `guitar-acoustic-and-plucked` | 4 | 17 |
| `keys-and-piano` | 4 | 18 |
| `utility-texture-and-master` | 3 | 19 |
| **Total** | **53** | |

---

## Criterios transversales (todos los días)

Cada implementación debe cumplir:

1. **Purificación** — sin `curl` directo en presets; sin escritura fuera de `storage`; sin errores ad hoc fuera de `errors`.
2. **Elevación** — toda ejecución real deja rastro útil (historial o snapshot) salvo `--dry-run`.
3. **Honestidad** — `degraded` visible si hubo fallback; nunca exit 0 silencioso tras un fallo grave.
4. **Poética funcional** — el nombre del preset debe corresponder a un comportamiento distinguible, no a un alias cosmético.
5. **Tests** — cada familia nueva trae su archivo `tests/presets_<familia>.zsh`.
6. **Manifiesto** — `status` actualizado solo cuando la lógica es real.

---

## Nota final

Los Días 1–5 construyeron el sistema nervioso. Los Días 6–19 encarnan la red del sonido. Los Días 20–22 elevan la consciencia de esa red y la vuelven sostenible.

Hasta que `bass-in-the-desert` ejecute algo real, el proyecto tiene arquitectura pero aún no respira. El primer aliento es el Día 7; el primer despertar completo es el Día 19; la integración consciente es el Día 20.