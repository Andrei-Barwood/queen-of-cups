# Presets y naming

`presets/manifest.tsv` es la fuente de verdad del catalogo.

## Campos oficiales

| Campo | Regla |
| --- | --- |
| `display_name` | nombre visible y humano del preset |
| `slug` | identificador publico, unico, estable, ASCII y `kebab-case` |
| `family` | familia tecnica que comparte core o heuristicas |
| `variant` | rol semantico dentro de la familia |
| `status` | estado de lifecycle: `planned`, `beta`, `active`, `deprecated` |
| `priority` | orden numerico de construccion; menor numero = antes |
| `aliases` | aliases explicitos separados por `|`; `-` significa ninguno |
| `notes` | contexto corto y util para roadmap o decisiones de diseno |

## Convencion de slugs

- siempre ASCII
- siempre `kebab-case`
- nunca se reciclan
- nunca dependen de detalles cosmeticos del `display_name`

## Politica de duplicados y ambiguedad

- Si dos nombres son la misma idea con otra ortografia o abreviatura, se conserva un solo preset y el resto se convierte en alias.
- Si dos nombres describen comportamientos distintos, se crean slugs distintos y variantes semanticas.
- Los sufijos numericos solo se permiten como placeholder temporal cuando todavia no existe una diferencia funcional clara.
- En cuanto aparezca una diferencia real, el proyecto prefiere variantes semanticas sobre numericas.

## Decisiones aplicadas hoy

- `Bass in the Desert` queda como `bass-in-the-desert`.
- `Bass in the Desert` queda marcado como preset fundacional mediante prioridad `010` y nota explicita en el manifiesto.
- La familia de `kick` se estabiliza en `kick` y `kick-2`; no se mantiene una serie abierta `kick-01`, `kick-02`, `kick-03` si no hay tres comportamientos vivos.
- La familia de `snare` se expresa semanticamente como `snare`, `urban-snare` y `urban-snare-tighter`.
- `synth bass` queda hoy como un solo preset canonico: `synth-bass`.
- `synth-bass-01` y `synth-bass-02` quedan reservados solo para el caso de que la familia se bifurque de verdad mas adelante.
- `ac gtr` no nace como segundo preset: queda como alias explicito de `acoustic-gtr`.
- `ohs` se mantiene como preset propio y no como alias de `drums-overheads`, porque ya se describe como variante compacta con funcion distinta.

## Familias registradas

- `bass`: `bass-in-the-desert`, `bass`, `put-this-on-bass`, `nice-bass`, `crunchy-bass`
- `low-end`: `upright-bass`, `synth-bass`, `808-boom-control`
- `vocals-atmospheric`: `dark-vocals`, `dreamy-camel-vocals`, `sparkley-camel-vocals`, `warm-springy-vocals`
- `female-vocal`: `female-vox-1`, `female-vox-1-wet`, `female-vocal-wet`
- `vocal-utility`: `pop-lead-vocal`, `vocal-help`, `give-backgrounds-some-life`
- `drum-bus`: `drum-bus-drivin`, `drum-bus-island`, `drum-bus-wild-spring-camel`, `drum-bus-magic`
- `drum-experimental`: `parallel-processing-drums`, `myon-pop-parallel-magic`, `wildin-camel-drums`, `wierdly-gated-drums`
- `drum-pieces-core`: `kick`, `kick-2`, `snare`, `urban-snare`, `urban-snare-tighter`
- `drum-detail-and-space`: `hats`, `drums-overheads`, `ohs`, `trash-drum-room`, `drum-room-smash`, `fill-kollin`
- `guitar-heavy-and-electric`: `heavy-bright-guitar`, `heavy-guitar-with-reverb`, `wildin-camel-guitar`, `el-gtr-driver`, `gtr`
- `guitar-acoustic-and-plucked`: `acoustic-guitar-wet`, `acoustic-gtr`, `muted-cuatro`, `muted-cuatro-wet`
- `keys-and-piano`: `keys-riding-a-camel`, `jazz-piano`, `rock-piano`, `piano-beef`
- `utility-texture-and-master`: `camels-need-water`, `lofi-looper`, `master-smiley-face`

