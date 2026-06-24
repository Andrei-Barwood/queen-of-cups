# 🏜️ Reina de Copas

*Un CLI shell-first que convierte un catálogo poético de presets en comandos vivos de `zsh` — con un corazón compartido para `network`, `storage` y `errors`.*

---

## Alma del proyecto

Reina de Copas no es solo un catálogo ni una caja de herramientas. Su propósito es análogo al **kundalini yoga** aplicado a la red del sonido:

| Movimiento | En el ser humano | En Reina de Copas |
| --- | --- | --- |
| **Purificar** | La mente | La **mente de la fuente de sonido** — quitar hábito automático, ruido y decisión reactiva |
| **Elevar** | La consciencia | La **consciencia de la red del sonido** — ver cómo fluye la señal, qué se degrada, qué intención sostiene cada preset |

Nombres como `Bass in the Desert`, `dreamy-camel-vocals` o `camels-need-water` no son decoración: nombran **estados de consciencia sonora** que el código debe poder invocar con intención — o declarar con honestidad que aún no respiran.

---

## Geometría del mandala

El repositorio avanza por días. Cada día talla una forma nueva en el mismo centro:

```
Días 1–5   ⬡  Hexágono de servicios — network, storage, errors
Día 6      ◉  Vesica piscis — el portal entre sistema y alma sonora
Día 7      🔺 Triángulo de fuego — la familia bass respira en el desierto
Día 8      🌀 Espiral hacia adentro — la familia low-end abre el pozo bajo 120 Hz
Día 9      🌫️ Cúpula atmosférica — la familia vocals-atmospheric abre el espacio de la voz
Día 10     🎙️ Flecha frontal — la familia female-vocal purifica la presencia sin máscara
Día 11     🛠️ Triángulo operativo — la familia vocal-utility asiste y diagnostica
Día 12     🥁 Cuadrado del pulso — la familia drum-bus unifica el colectivo rítmico
Día 13     🎛️ Octágono experimental — capas paralelas con degradación segura
Día 14     🥾 Punto cardinal — la familia drum-pieces-core ancla kick y snare
Día 15     🌬️ Hexágono del aire — la familia drum-detail-and-space abre overheads, room y fills
Día 16     ⚡ Pentágono eléctrico — la familia guitar-heavy-and-electric carga drive y cuerpo metálico
```

**Versión actual:** `0.15.0-dev` · **Día 16** · **42 presets activos** de 53 en el manifiesto.

El preset fundacional sigue siendo [**Bass in the Desert**](presets/manifest.tsv) (`bass-in-the-desert`, prioridad 010): la primera llama en la arena y la referencia arquitectónica de todo lo que viene después.

### Familias que ya respiran

| Familia | Presets activos | Geometría |
| --- | --- | --- |
| `bass` | `bass-in-the-desert`, `bass`, `put-this-on-bass`, `nice-bass`, `crunchy-bass` | Triángulo de fuego — perfil, receta, snapshot |
| `low-end` | `upright-bass`, `synth-bass`, `808-boom-control` | Espiral de tres vueltas — orgánico, sintético, impacto |
| `vocals-atmospheric` | `dark-vocals`, `dreamy-camel-vocals`, `sparkley-camel-vocals`, `warm-springy-vocals` | Cuadrilátero de aire — sombra, niebla, brillo, calor |
| `female-vocal` | `female-vox-1`, `female-vox-1-wet`, `female-vocal-wet` | Flecha frontal — dry → wet → wet-wide |
| `vocal-utility` | `pop-lead-vocal`, `vocal-help`, `give-backgrounds-some-life` | Triángulo operativo — lead, assist, background |
| `drum-bus` | `drum-bus-drivin`, `drum-bus-island`, `drum-bus-wild-spring-camel`, `drum-bus-magic` | Cuadrado del pulso — drive, spaced, wild, glue |
| `drum-experimental` | `parallel-processing-drums`, `myon-pop-parallel-magic`, `wildin-camel-drums`, `wierdly-gated-drums` | Octágono del riesgo — parallel, pop, wild, gated |
| `drum-pieces-core` | `kick`, `kick-2`, `snare`, `urban-snare`, `urban-snare-tighter` | Punto cardinal — anchor, accent, variantes semánticas |
| `drum-detail-and-space` | `hats`, `drums-overheads`, `ohs`, `trash-drum-room`, `drum-room-smash`, `fill-kollin` | Hexágono del aire — detail, overheads, room, fill |
| `guitar-heavy-and-electric` | `heavy-bright-guitar`, `heavy-guitar-with-reverb`, `wildin-camel-guitar`, `el-gtr-driver`, `gtr` | Pentágono eléctrico — bright, reverb, wild, driver, base |

Las familias de batería van del **cuadrado** al **octágono** al **punto cardinal** al **hexágono del aire**. La primera familia de cuerdas enciende el **pentágono eléctrico** — `gtr` y `el-gtr-driver` son presets distintos.

