# Familia drum-bus — bateria como organismo, no como suma de golpes.
#
# Semantica (Dia 12):
#   drive  — empuje, glue energetico, compresion hacia adelante
#   spaced — bus abierto, separacion entre piezas, aire en el conjunto
#   wild   — elasticidad y energia spring-camel en el colectivo ritmico
#   glue   — cohesion, polish, magia de union sin perder pulso
#
# Matriz compartida: compression_character, space_cohesion, organism_mode

function reina_drum_bus_organism_matrix() {
  emulate -L zsh
  local variant="${1:-drive}"

  case "$variant" in
    spaced)
      cat <<'EOF'
organism_mode=collective-separated
compression_character=light
space_cohesion=open
bus_width=wide
EOF
      ;;
    wild)
      cat <<'EOF'
organism_mode=collective-elastic
compression_character=reactive
space_cohesion=spring-camel
bus_width=expansive
camel_spring=active
EOF
      ;;
    glue)
      cat <<'EOF'
organism_mode=collective-unified
compression_character=glue
space_cohesion=tight
bus_width=focused
EOF
      ;;
    *)
      cat <<'EOF'
organism_mode=collective-driving
compression_character=forward
space_cohesion=punchy
bus_width=moderate
EOF
      ;;
  esac
}

function reina_drum_bus_default_profile() {
  emulate -L zsh
  local variant="${1:-drive}"
  local profile

  profile="$(reina_drum_bus_organism_matrix "$variant")"
  profile+=$'\n'
  profile+="drum_bus_family=drum-bus"$'\n'

  case "$variant" in
    spaced)
      profile+=$'island_mode=active\npiece_separation=high\nroom_between_hits=present\n'
      ;;
    wild)
      profile+=$'spring_energy=high\nelastic_groove=active\ncamel_spring_line=drum-bus-wild-spring-camel\n'
      ;;
    glue)
      profile+=$'magic_cohesion=active\npolish_level=high\nglue_preservation=pulse\n'
      ;;
    *)
      profile+=$'drive_energy=high\nglue_forward=active\npunch_preservation=firm\n'
      ;;
  esac

  print -rn -- "$profile"
}

function reina_drum_bus_variant_label() {
  emulate -L zsh
  local variant="${1:-drive}"

  case "$variant" in
    spaced) print -- "island" ;;
    wild) print -- "wild-spring-camel" ;;
    glue) print -- "magic" ;;
    *) print -- "drivin" ;;
  esac
}

function reina_drum_bus_variant_transform() {
  emulate -L zsh
  local variant="${1:-drive}"

  case "$variant" in
    spaced)
      cat <<'EOF'
transform=drum-bus-island
steps=open-bus|separate-pieces|preserve-air|light-glue
intent=bus abierto con piezas separadas y espacio entre golpes
EOF
      ;;
    wild)
      cat <<'EOF'
transform=drum-bus-wild-spring
steps=elastic-compress|spring-groove|camel-energy|reactive-punch
intent=bus elastico y energetico en la linea spring-camel
camel_spring=active
EOF
      ;;
    glue)
      cat <<'EOF'
transform=drum-bus-magic-glue
steps=unify-collective|polish-cohesion|preserve-pulse|magic-glue
intent=cohesion y polish del colectivo ritmico
EOF
      ;;
    *)
      cat <<'EOF'
transform=drum-bus-drivin
steps=forward-compress|drive-glue|collective-punch|energy-push
intent=empuje y energia de conjunto en el bus
EOF
      ;;
  esac
}

function reina_drum_bus_ensure_profile() {
  emulate -L zsh
  local variant="${1:-drive}"
  local profile

  profile="$(reina_preset_profile_get profile "")"
  if [[ -z "$profile" ]]; then
    profile="$(reina_drum_bus_default_profile "$variant")"
    reina_preset_profile_put profile "$profile"
  fi

  print -rn -- "$profile"
}

function reina_drum_bus_build_recipe() {
  emulate -L zsh
  local profile="${1:-}"
  local variant="${2:-drive}"
  local slug="${3:-drum-bus}"
  local label transform

  label="$(reina_drum_bus_variant_label "$variant")"
  transform="$(reina_drum_bus_variant_transform "$variant")"

  print -- "preset=$slug"
  print -- "family=drum-bus"
  print -- "variant=$variant"
  print -- "label=$label"
  print -- "$profile"
  print -- "$transform"
}

function reina_drum_bus_run_core() {
  emulate -L zsh
  local slug="${1:-}"
  local variant="${2:-drive}"
  local implementation="${3:-drum-bus-core}"
  local profile recipe message label

  [[ -n "$slug" ]] || {
    reina_preset_set_result failed "slug de drum-bus vacio" "$implementation"
    return 1
  }

  profile="$(reina_drum_bus_ensure_profile "$variant")"
  recipe="$(reina_drum_bus_build_recipe "$profile" "$variant" "$slug")"
  reina_preset_snapshot_record "$recipe" "run"

  label="$(reina_drum_bus_variant_label "$variant")"
  message="drum-bus $label purificado: $slug"
  reina_preset_set_result ok "$message" "$implementation"
  return 0
}

function reina_family_drum_bus_run() {
  emulate -L zsh

  reina_drum_bus_run_core \
    "$REINA_PRESET_SLUG" \
    "$REINA_PRESET_VARIANT" \
    "drum-bus-family"
}