## Alias policy

- Los aliases excepcionales se registran en `presets/aliases.tsv`.
- El manifiesto mantiene una vista compacta de aliases por preset.
- El runner del Dia 2 resuelve `slug`, alias explicito y `display_name` normalizado cuando no introduzca ambiguedad.
- Si un alias o nombre normalizado apunta a mas de una entrada, el runner debe fallar con `ERR_PRESET_ALIAS_AMBIGUOUS`.
- Si no hay coincidencia, el runner debe fallar con `ERR_PRESET_NOT_FOUND`.

## Comandos de inspeccion

```sh
reina list
reina list --json
reina info bass-in-the-desert
reina info ac-gtr
reina run bass-in-the-desert --dry-run
```

`reina info <preset>` muestra la ficha del manifiesto. `reina run <preset>` usa esa misma resolucion, prepara el contexto compartido y despacha la implementacion real del preset.

## Ciclo de vida

| Status | Significado |
| --- | --- |
| `planned` | catalogado en el manifiesto; sin implementacion |
| `beta` | implementacion experimental disponible |
| `active` | implementacion estable y soportada |
| `deprecated` | aun ejecutable, pero en retiro |

Regla del Dia 6: si no existe runner para el preset, `reina run` falla con `ERR_PRESET_NOT_IMPLEMENTED` aunque el manifiesto lo conozca. No se finge exito.

## Contrato de implementacion

### Despacho

`lib/presets/dispatcher.zsh` resuelve el runner en este orden:

1. funcion `reina_preset_<slug>_run` ya cargada
2. archivo `lib/presets/implementations/<slug>.zsh`
3. funcion `reina_family_<family>_run` ya cargada
4. archivo `lib/presets/families/<family>.zsh`

`<slug>` y `<family>` usan guiones en rutas de archivo. Las funciones convierten guiones a guiones bajos.

Ejemplos:

- slug `bass-in-the-desert` -> `reina_preset_bass_in_the_desert_run`
- familia `vocals-atmospheric` -> `reina_family_vocals_atmospheric_run`

### Entrada del runner

Todo preset recibe el contexto ya preparado por el runner:

- metadata del manifiesto en `REINA_PRESET_*`
- servicios compartidos `network`, `storage`, `errors`
- flags globales (`REINA_DEBUG`, `REINA_OFFLINE`, `REINA_QUIET`, `REINA_JSON`, `REINA_DRY_RUN`)

Los presets no deben invocar `curl`, escribir fuera de `storage` ni emitir errores fuera de `errors`.

### Salida del runner

El runner debe terminar con:

- `reina_preset_set_result <ok|degraded|failed> <message> <implementation>`
- exit code `0` para `ok` o `degraded`
- exit code distinto de `0` para `failed`

Helpers compartidos en `lib/presets/family-core.zsh`:

- `reina_preset_profile_get` / `reina_preset_profile_put`
- `reina_preset_snapshot_record`
- `reina_preset_history_record` (el runner principal ya registra historial tras un despacho exitoso)

### Estructura recomendada

```text
lib/presets/
  dispatcher.zsh
  family-core.zsh
  implementations/
    <slug>.zsh
  families/
    <family>.zsh
```

### Validacion minima

```sh
zsh tests/preset_dispatcher.zsh
zsh tests/presets_bass.zsh
./bin/reina run bass-in-the-desert
./bin/reina run crunchy-bass --json
./bin/reina info bass-in-the-desert
```

## Familia `bass` (Dia 7)

Primera familia implementada. Demuestra el patron que el resto de familias repetira:

- core compartido en `lib/presets/families/bass.zsh`
- referencia arquitectonica por slug en `lib/presets/implementations/bass-in-the-desert.zsh`
- variantes heredadas via `reina_family_bass_run` cuando no existe runner por slug

### Semantica de transformacion

