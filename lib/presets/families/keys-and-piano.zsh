# Familia keys-and-piano — consciencia armonica: lectura, no correccion.
#
# Semantica (Dia 18):
#   base  — teclas generales, lectura armonica con eje camel
#   jazz  — color jazz, flexibilidad y extensiones armonicas
#   rock  — empuje, ataque y presencia rock
#   beef  — cuerpo reforzado, densidad y peso piano
#
# Politica armonica:
#   Las teclas son territorio de lectura, no de correccion agresiva.
#   keys-riding-a-camel activa camel_axis=active para recorrido armonico continuo.

function reina_keys_and_piano_camel_axis_enabled() {
  emulate -L zsh
  local variant="${1:-}"

  [[ "$variant" == "base" ]]
}

function reina_keys_and_piano_camel_axis() {
  emulate -L zsh
  local variant="${1:-}"

  if reina_keys_and_piano_camel_axis_enabled "$variant"; then
    cat <<'EOF'
camel_axis=active
camel_identity=harmonic-continuity
camel_semantic=lectura-que-atraviesa-el-acorde
canonical_preset=keys-riding-a-camel
EOF
  else
    cat <<'EOF'
camel_axis=latent
camel_identity=shared-harmonic-matrix
camel_semantic=lectura-sin-recorrido-camel
EOF
  fi
}

function reina_keys_and_piano_harmonic_core() {
  emulate -L zsh

  cat <<'EOF'
instrument_family=keys-piano
reading_mode=harmonic-awareness
correction_policy=read-not-fix
voicing_approach=contextual
EOF
}

function reina_keys_and_piano_harmonic_matrix() {
  emulate -L zsh
  local variant="${1:-base}"

  case "$variant" in
    jazz)
      cat <<'EOF'
harmonic_mode=jazz-flexible
chord_color=extended-warm
extension_tolerance=high
swing_feel=moderate
voicing_density=open
EOF
      ;;
    rock)
      cat <<'EOF'
harmonic_mode=rock-drive
attack_character=punch-forward
presence_shape=mid-forward
compression_character=assertive
voicing_density=tight
EOF
      ;;
    beef)
      cat <<'EOF'
harmonic_mode=body-reinforced
piano_body=beef
density=high
low_mid_weight=forward
voicing_density=thick
EOF
      ;;
    *)
      cat <<'EOF'
harmonic_mode=general-reading
chord_color=balanced
extension_tolerance=moderate
voicing_density=even
reading_focus=progression-aware
EOF
      ;;
  esac
}

function reina_keys_and_piano_default_profile() {
  emulate -L zsh
  local variant="${1:-base}"
  local profile

  profile="$(reina_keys_and_piano_harmonic_matrix "$variant")"
  profile+=$'\n'
  profile+="$(reina_keys_and_piano_camel_axis "$variant")"
  profile+=$'\n'
  profile+="$(reina_keys_and_piano_harmonic_core)"
  profile+=$'\n'
  profile+="keys_family=keys-and-piano"$'\n'
  profile+="variant=$variant"$'\n'

  print -rn -- "$profile"
}

function reina_keys_and_piano_variant_label() {
  emulate -L zsh
  local variant="${1:-base}"

  case "$variant" in
    jazz) print -- "jazz" ;;
    rock) print -- "rock" ;;
    beef) print -- "beef" ;;
    *) print -- "keys" ;;
  esac
}

function reina_keys_and_piano_variant_transform() {
  emulate -L zsh
  local variant="${1:-base}"

  case "$variant" in
    jazz)
      cat <<'EOF'
transform=jazz-piano
steps=flexible-voicing|extended-color|swing-context|read-not-correct
intent=piano con color jazz y lectura mas flexible
EOF
      ;;
    rock)
      cat <<'EOF'
transform=rock-piano
steps=rock-attack|mid-presence|assertive-dynamics|drive-forward
intent=piano con empuje y ataque rock
EOF
      ;;
    beef)
      cat <<'EOF'
transform=piano-beef
steps=reinforced-body|thick-density|low-mid-weight|harmonic-anchor
intent=piano con cuerpo reforzado y densidad
EOF
      ;;
    *)
      cat <<'EOF'
transform=keys-riding-a-camel
steps=harmonic-reading|camel-continuity|progression-aware|read-not-correct
intent=preset general de teclas y lectura armonica
camel_axis=active
EOF
      ;;
  esac
}

function reina_keys_and_piano_ensure_profile() {
  emulate -L zsh
  local variant="${1:-base}"
  local profile

  profile="$(reina_preset_profile_get profile "")"
  if [[ -z "$profile" ]]; then
    profile="$(reina_keys_and_piano_default_profile "$variant")"
    reina_preset_profile_put profile "$profile"
  fi

  print -rn -- "$profile"
}

function reina_keys_and_piano_build_recipe() {
  emulate -L zsh
  local profile="${1:-}"
  local variant="${2:-base}"
  local slug="${3:-keys-and-piano}"
  local label transform

  label="$(reina_keys_and_piano_variant_label "$variant")"
  transform="$(reina_keys_and_piano_variant_transform "$variant")"

  print -- "preset=$slug"
  print -- "family=keys-and-piano"
  print -- "variant=$variant"
  print -- "label=$label"
  print -- "$profile"
  print -- "$transform"
}

function reina_keys_and_piano_run_core() {
  emulate -L zsh
  local slug="${1:-}"
  local variant="${2:-base}"
  local implementation="${3:-keys-and-piano-core}"
  local profile recipe message label

  [[ -n "$slug" ]] || {
    reina_preset_set_result failed "slug de keys-and-piano vacio" "$implementation"
    return 1
  }

  profile="$(reina_keys_and_piano_ensure_profile "$variant")"
  recipe="$(reina_keys_and_piano_build_recipe "$profile" "$variant" "$slug")"
  reina_preset_snapshot_record "$recipe" "run"

  label="$(reina_keys_and_piano_variant_label "$variant")"
  message="keys-and-piano $label purificado: $slug"
  reina_preset_set_result ok "$message" "$implementation"
  return 0
}

function reina_family_keys_and_piano_run() {
  emulate -L zsh

  reina_keys_and_piano_run_core \
    "$REINA_PRESET_SLUG" \
    "$REINA_PRESET_VARIANT" \
    "keys-and-piano-family"
}