Los **11 presets restantes** aguardan su talla en el roadmap. El portal no miente: si no hay implementación, responde `ERR_PRESET_NOT_IMPLEMENTED`.

---

## Primer contacto

```sh
./bin/reina help
./bin/reina version
./bin/reina list
./bin/reina info bass-in-the-desert
```

Invoca el desierto — primera respiración real del low-end:

```sh
./bin/reina run bass-in-the-desert
./bin/reina run crunchy-bass --json
./bin/reina run 808-boom-control --dry-run
```

Escucha el subsuelo y habita el espacio de la voz:

```sh
./bin/reina run upright-bass
./bin/reina run dreamy-camel-vocals --json
./bin/reina run dark-vocals
./bin/reina run female-vox-1
./bin/reina run female-vocal-wet --json
./bin/reina run vocal-help
./bin/reina run vocal-help --json
./bin/reina run drum-bus-drivin
./bin/reina run drum-bus-wild-spring-camel --json
./bin/reina run parallel-processing-drums
./bin/reina --offline run parallel-processing-drums
./bin/reina run kick
./bin/reina run snare --json
./bin/reina net-check --offline
```

Ritual de verificación completo:

```sh
make test
```

---

## Instalación

```sh
make install PREFIX="$HOME/.local"
reina version
```

Copia el árbol a `$PREFIX/lib/reina-de-copas` y crea el comando `$PREFIX/bin/reina`.

```sh
make uninstall PREFIX="$HOME/.local"
```

Generar tarball local:

```sh
make dist
```

---

## Cimientos técnicos

Decisiones que sostienen la geometría:

- **`zsh >= 5.4`** — shell-first, helpers externos pequeños cuando simplifican el core
- **`presets/manifest.tsv`** — fuente de verdad del catálogo; slugs en `kebab-case`
- **Servicios compartidos** — `network`, `storage`, `errors`; los presets no reinventan esas capas
- **Runtime XDG** — con fallback local en `.reina/` y raíces configurables (`REINA_CONFIG_ROOT`, `REINA_CACHE_ROOT`, `REINA_STATE_ROOT`)
- **Errores honestos** — estados `ok`, `degraded`, `failed`; JSON estable; el runner no finge éxito
- **Flags globales** — `--debug`, `--offline`, `--quiet`, `--json`, `--dry-run`

Estructura del repositorio:

```text
bin/reina          → portal de entrada
lib/core/          → bootstrap, manifiesto, contexto
lib/presets/       → dispatcher, familias, implementaciones
lib/services/      → network, storage, errors
presets/           → manifest.tsv, aliases.tsv
tests/             → rituales de verificación
docs/              → arquitectura, roadmap, bitácora
```

Convenciones: funciones con prefijo `reina_`; familias y variantes definidas en el manifiesto; `shellcheck` y `shfmt` recomendados cuando estén instalados.

---

## Documentación

| Archivo | Para qué |
| --- | --- |
| [`docs/journal.md`](docs/journal.md) | Bitácora viva — geometría espiritual, commits, poesía del camino |
| [`docs/roadmap.md`](docs/roadmap.md) | Plan Días 0–22: purificación y elevación paso a paso |
| [`docs/architecture.md`](docs/architecture.md) | Contratos de servicios, runtime, exit codes |
| [`docs/presets.md`](docs/presets.md) | Familias, variantes, semántica de transformación |
| [`docs/distribution.md`](docs/distribution.md) | Instalación y empaquetado |
| [`CHANGELOG.md`](CHANGELOG.md) | Historial por versión |

---

## Estado del mandala

| Capa | Estado |
| --- | --- |
| Infraestructura (Días 1–5) | ✅ Integrada en `main` |
| Portal de despacho (Día 6) | ✅ `reina run` ejecuta o declara con honestidad |
| Familia `bass` (Día 7) | ✅ 5 presets `active` |
| Familia `low-end` (Día 8) | ✅ 3 presets `active` |
| Familia `vocals-atmospheric` (Día 9) | ✅ 4 presets `active` |
| Familia `female-vocal` (Día 10) | ✅ 3 presets `active` |
| Familia `vocal-utility` (Día 11) | ✅ 3 presets `active` |
| Familia `drum-bus` (Día 12) | ✅ 4 presets `active` |
| Familia `drum-experimental` (Día 13) | ✅ 4 presets `active` |
| Familia `drum-pieces-core` (Día 14) | ✅ 5 presets `active` |
| Familia `drum-detail-and-space` (Día 15) | ✅ 6 presets `active` |
| Familia `guitar-heavy-and-electric` (Día 16) | ✅ 5 presets `active` |
| Resto del catálogo | 🪕 En `planned` — Días 17–19 por delante |

---

*El desierto ya tiene llama, pozo, cielo interior, flecha frontal, triángulo operativo, cuadrado del pulso, octágono experimental, punto cardinal, hexágono del aire y pentágono eléctrico. Lo que sigue es la cuerda resonante.*

🪕 **Próximo paso:** Día 17 — familia `guitar-acoustic-and-plucked`