| Variante | Label | Intencion de senal |
| --- | --- | --- |
| `foundational` | desert | Low-end seco y respirable: fundamental ancha, armonicos dispersos, transientes secos. El "desierto" es espacio, no vacio. |
| `base` | base | Cadena neutra: contencion suave de sub, EQ equilibrada, dinamica transparente. |
| `utility` | utility | Cadena directa y opinionada: high-pass, compresion, saturacion ligera. |
| `smooth` | nice | Compresion amable, transientes redondeados, brillo contenido. |
| `aggressive` | crunchy | Saturacion armonica, presencia media, mordida en el ataque. |

Cada ejecucion real (sin `--dry-run`):

1. asegura un perfil en `${config}/presets/<slug>/profile.txt`
2. construye una receta de transformacion y la guarda como snapshot
3. registra historial via el runner principal

## Familia `low-end` (Dia 8)

Segunda familia implementada. Profundiza el subsuelo sonoro bajo 120 Hz en dialogo con `bass`:

| Familia | Rol | Prioridad |
| --- | --- | --- |
| `bass` | Low-end fundacional y generalista | 010–050 |
| `low-end` | Organicidad, sintesis e impacto controlado | 060–080 |

- core compartido en `lib/presets/families/low-end.zsh`
- variantes via `reina_family_low_end_run`
- `upright-bass` hereda contencion del core `bass`; `synth-bass` permanece aislado

### Politica de subgrave

| Variante | Preset | Contencion | Headroom | Relacion con `bass` |
| --- | --- | --- | --- | --- |
| `organic` | `upright-bass` | gentle | 7 dB | hereda contencion (`bass_inherit=enabled`) |
| `synthetic` | `synth-bass` | moderate | 5 dB | aislado (`non_interference=upright-bass`) |
| `impact` | `808-boom-control` | firm | 4 dB | gobernador de sub (`808_governor=true`) |

`808-boom-control` coordina el subgrave dominante sin anular el cuerpo mid-bass que `bass` sostiene. `synth-bass` y `upright-bass` usan transformaciones y perfiles disjuntos para evitar interferencia cruzada.

### Semantica de transformacion

| Variante | Label | Intencion de senal |
| --- | --- | --- |
| `organic` | upright | Cuerpo resonante, armonicos maderosos, sub natural con herencia bass |
| `synthetic` | synth | Sub sintetico limpio, armonicos controlados, sin resonancia organica |
| `impact` | 808 | Golpe de sub dominante con contencion firme y headroom reservado |

### Validacion

```sh
zsh tests/presets_low_end.zsh
./bin/reina run 808-boom-control --dry-run
./bin/reina run upright-bass
./bin/reina run synth-bass --json
```

## Familia `vocals-atmospheric` (Dia 9)

Tercera familia implementada. Abre la voz como paisaje atmosferico, no como señal aislada.

- core compartido en `lib/presets/families/vocals-atmospheric.zsh`
- matriz compartida de espacio y densidad: `space_width`, `space_depth`, `vocal_density`, `continuity`
- variantes via `reina_family_vocals_atmospheric_run`

### Eje camel

El **camel** no es gimmick: nombra la **linea de continuidad atmosferica** — la voz que atraviesa un espacio en lugar de posarse sobre el.

| Preset | Eje camel | Rol |
| --- | --- | --- |
| `dreamy-camel-vocals` | `camel_axis=active` | Paisaje continuo y difuso |
| `sparkley-camel-vocals` | `camel_axis=active` | Brillo fino y detalle aereo |
| `dark-vocals` | `camel_axis=latent` | Sombra intima sin forzar recorrido camel |
| `warm-springy-vocals` | `camel_axis=latent` | Calidez elastica en la matriz compartida |

### Semantica de transformacion

| Variante | Label | Intencion de senal |
| --- | --- | --- |
| `dark` | dark | Sombra, densidad, presencia intima |
| `dreamy` | dreamy-camel | Atmosfera continua en la linea camel |
| `sparkly` | sparkley-camel | Brillo fino y detalle aereo en la linea camel |
| `warm` | warm-springy | Calidez elastica y cuerpo vocal redondeado |

### Validacion

```sh
zsh tests/presets_vocals_atmospheric.zsh
./bin/reina run dreamy-camel-vocals --json
./bin/reina run dark-vocals
./bin/reina run sparkley-camel-vocals
```

## Familia `female-vocal` (Dia 10)

