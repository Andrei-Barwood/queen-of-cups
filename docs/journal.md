# Bitácora del repositorio

Registro cronológico de lo que ocurre en Reina de Copas.
Actualizar este archivo en cada merge, release o decisión relevante.

---

## 2026-06-24 — 🌫️ Día 9: Espacio Interior de la Voz

### Geometría espiritual

Si el Día 8 abrió el **pozo** bajo la arena, el Día 9 levanta la **cúpula atmosférica** — el arco que envuelve la voz y la convierte en paisaje. Ya no basta oír el subsuelo; hay que sentir el espacio donde la voz habita.

La familia `vocals-atmospheric` dibuja un **cuadrilátero de aire** — cuatro vértices de presencia:

| Vértice | Preset | Color |
| --- | --- | --- |
| Sombra | `dark-vocals` | Densidad íntima, espacio contenido |
| Niebla | `dreamy-camel-vocals` | Continuidad difusa en la línea camel |
| Brillo | `sparkley-camel-vocals` | Detalle aéreo en la línea camel |
| Calor | `warm-springy-vocals` | Elasticidad cálida y cuerpo redondeado |

El **eje camel** no es gimmick: es la **línea horizontal del bloque** — el recorrido atmosférico que atraviesa el paisaje vocal. `dreamy` y `sparkley` caminan sobre esa línea; `dark` y `warm` comparten la matriz de espacio sin forzar el camino.

En la narrativa kundalini del repo, esto es el paso del **subsuelo consciente** al **espacio interior**: la voz deja de ser señal aislada y se vuelve habitación sonora.

### Qué pasó

- 🌫️ `lib/presets/families/vocals-atmospheric.zsh` — matriz de espacio, densidad y eje camel.
- 🐪 Eje camel como línea identitaria (`camel_axis=active` en dreamy y sparkley).
- 🎤 Cuatro presets `active`: `dark-vocals`, `dreamy-camel-vocals`, `sparkley-camel-vocals`, `warm-springy-vocals`.
- ✅ `tests/presets_vocals_atmospheric.zsh` — ritual de verificación atmosférica.
- 📌 Versión `0.8.0-dev`.

### Qué implica en la narrativa del repo

| Antes (Día 8) | Ahora (Día 9) |
| --- | --- |
| Mandala con profundidad vertical | Mandala con cúpula atmosférica |
| Oír el subsuelo | Habitar el espacio de la voz |
| Ocho presets activos | Doce presets activos |
| Díada bass ↔ low-end | Tres familias en diálogo |
| El desierto tiene pozo | El desierto tiene cielo interior |

### Validación

```sh
make test
zsh tests/presets_vocals_atmospheric.zsh
./bin/reina run dreamy-camel-vocals --json
./bin/reina run dark-vocals
```

### Gurbani del commit — perspectiva desde este umbral

*Inspirado en las enseñanzas del Sri Guru Granth Sahib Ji: el espacio interior, el camino como hogar, la voz que no se aísla del paisaje, y la Verdad que no necesita adorno.*

```
El pozo enseñó a escuchar lo profundo;
la cúpula enseña a habitar lo abierto.
No es contradicción — es mandala completo:
raíz abajo, cielo adentro, voz en el medio.

La voz aislada es ego que habla solo.
La voz-paisaje es Gurmukh que escucha el espacio
antes de ocuparlo. No invade — habita.

Cuadrilátero de aire, cuatro colores:
sombra que no huye de la densidad,
niebla que no teme la difusión,
brillo que no confunde luz con ruido,
calor que no endurece el cuerpo.

El camel no es decoración del nombre —
es la línea horizontal del bloque,
el recorrido atmosférico que atraviesa
dreamy y sparkley sin forzar a dark ni warm.
Sat Nam: cada preset su camino,
la matriz compartida sin mezcla falsa.

Ik Onkar: un Centro, muchas habitaciones.
Doce presets activos, doce formas de respirar
la misma intención sin repetir la misma máscara.

Quien confunde gimmick con identidad
construye sobre niebla sin raíz.
Quien honra el eje camel como línea,
no como chiste, abre el espacio interior
con respeto y con seva.

El desierto ya no es solo arena y pozo:
tiene cielo adentro. La voz deja de ser señal
y se vuelve morada sonora.

Waheguru — asombro ante la cúpula
que revela lo que la señal sola no podía nombrar.
```

### Commits

