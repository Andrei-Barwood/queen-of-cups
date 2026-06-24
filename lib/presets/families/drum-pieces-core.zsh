# Familia drum-pieces-core — anclas del pulso primario.
#
# Politica de variantes semanticas (Dia 14):
#   kick  — anchor, anchor-tight (kick-2); sin serie abierta kick-01, kick-02...
#   snare — accent, accent-dry, accent-tight; variantes con nombre, no numeros
#   kick-2 es el unico sufijo numerico permitido: segunda ancla semantica, no placeholder
#
# Semantica:
#   anchor       — golpe ancla, pulso central del kit
#   anchor-tight — ancla mas focalizada y seca
#   accent       — acento principal del bloque
#   accent-dry   — snare moderno, seco y frontal
#   accent-tight — acento apretado y controlado

function reina_drum_pieces_core_semantic_policy() {
  emulate -L zsh

  cat <<'EOF'
variant_policy=semantic-only
kick_variants=anchor|anchor-tight
snare_variants=accent|accent-dry|accent-tight
numeric_series=closed
allowed_numeric_suffix=kick-2
forbidden_pattern=kick-0[0-9]+|snare-[0-9]+
EOF
}

function reina_drum_pieces_core_piece_role() {
  emulate -L zsh
  local variant="${1:-anchor}"

  case "$variant" in
    anchor-tight)
      print -- "kick"
      ;;
    accent|accent-dry|accent-tight)
      print -- "snare"
      ;;
    *)
      print -- "kick"
      ;;
  esac
}

function reina_drum_pieces_core_anchor_matrix() {
  emulate -L zsh
  local variant="${1:-anchor}"

  case "$variant" in
    anchor-tight)
      cat <<'EOF'
pulse_role=anchor-tight
sub_focus=tight
attack_shape=dry-forward
body_presence=focal
EOF
      ;;
    *)
      cat <<'EOF'
pulse_role=anchor
sub_focus=central
attack_shape=round-punch
body_presence=full
EOF
      ;;
  esac
}

function reina_drum_pieces_core_accent_matrix() {
  emulate -L zsh
  local variant="${1:-accent}"

  case "$variant" in
    accent-dry)
      cat <<'EOF'
pulse_role=accent-dry
snap_focus=frontal
ring_character=dry-modern
body_presence=controlled
EOF
      ;;
    accent-tight)
      cat <<'EOF'
pulse_role=accent-tight
snap_focus=compressed
ring_character=tight
body_presence=minimal
EOF
      ;;
    *)
      cat <<'EOF'
pulse_role=accent
snap_focus=present
ring_character=classic
body_presence=balanced
EOF
      ;;
  esac
}

function reina_drum_pieces_core_default_profile() {
  emulate -L zsh
  local variant="${1:-anchor}"
  local profile piece_role

  profile="$(reina_drum_pieces_core_semantic_policy)"
  profile+=$'\n'
  piece_role="$(reina_drum_pieces_core_piece_role "$variant")"
  profile+="piece_role=$piece_role"$'\n'
  profile+="variant=$variant"$'\n'

  if [[ "$piece_role" == "snare" ]]; then
    profile+="$(reina_drum_pieces_core_accent_matrix "$variant")"
  else
    profile+="$(reina_drum_pieces_core_anchor_matrix "$variant")"
  fi

  print -rn -- "$profile"
}

function reina_drum_pieces_core_variant_label() {
  emulate -L zsh
  local variant="${1:-anchor}"

  case "$variant" in
    anchor-tight) print -- "anchor-tight" ;;
    accent-dry) print -- "accent-dry" ;;
    accent-tight) print -- "accent-tight" ;;
    accent) print -- "accent" ;;
    *) print -- "anchor" ;;
  esac
}

function reina_drum_pieces_core_variant_transform() {
  emulate -L zsh
  local variant="${1:-anchor}"

  case "$variant" in
    anchor-tight)
      cat <<'EOF'
transform=kick-anchor-tight
steps=focalize-sub|dry-attack|tight-body|preserve-pulse
intent=ancla seca y focalizada sin serie numerica abierta
semantic_policy=anchor-tight
EOF
      ;;
    accent-dry)
      cat <<'EOF'
transform=urban-snare-dry
steps=dry-snap|frontal-presence|control-ring|modern-accent
intent=acento seco y frontal urbano
semantic_policy=accent-dry
EOF
      ;;
    accent-tight)
      cat <<'EOF'
transform=urban-snare-tight
steps=compress-snap|tight-ring|control-body|focused-accent
intent=acento apretado y controlado
semantic_policy=accent-tight
EOF
      ;;
    accent)
      cat <<'EOF'
transform=snare-accent
steps=present-snap|classic-ring|balance-body|main-accent
intent=acento principal del bloque
semantic_policy=accent
EOF
      ;;
    *)
      cat <<'EOF'
transform=kick-anchor
steps=central-sub|round-punch|full-body|anchor-pulse
intent=golpe ancla y pulso central
semantic_policy=anchor
EOF
      ;;
  esac
}

function reina_drum_pieces_core_ensure_profile() {
  emulate -L zsh
  local variant="${1:-anchor}"
  local profile

  profile="$(reina_preset_profile_get profile "")"
  if [[ -z "$profile" ]]; then
    profile="$(reina_drum_pieces_core_default_profile "$variant")"
    reina_preset_profile_put profile "$profile"
  fi

  print -rn -- "$profile"
}

function reina_drum_pieces_core_build_recipe() {
  emulate -L zsh
  local profile="${1:-}"
  local variant="${2:-anchor}"
  local slug="${3:-drum-pieces-core}"
  local label transform piece_role

  label="$(reina_drum_pieces_core_variant_label "$variant")"
  transform="$(reina_drum_pieces_core_variant_transform "$variant")"
  piece_role="$(reina_drum_pieces_core_piece_role "$variant")"

  print -- "preset=$slug"
  print -- "family=drum-pieces-core"
  print -- "variant=$variant"
  print -- "label=$label"
  print -- "piece_role=$piece_role"
  print -- "$profile"
  print -- "$transform"
}

function reina_drum_pieces_core_run_core() {
  emulate -L zsh
  local slug="${1:-}"
  local variant="${2:-anchor}"
  local implementation="${3:-drum-pieces-core}"
  local profile recipe message label piece_role

  [[ -n "$slug" ]] || {
    reina_preset_set_result failed "slug de drum-pieces-core vacio" "$implementation"
    return 1
  }

  profile="$(reina_drum_pieces_core_ensure_profile "$variant")"
  recipe="$(reina_drum_pieces_core_build_recipe "$profile" "$variant" "$slug")"
  reina_preset_snapshot_record "$recipe" "run"

  label="$(reina_drum_pieces_core_variant_label "$variant")"
  piece_role="$(reina_drum_pieces_core_piece_role "$variant")"
  message="drum-pieces-core $piece_role $label purificado: $slug"
  reina_preset_set_result ok "$message" "$implementation"
  return 0
}

function reina_family_drum_pieces_core_run() {
  emulate -L zsh

  reina_drum_pieces_core_run_core \
    "$REINA_PRESET_SLUG" \
    "$REINA_PRESET_VARIANT" \
    "drum-pieces-core-family"
}