Cuarta familia implementada. Purifica la presencia frontal de la voz femenina con verdad timbral.

- core compartido en `lib/presets/families/female-vocal.zsh`
- variantes via `reina_family_female_vocal_run`
- la variante wet **extiende** el core dry; wet-wide extiende wet — sin copiar logica

### Cadena de derivacion

```text
female-vox-1 (dry)  →  female-vox-1-wet (wet)  →  female-vocal-wet (wet-wide)
```

| Preset | Variante | Extension |
| --- | --- | --- |
| `female-vox-1` | `dry` | Raiz: presencia frontal, mascara reducida, señal seca |
| `female-vox-1-wet` | `wet` | `extends-dry` — cola corta, mezcla humeda enfocada |
| `female-vocal-wet` | `wet-wide` | `extends-wet` — espacio amplio, mezcla difusa, estereo expandido |

### Semantica de transformacion

| Variante | Intencion de senal |
| --- | --- |
| `dry` | Presencia frontal clara, minima mascara, timbralmente honesta |
| `wet` | Extension humeda de dry sin perder claridad |
| `wet-wide` | Extension amplia de la cadena wet con mezcla difusa |

### Validacion

```sh
zsh tests/presets_female_vocal.zsh
./bin/reina run female-vox-1
./bin/reina run female-vox-1-wet
./bin/reina run female-vocal-wet --json
```

## Familia `vocal-utility` (Dia 11)

Quinta familia implementada. Eleva la consciencia operativa: la red aprende a asistir, no solo a embellecer.

- core compartido en `lib/presets/families/vocal-utility.zsh`
- variantes via `reina_family_vocal_utility_run`
- `vocal-help` es preset **diagnostico**: reporta estado util en humano y `--json`

### Roles operativos

| Preset | Variante | Rol |
| --- | --- | --- |
| `pop-lead-vocal` | `lead` | Voz principal, foco frontal, liderazgo en la mezcla |
| `vocal-help` | `assist` | Diagnostico de red, runtime y cadena vocal |
| `give-backgrounds-some-life` | `background` | Fondos con vida y movimiento contextual |

### vocal-help diagnostico

`vocal-help` no solo procesa: expone en `REINA_PRESET_RESULT_MESSAGE`:

- `network_mode` y `network_status`
- rutas de `config` y `state`
- `vocal_stack` activo
- `recommendation` operativa

### Validacion

```sh
zsh tests/presets_vocal_utility.zsh
./bin/reina run vocal-help
./bin/reina run vocal-help --json
./bin/reina run pop-lead-vocal
```

## Familia `drum-bus` (Dia 12)

Sexta familia implementada. Purifica el colectivo ritmico: la bateria como organismo, no como suma de golpes.

- core compartido en `lib/presets/families/drum-bus.zsh`
- matriz de compresion, espacio y cohesion: `compression_character`, `space_cohesion`, `organism_mode`
- variantes via `reina_family_drum_bus_run`

### Semantica de transformacion

| Variante | Preset | Compresion / espacio / cohesion |
| --- | --- | --- |
| `drive` | `drum-bus-drivin` | Empuje hacia adelante, glue energetico, punch firme |
| `spaced` | `drum-bus-island` | Bus abierto, piezas separadas, aire entre golpes |
| `wild` | `drum-bus-wild-spring-camel` | Elasticidad spring-camel, groove reactivo |
| `glue` | `drum-bus-magic` | Cohesion, polish, magia de union sin perder pulso |

### Validacion

```sh
zsh tests/presets_drum_bus.zsh
./bin/reina run drum-bus-drivin
./bin/reina run drum-bus-island
./bin/reina run drum-bus-wild-spring-camel --json
./bin/reina run drum-bus-magic
```

## Familia `drum-experimental` (Dia 13)

Septima familia implementada. Capas paralelas y texturas no lineales con riesgo controlado.

- core compartido en `lib/presets/families/drum-experimental.zsh`
- variantes via `reina_family_drum_experimental_run`
- degradacion segura: fallback local si faltan dependencias — nunca fallo fatal

### Degradacion segura