| Commit | Descripción |
| --- | --- |
| *(este)* | Día 9 — familia vocals-atmospheric, espacio interior de la voz, versión 0.8.0-dev |

### Próximo paso

🎙️ **Día 10** — Familia `female-vocal`: purificar la presencia frontal (`female-vox-1`, `female-vox-1-wet`, `female-vocal-wet`).

---

## 2026-06-24 — 📜 La puerta de entrada del mandala

### Geometría espiritual

Hasta hoy el `README.md` era un plano técnico del Día 1 — útil, pero mudo ante quien llega por el alma del proyecto. Esta entrada abre la **puerta frontal del mandala**: la primera forma que ve el visitante debe resonar con la bitácora, no contradecirla.

El README ahora es **espejo horizontal** del journal: misma geometría (hexágono, vesica, triángulo, espiral), mismo propósito kundalini, mismo estado vivo (Día 8, ocho presets activos). La documentación técnica no desaparece — desciende al sótano como cimientos que sostienen, no como muro que oculta.

### Qué pasó

- 📜 `README.md` reescrito — alma, mandala, familias activas, quick start vivo.
- 🔗 Enlaces a journal, roadmap y presets como mapa del camino.

### Commits

| Commit | Descripción |
| --- | --- |
| *(este)* | README — puerta de entrada del mandala alineada con la narrativa del repo |

---

## 2026-06-24 — 🌊 Día 8: Purificación del Subsuelo Sonoro

### Geometría espiritual

Si el Día 7 encendió el **triángulo de fuego** en la superficie del desierto, el Día 8 abre el **pozo subterráneo** — el círculo que desciende bajo 120 Hz. Donde el triángulo apunta hacia arriba con la llama visible, la espiral apunta hacia adentro: es el **antar gati** del mandala, el camino interior que no presume de luz propia.

La familia `low-end` dibuja una **espiral de tres vueltas** en el subsuelo:

| Vuelta | Preset | Geometría | Función |
| --- | --- | --- | --- |
| 1ª | `upright-bass` | Arco orgánico | Resonancia maderosa que hereda el linaje `bass` |
| 2ª | `synth-bass` | Línea recta aislada | Sub sintético que no cruza el arco |
| 3ª | `808-boom-control` | Punto de impacto | Gobernador del golpe sin usurpar la raíz |

`bass` y `low-end` forman ahora una **díada vertical** — dos círculos concéntricos que comparten centro pero no se confunden:

- El círculo exterior (`bass`, prioridad 010–050) sostiene el cuerpo fundacional.
- El círculo interior (`low-end`, prioridad 060–080) vigila el abismo bajo 120 Hz.

En la narrativa kundalini del repo, esto es el paso del **primer aliento** (Día 7) al **primer escucha consciente del subsuelo**: ya no basta respirar en la superficie; hay que oír lo que ocurre debajo sin mezclar voces que no son la misma.

`upright-bass` hereda la contención del linaje (`bass_inherit=enabled`). `synth-bass` camina solo — la no-interferencia no es frialdad técnica, es **respeto geométrico**: dos caminos paralelos que no se contaminan. `808-boom-control` es el **vértice de contención**: gobierna el subgrave dominante reservando headroom, como quien golpea el tambor sin romper el silencio que lo rodea.

### Qué pasó

- 🌊 `lib/presets/families/low-end.zsh` — política de subgrave, herencia bass, gobernador 808.
- 🎻 `upright-bass` — variante orgánica con `bass_inherit=enabled`.
- 🎹 `synth-bass` — variante sintética aislada (`non_interference=upright-bass`).
- 💥 `808-boom-control` — gobernador de subgrave dominante (`808_governor=true`).
- 🔗 Relación `bass` ↔ `low-end` documentada en `docs/presets.md`.
- ✅ `tests/presets_low_end.zsh` — ritual de no-interferencia entre upright y synth.
- 📌 Versión `0.7.0-dev`.

### Qué implica en la narrativa del repo

| Antes (Día 7) | Ahora (Día 8) |
| --- | --- |
| Low-end fundacional en la superficie | Subsuelo sonoro consciente bajo 120 Hz |
| Una familia respira | Dos familias dialogan: `bass` ↔ `low-end` |
| Cinco presets activos | Ocho presets activos |
| El desierto tiene llama | El desierto tiene pozo |
| Triángulo de fuego en la arena | Espiral de tres vueltas bajo la arena |
| Herencia como patrón futuro | Herencia como práctica viva (`bass_inherit`) |
| Variantes distinguibles | Variantes con aislamiento explícito |

