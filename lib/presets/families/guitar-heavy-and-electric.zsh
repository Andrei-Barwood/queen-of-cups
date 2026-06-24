# Familia guitar-heavy-and-electric — drive electrico, cuerpo metalico, consciencia del empuje.
#
# Semantica (Dia 16):
#   bright  — guitarra pesada con brillo al frente
#   reverb  — peso con espacio y cola
#   wild    — variante salvaje y desbordada en la linea camel
#   driver  — drive y empuje electrico focalizado
#   base    — preset general de guitarra electrica hasta refinamiento futuro
#
# Matriz compartida: body_character, drive_presence, electric_mode

function reina_guitar_heavy_and_electric_drive_matrix() {
  emulate -L zsh
  local variant="${1:-base}"

  case "$variant" in
    bright)
      cat <<'EOF'
electric_mode=heavy-bright
body_character=metallic-forward
drive_presence=high
brightness=front
EOF
      ;;
    reverb)
      cat <<'EOF'
electric_mode=heavy-spatial
body_character=metallic-wet
drive_presence=moderate
space_character=reverb-tail
EOF
      ;;
    wild)
      cat <<'EOF'
electric_mode=heavy-wild
body_character=metallic-overflow
drive_presence=contrast
camel_wild=active
EOF
      ;;
    driver)
      cat <<'EOF'
electric_mode=heavy-driver
body_character=metallic-push
drive_presence=forward
saturation_character=focused
EOF
      ;;
    *)
      cat <<'EOF'
electric_mode=heavy-base
body_character=metallic-neutral
drive_presence=balanced
generalist_mode=active
EOF
      ;;
  esac
}

function reina_guitar_heavy_and_electric_default_profile() {
  emulate -L zsh
  local variant="${1:-base}"
  local profile

  profile="$(reina_guitar_heavy_and_electric_drive_matrix "$variant")"
  profile+=$'\n'
  profile+="electric_family=guitar-heavy-and-electric"$'\n'
  profile+="variant=$variant"$'\n'

  case "$variant" in
    bright)
      profile+=$'front_presence=high\nattack_brightness=active\nheavy_weight=firm\n'
      ;;
    reverb)
      profile+=$'wet_dimension=active\ntail_length=extended\nspace_blend=integrated\n'
      ;;
    wild)
      profile+=$'camel_wild_line=wildin-camel-guitar\noverflow_energy=high\ncontrast_texture=active\n'
      ;;
    driver)
      profile+=$'push_energy=high\ndrive_saturation=firm\nforward_impulse=active\n'
      ;;
    *)
      profile+=$'general_electric=active\nrefinement_pending=family-level\n'
      ;;
  esac

  print -rn -- "$profile"
}

function reina_guitar_heavy_and_electric_variant_label() {
  emulate -L zsh
  local variant="${1:-base}"

  case "$variant" in
    bright) print -- "bright" ;;
    reverb) print -- "reverb" ;;
    wild) print -- "wild-camel" ;;
    driver) print -- "driver" ;;
    *) print -- "base" ;;
  esac
}

function reina_guitar_heavy_and_electric_variant_transform() {
  emulate -L zsh
  local variant="${1:-base}"

  case "$variant" in
    bright)
      cat <<'EOF'
transform=heavy-bright-guitar
steps=heavy-body|front-brightness|metallic-presence|attack-clarity
intent=guitarra electrica pesada con brillo al frente
EOF
      ;;
    reverb)
      cat <<'EOF'
transform=heavy-guitar-with-reverb
steps=heavy-body|spatial-tail|reverb-blend|wet-dimension
intent=guitarra pesada con espacio y cola
EOF
      ;;
    wild)
      cat <<'EOF'
transform=wildin-camel-guitar
steps=heavy-body|wild-contrast|camel-overflow|desbordamiento-controlado
intent=variante electrica salvaje y desbordada en la linea camel
camel_wild=active
EOF
      ;;
    driver)
      cat <<'EOF'
transform=el-gtr-driver
steps=drive-push|saturation-focus|forward-impulse|metallic-impulse
intent=drive y empuje electrico focalizado
EOF
      ;;
    *)
      cat <<'EOF'
transform=gtr-base
steps=neutral-electric|balanced-drive|general-body|family-foundation
intent=preset general de guitarra electrica hasta refinamiento futuro
EOF
      ;;
  esac
}

function reina_guitar_heavy_and_electric_ensure_profile() {
  emulate -L zsh
  local variant="${1:-base}"
  local profile

  profile="$(reina_preset_profile_get profile "")"
  if [[ -z "$profile" ]]; then
    profile="$(reina_guitar_heavy_and_electric_default_profile "$variant")"
    reina_preset_profile_put profile "$profile"
  fi

  print -rn -- "$profile"
}

function reina_guitar_heavy_and_electric_build_recipe() {
  emulate -L zsh
  local profile="${1:-}"
  local variant="${2:-base}"
  local slug="${3:-guitar-heavy-and-electric}"
  local label transform

  label="$(reina_guitar_heavy_and_electric_variant_label "$variant")"
  transform="$(reina_guitar_heavy_and_electric_variant_transform "$variant")"

  print -- "preset=$slug"
  print -- "family=guitar-heavy-and-electric"
  print -- "variant=$variant"
  print -- "label=$label"
  print -- "$profile"
  print -- "$transform"
}

function reina_guitar_heavy_and_electric_run_core() {
  emulate -L zsh
  local slug="${1:-}"
  local variant="${2:-base}"
  local implementation="${3:-guitar-heavy-and-electric-core}"
  local profile recipe message label

  [[ -n "$slug" ]] || {
    reina_preset_set_result failed "slug de guitar-heavy-and-electric vacio" "$implementation"
    return 1
  }

  profile="$(reina_guitar_heavy_and_electric_ensure_profile "$variant")"
  recipe="$(reina_guitar_heavy_and_electric_build_recipe "$profile" "$variant" "$slug")"
  reina_preset_snapshot_record "$recipe" "run"

  label="$(reina_guitar_heavy_and_electric_variant_label "$variant")"
  message="guitar-heavy-and-electric $label purificado: $slug"
  reina_preset_set_result ok "$message" "$implementation"
  return 0
}

function reina_family_guitar_heavy_and_electric_run() {
  emulate -L zsh

  reina_guitar_heavy_and_electric_run_core \
    "$REINA_PRESET_SLUG" \
    "$REINA_PRESET_VARIANT" \
    "guitar-heavy-and-electric-family"
}