| Variante | Dependencia opcional | Fallback |
| --- | --- | --- |
| `parallel` | red + `curl` | `layer_mode=local-fallback` |
| `parallel-pop` | red + `curl` | `layer_mode=local-fallback` |
| `parallel-wild` | red + `curl` | `layer_mode=local-fallback` |
| `gated` | `awk` | `layer_mode=local-fallback` |

Con `--offline`, las variantes parallel degradan a fallback local y marcan `result_status: degraded` con exit code `0`.

### Semantica de transformacion

| Variante | Preset | Intencion |
| --- | --- | --- |
| `parallel` | `parallel-processing-drums` | Capas paralelas base con riesgo controlado |
| `parallel-pop` | `myon-pop-parallel-magic` | Paralelo pulido y pop |
| `parallel-wild` | `wildin-camel-drums` | Paralelo salvaje y contrastado |
| `gated` | `wierdly-gated-drums` | Gating deliberado y textura no lineal |

### Validacion

```sh
zsh tests/presets_drum_experimental.zsh
./bin/reina run parallel-processing-drums
./bin/reina run wildin-camel-drums --json
./bin/reina --offline run parallel-processing-drums
```

## Familia `drum-pieces-core` (Dia 14)

Octava familia implementada. Vuelve al pulso primario: anclas kick y acentos snare.

- core compartido en `lib/presets/families/drum-pieces-core.zsh`
- variantes via `reina_family_drum_pieces_core_run`
- politica semantica: sin series numericas abiertas (`kick-01`, `snare-02` prohibidas)

### Politica de variantes semanticas

| Rol | Variantes | Presets |
| --- | --- | --- |
| Kick (ancla) | `anchor`, `anchor-tight` | `kick`, `kick-2` |
| Snare (acento) | `accent`, `accent-dry`, `accent-tight` | `snare`, `urban-snare`, `urban-snare-tighter` |

`kick-2` es el unico sufijo numerico permitido: segunda ancla semantica, no placeholder de serie abierta.

### Semantica de transformacion

| Variante | Intencion |
| --- | --- |
| `anchor` | Golpe ancla, pulso central, cuerpo completo |
| `anchor-tight` | Ancla focalizada y seca |
| `accent` | Acento principal clasico |
| `accent-dry` | Snare moderno, seco y frontal |
| `accent-tight` | Acento apretado y controlado |

### Validacion

```sh
zsh tests/presets_drum_pieces_core.zsh
./bin/reina run kick
./bin/reina run kick-2
./bin/reina run snare --json
./bin/reina run urban-snare-tighter
```

## Familia `drum-detail-and-space` (Dia 15)

Novena familia implementada. Eleva el aire alrededor del kit: microdetalle, overheads, room y fills.

- core compartido en `lib/presets/families/drum-detail-and-space.zsh`
- variantes via `reina_family_drum_detail_and_space_run`
- matriz de espacio y detalle via `reina_drum_detail_and_space_space_matrix`

### Politica de independencia ohs

`ohs` NO es alias de `drums-overheads`. Comparten familia pero mantienen slug, variant, perfil y transform propios:

| Preset | Variante | Relacion |
| --- | --- | --- |
| `drums-overheads` | `overheads-wide` | Perspectiva amplia; par compacto = `ohs` |
| `ohs` | `overheads-compact` | Perspectiva compacta; `independence=not-alias-of-drums-overheads` |

### Semantica de transformacion

| Variante | Preset | Intencion |
| --- | --- | --- |
| `detail` | `hats` | Microdetalle, brillo y actividad superficial |
| `overheads-wide` | `drums-overheads` | Perspectiva amplia y panoramica del kit |
| `overheads-compact` | `ohs` | Overheads compactos con identidad propia |
| `room-trash` | `trash-drum-room` | Room roto, sucio y agresivo |
| `room-smash` | `drum-room-smash` | Room aplastado y dominante |
| `fill` | `fill-kollin` | Transicion, adorno y movimiento interno |

### Validacion

```sh
zsh tests/presets_drum_detail_and_space.zsh
./bin/reina run hats
./bin/reina run ohs --json
./bin/reina run drums-overheads
./bin/reina run fill-kollin
```