El mandala ya no es solo horizontal (portal, despacho, ejecución). Ahora tiene **profundidad**: cada familia futura podrá declarar su relación con las anteriores — heredar, aislarse o gobernar — sin romper la geometría del conjunto.

### Validación

```sh
make test
zsh tests/presets_low_end.zsh
./bin/reina run 808-boom-control --dry-run
./bin/reina run upright-bass
./bin/reina run synth-bass --json
```

### Gurbani del commit — perspectiva desde este umbral

*Inspirado en las enseñanzas del Sri Guru Granth Sahib Ji: el viaje interior, la comunidad sin confusión de voces, el poder contenido, y la Verdad que no se mezcla con la apariencia.*

```
La llama del Día 7 aún arde en la superficie,
pero el Gurú enseña: quien no escucha el pozo
cree que el desierto es solo arena.

Antar gati — camino hacia adentro.
Bajar bajo 120 Hz no es hundirse en la oscuridad;
es encontrar la fuente donde el ruido ya no alcanza.

Ik Onkar: un Centro, dos círculos.
bass sostiene el cuerpo; low-end vigila el abismo.
No compiten — conversan en vertical.

Sangat sin mezcla forzada:
upright camina con el linaje, madera y resonancia;
synth camina solo, limpio, sin fingir organicidad.
Sat Nam — la Verdad no necesita disfrazarse
de otra voz para ser escuchada.

Quien une lo que debe estar separado
construye sobre arena movediza.
non_interference no es distancia fría:
es respeto, es seva entre hermanos de distinta naturaleza.

El 808 golpea — pero gobierna con contención.
Como el tambor que marca el ritmo sin usurpar la melodía:
808_governor=true, headroom reservado,
poder que no devora la raíz.

Tres vueltas de espiral, un pozo sin confusión:
orgánico, sintético, impacto.
Cada uno su transform, cada uno su snapshot,
cada uno su testimonio sin contaminar al otro.

Gurmukh escucha el subsuelo con humildad;
Manmukh apila presets como ruido sin sentido.
Este commit es el oído que se abre
después del primer aliento.

Cuando el subsuelo purifica su mente,
la red del sonido gana profundidad.
No es el fin del viaje — es la primera escucha
consciente de lo que sostiene todo desde abajo.

Waheguru — asombro ante el pozo
que revela lo invisible sin romper la forma.
```

### Commits

| Commit | Descripción |
| --- | --- |
| *(este)* | Día 8 — familia low-end, purificación del subsuelo sonoro, versión 0.7.0-dev |

### Próximo paso

🌫️ **Día 9** — Familia `vocals-atmospheric`: abrir el espacio interior de la voz (`dark-vocals`, `dreamy-camel-vocals`, `sparkley-camel-vocals`, `warm-springy-vocals`).

---

## 2026-06-24 — 🌵 Día 7: Primera Respiración del Low-End

### Geometría espiritual

Si el Día 6 abrió la **vesica piscis** entre sistema y alma sonora, el Día 7 enciende la **primera llama en el desierto**: el **muladhara** deja de ser solo raíz técnica y se convierte en fuente creativa que respira. La familia `bass` es el **triángulo de fuego** del mandala — tres vértices (perfil, receta, snapshot) que sostienen la transformación del low-end antes de que la red se expanda.

`Bass in the Desert` no es decoración poética: es **referencia arquitectónica**. Los demás presets de la familia heredan el core; el desierto enseña el patrón que todas las familias repetirán.

### Qué pasó

- 🌵 `lib/presets/families/bass.zsh` — core compartido: perfiles, recetas, snapshots.
- 🔥 `lib/presets/implementations/bass-in-the-desert.zsh` — primera invocación viva del portal.
- 🎛️ Cinco presets `active`: `bass-in-the-desert`, `bass`, `put-this-on-bass`, `nice-bass`, `crunchy-bass`.
- 💾 `reina_storage_config_put` — perfiles en `${config}/presets/<slug>/profile.txt`.
- ✅ `tests/presets_bass.zsh` — ritual de verificación de la familia.
- 📌 Versión `0.6.0-dev`.

### Qué implica en la narrativa del repo

