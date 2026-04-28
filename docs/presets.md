# Presets y naming

`presets/manifest.tsv` es la fuente de verdad del catalogo.

## Campos oficiales

| Campo | Regla |
| --- | --- |
| `display_name` | nombre visible y humano del preset |
| `slug` | identificador publico, unico, estable, ASCII y `kebab-case` |
| `family` | familia tecnica que comparte core o heuristicas |
| `variant` | rol semantico dentro de la familia |
| `status` | estado de lifecycle; en Dia 1 todos nacen como `planned` |
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

`reina info <preset>` muestra la ficha del manifiesto. `reina run <preset>` usa esa misma resolucion y prepara el contexto compartido para `network`, `storage`, `errors`, flags y metadata del preset.
