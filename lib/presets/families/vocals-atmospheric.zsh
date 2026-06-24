# Familia vocals-atmospheric — voz como paisaje, no como señal aislada.
#
# Eje camel (linea identitaria del bloque, no gimmick):
#   El "camel" nombra continuidad atmosferica y recorrido sonoro — la voz que
#   atraviesa un espacio en lugar de posarse sobre el. dreamy-camel-vocals y
#   sparkley-camel-vocals activan camel_axis=active; dark-vocals y warm-springy-vocals
#   comparten la matriz atmosferica sin forzar la linea camel.
#
# Semantica de transformacion (Dia 9):
#   dark    — sombra, densidad, presencia intima, espacio contenido
#   dreamy  — atmosfera continua, paisaje abierto, eje camel activo
#   sparkly — brillo fino, detalle aereo, eje camel activo
#   warm    — calidez elastica, cuerpo vocal redondeado, continuidad suave

function reina_vocals_atmospheric_camel_axis_enabled() {
  emulate -L zsh
  local variant="${1:-}"

  [[ "$variant" == "dreamy" || "$variant" == "sparkly" ]]
}

function reina_vocals_atmospheric_camel_axis() {
  emulate -L zsh
  local variant="${1:-}"

  if reina_vocals_atmospheric_camel_axis_enabled "$variant"; then
    cat <<'EOF'
camel_axis=active
camel_identity=line-of-continuity
camel_semantic=paisaje-sonoro-continuo
camel_presets=dreamy-camel-vocals|sparkley-camel-vocals
EOF
  else
    cat <<'EOF'
camel_axis=latent
camel_identity=shared-matrix-only
camel_semantic=atmosfera-sin-recorrido-camel
EOF
  fi
}

function reina_vocals_atmospheric_space_matrix() {
  emulate -L zsh
  local variant="${1:-base}"

  case "$variant" in
    dark)
      cat <<'EOF'
space_width=narrow
space_depth=deep
vocal_density=high
continuity=intimate
presence_shape=shadow-forward
EOF
      ;;
    dreamy)
      cat <<'EOF'
space_width=wide
space_depth=layered
vocal_density=low
continuity=flowing
presence_shape=diffuse
EOF
      ;;
    sparkly)
      cat <<'EOF'
space_width=wide
space_depth=airy
vocal_density=medium
continuity=shimmering
presence_shape=bright-detail
EOF
      ;;
    warm)
      cat <<'EOF'
space_width=medium
space_depth=rounded
vocal_density=medium
continuity=elastic
presence_shape=body-warm
EOF
      ;;
    *)
      cat <<'EOF'
space_width=balanced
space_depth=moderate
vocal_density=balanced
continuity=even
presence_shape=neutral
EOF
      ;;
  esac
}

function reina_vocals_atmospheric_default_profile() {
  emulate -L zsh
  local variant="${1:-base}"
  local profile

  profile="$(reina_vocals_atmospheric_space_matrix "$variant")"
  profile+=$'\n'
  profile+="$(reina_vocals_atmospheric_camel_axis "$variant")"
  print -rn -- "$profile"
}

function reina_vocals_atmospheric_variant_label() {
  emulate -L zsh
  local variant="${1:-base}"

  case "$variant" in
    dark) print -- "dark" ;;
    dreamy) print -- "dreamy-camel" ;;
    sparkly) print -- "sparkley-camel" ;;
    warm) print -- "warm-springy" ;;
    *) print -- "atmospheric" ;;
  esac
}

function reina_vocals_atmospheric_variant_transform() {
  emulate -L zsh
  local variant="${1:-base}"

  case "$variant" in
    dark)
      cat <<'EOF'
transform=dark-intimate
steps=contain-space|deepen-shadow|raise-density|preserve-intimacy
intent=voz en sombra, densidad y presencia cercana
EOF
      ;;
    dreamy)
      cat <<'EOF'
transform=dreamy-camel-continuum
steps=open-space|layer-atmosphere|camel-continuity|diffuse-presence
intent=paisaje vocal continuo en la linea camel
camel_line=active
EOF
      ;;
    sparkly)
      cat <<'EOF'
transform=sparkley-camel-shimmer
steps=open-air|fine-detail|camel-continuity|bright-shimmer
intent=brillo fino y detalle aereo en la linea camel
camel_line=active
EOF
      ;;
    warm)
      cat <<'EOF'
transform=warm-springy-body
steps=round-space|elastic-continuity|warm-body|gentle-spring
intent=calidez elastica y cuerpo vocal redondeado
EOF
      ;;
    *)
      cat <<'EOF'
transform=atmospheric-neutral
steps=balance-space|even-density|transparent-presence
intent=paisaje vocal equilibrado
EOF
      ;;
  esac
}

function reina_vocals_atmospheric_ensure_profile() {
  emulate -L zsh
  local variant="${1:-base}"
  local profile

  profile="$(reina_preset_profile_get profile "")"
  if [[ -z "$profile" ]]; then
    profile="$(reina_vocals_atmospheric_default_profile "$variant")"
    reina_preset_profile_put profile "$profile"
  fi

  print -rn -- "$profile"
}

function reina_vocals_atmospheric_build_recipe() {
  emulate -L zsh
  local profile="${1:-}"
  local variant="${2:-base}"
  local slug="${3:-vocals-atmospheric}"
  local label transform

  label="$(reina_vocals_atmospheric_variant_label "$variant")"
  transform="$(reina_vocals_atmospheric_variant_transform "$variant")"

  print -- "preset=$slug"
  print -- "family=vocals-atmospheric"
  print -- "variant=$variant"
  print -- "label=$label"
  print -- "$profile"
  print -- "$transform"
}

function reina_vocals_atmospheric_run_core() {
  emulate -L zsh
  local slug="${1:-}"
  local variant="${2:-base}"
  local implementation="${3:-vocals-atmospheric-core}"
  local profile recipe message label

  [[ -n "$slug" ]] || {
    reina_preset_set_result failed "slug de vocals-atmospheric vacio" "$implementation"
    return 1
  }

  profile="$(reina_vocals_atmospheric_ensure_profile "$variant")"
  recipe="$(reina_vocals_atmospheric_build_recipe "$profile" "$variant" "$slug")"
  reina_preset_snapshot_record "$recipe" "run"

  label="$(reina_vocals_atmospheric_variant_label "$variant")"
  message="vocals $label purificados: $slug"
  reina_preset_set_result ok "$message" "$implementation"
  return 0
}

function reina_family_vocals_atmospheric_run() {
  emulate -L zsh

  reina_vocals_atmospheric_run_core \
    "$REINA_PRESET_SLUG" \
    "$REINA_PRESET_VARIANT" \
    "vocals-atmospheric-family"
}