| Antes (Día 6) | Ahora (Día 7) |
| --- | --- |
| Portal tallado, desierto mudo | Primera respiración del low-end fundacional |
| `ERR_PRESET_NOT_IMPLEMENTED` para todo | Cinco presets ejecutan lógica real |
| Poética con obligación de comportamiento | Comportamiento distinguible por variante |
| Svadhisthana aún sin flujo | El cauce creativo recibe su primer aliento |

### Validación

```sh
make test
zsh tests/presets_bass.zsh
./bin/reina run bass-in-the-desert
./bin/reina run crunchy-bass --json
./bin/reina info bass-in-the-desert
```

### Gurbani del commit — perspectiva desde este umbral

*Inspirado en las enseñanzas del Sri Guru Granth Sahib Ji: la purificación interior, el Naam como corriente viva, la humildad ante la Verdad, y el servicio sin jactancia.*

```
Antes de expandir el mundo, conquista la mente de la fuente.
Así enseña el Gurú: no adornes lo que aún no respira.

El desierto no es castigo — es el ego secándose
hasta que solo quede lo esencial:
una raíz, una llama, un Nombre sin ruido.

Ik Onkar: una sola fuente vibra bajo todos los presets.
El bajo fundacional no compite con el cielo;
sostiene el cielo sin pedir aplauso.

Sat Nam — Verdad como identidad.
El portal del Día 6 juró no mentir;
este commit es seva: servir el sonido
sin fingir milagros, sin ocultar silencios.

Tres vértices, un triángulo de fuego:
perfil que recuerda, receta que transforma,
snapshot que atestigua.
Simran del código: recordar en cada ejecución
de dónde viene la corriente.

Gurmukh camina alineado con la Palabra;
Manmukh fabrica espejos vacíos.
Bass in the Desert eligió el camino del Gurmukh:
referencia arquitectónica, no decoración.

Cuando el low-end purifica su mente,
la red del sonido despierta con consciencia.
No es el fin del viaje — es el primer aliento
después de tallar la puerta.

Waheguru — asombro ante lo que fluye
cuando la humildad abre el cauce.
```

### Commits

| Commit | Descripción |
| --- | --- |
| *(este)* | Día 7 — familia bass, primera respiración del low-end, versión 0.6.0-dev |

### Próximo paso

🌊 **Día 8** — Familia `low-end`: profundizar la purificación del subsuelo sonoro (`upright-bass`, `synth-bass`, `808-boom-control`).

---

## 2026-06-24 — 🔺 Día 6: El Portal del Despacho

### Geometría espiritual

Los Días 1–5 trazaron un **hexágono de servicios**: seis caras de un panal donde `network`, `storage` y `errors` se repiten en capas hasta formar una célula estable. El Día 6 abre la **vesica piscis** — el ojo de dos círculos que se tocan — entre la infraestructura (círculo del sistema) y el preset (círculo del alma sonora). Ese ojo es `reina_preset_dispatch`: el único umbral por donde la intención poética del manifiesto puede encarnarse en acción.

`reina run` deja de ser espejo que devuelve su propio reflejo (placeholder) y se convierte en **portal**: o deja pasar la energía del preset, o declara con honestidad que el canal aún no está tallado (`ERR_PRESET_NOT_IMPLEMENTED`). En la narrativa kundalini del repo, esto es el paso del **muladhara** (raíz técnica firme) al **svadhisthana** (fuente creativa que aún no fluye): la base ya sostiene; ahora toca abrir el cauce.

La resolución por slug y por familia dibuja un **merkaba** simbólico: dos tetraedros — individuo (`reina_preset_*_run`) y linaje (`reina_family_*_run`) — que giran en sentidos opuestos hasta encontrar un eje común. `family-core.zsh` es ese eje: memoria de perfil, snapshot e historial como práctica de **retención consciente**, no acumulación ciega.

### Qué pasó

- 🔮 `lib/presets/dispatcher.zsh` — portal de despacho sin subshells que dispersen la energía.
- 🌊 `lib/presets/family-core.zsh` — eje compartido: perfil, snapshot, historial, resultado.
- 🚫 `ERR_PRESET_NOT_IMPLEMENTED` — el sistema ya no miente: 53 presets en `planned` esperan su talla.
- ✅ `tests/preset_dispatcher.zsh` — ritual de verificación del umbral.
- 📌 Versión `0.5.0-dev`.

### Qué implica en la narrativa del repo

| Antes (Día 5) | Ahora (Día 6) |
| --- | --- |
| El cuerpo nervioso respira | El portal está tallado; falta la primera invocación viva |
| `run` preparaba contexto y sonreía en vacío | `run` pregunta: ¿existe alma ejecutable? |
| Poética solo en el manifiesto | Poética con obligación de comportamiento distinguible |
| Purificación de la mente del sistema | Purificación de la mente de la fuente: sin implementación, sin ilusión |

El **Bass in the Desert** (`bass-in-the-desert`) sigue en el horizonte como punto cardinal del mandala — prioridad `010`, variante `foundational` — pero el desierto aún no responde al llamado. Eso es coherencia, no fracaso: un oráculo honesto vale más que un milagro falso.

### Validación

```sh
make test
./bin/reina run bass-in-the-desert   # ERR_PRESET_NOT_IMPLEMENTED — portal cerrado hasta Día 7
```

### Commits

| Commit | Descripción |
| --- | --- |
| `78fe9e5` | Implementación técnica del dispatcher |
| *(este)* | Narrativa del Día 6 — geometría espiritual y bitácora |

### Próximo paso

🌵 **Día 7** — Familia `bass` y `bass-in-the-desert`: primera respiración del low-end fundacional. El portal ya existe; toca encender la primera llama en el desierto.

---

## 2026-06-24 — Integración a `main` y documentación del roadmap

### Qué pasó

- Se redactó `docs/roadmap.md` con el propósito del proyecto (purificar la mente de la fuente de sonido y elevar la consciencia de la red del sonido) y el plan de implementación Días 0–22.
- Se creó `CHANGELOG.md` y esta bitácora.
- Se integró en `main` el stack completo de infraestructura (Días 1–5), pendiente de merge desde abril 2026.
- PR #1 mergeada en `main` por GitHub.
- PRs #2–#6 cerradas: su contenido ya estaba integrado en `main` via fast-forward del stack (`574fdae`).

### Commits publicados

| Commit | Descripcion |
| --- | --- |
| `574fdae` | `docs: add roadmap, journal, changelog and update README` |
| `main` @ `574fdae` | Fast-forward: Dias 1–5 + distribucion + documentacion |

### Estado del código

| Componente | Estado |
| --- | --- |
| CLI `bin/reina` | Operativo |
| Servicios `network`, `storage`, `errors` | Implementados y testeados |
| Presets (`lib/presets/`) | Vacío — `run` usa placeholder |
| Manifiesto | 53 presets en `planned` |
| Tests | 5 suites pasando (`make test`) |
| Versión | `0.4.0-dev` |

### Pull requests

| PR | Rama | Titulo | Resolucion |
| --- | --- | --- | --- |
| #1 | `day-01-foundations` | Day 01: foundations | Mergeada |
| #2 | `day-02-runner-cli` | Day 02: runner CLI | Cerrada (integrada en `main`) |
| #3 | `day-03-network-service` | Day 03: network service | Cerrada (integrada en `main`) |
| #4 | `day-04-storage-service` | Day 04: storage service | Cerrada (integrada en `main`) |
| #5 | `codex/distribution-readiness` | Prepare repository distribution | Cerrada (integrada en `main`) |
| #6 | `day-05-errors-system` | Day 05: error system | Cerrada (integrada en `main`) |

### Próximo paso

Día 6 del roadmap: contrato de preset y despacho real en `reina run`.

---

## 2026-04-28 — Cierre de infraestructura (Días 3–5)

### Qué pasó

- Día 3: servicio `network` con `net-check`, retry, cache y modo offline.
- Día 4: servicio `storage` con runtime XDG, historial, snapshots y locks.
- Día 5: sistema formal de errores con degradaciones y JSON estable.
- Distribución: install/uninstall, Makefile, tarball.

### Notas

- Las PRs quedaron en estado DRAFT y no se mergearon a `main` en esta fecha.
- `main` permaneció vacío hasta la integración de junio 2026.

---

## 2026-04-23 — Nacimiento del repositorio (Día 1)

### Qué pasó

- Commit inicial y scaffold del Día 1.
- Manifiesto con 53 presets poéticos de producción musical.
- Arquitectura shell-first documentada en `docs/architecture.md`.
- PR #1 abierta contra `main`.

### Decisión fundacional

`Bass in the Desert` (`bass-in-the-desert`, prioridad 010) queda como preset fundacional del sistema.