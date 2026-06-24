# Familia drum-detail-and-space — aire, detalle y espacio alrededor del kit.
#
# Semantica (Dia 15):
#   detail            — microdetalle, brillo y actividad superficial (hats)
#   overheads-wide    — perspectiva amplia y panoramica (drums-overheads)
#   overheads-compact — overheads compactos con identidad propia (ohs)
#   room-trash        — room roto, sucio y agresivo
#   room-smash        — room aplastado y dominante
#   fill              — transicion, adorno y movimiento interno
#
# Politica ohs:
#   ohs NO es alias de drums-overheads. Comparte familia pero mantiene
#   slug, variant, perfil y transform propios (overheads-compact vs wide).

function reina_drum_detail_and_space_independence_policy() {
  emulate -L zsh
  local slug="${1:-}"

  case "$slug" in
    ohs)
      cat <<'EOF'
independence_policy=own-preset
overheads_relation=compact-not-alias
paired_wide_preset=drums-overheads
EOF
      ;;
    drums-overheads)
      cat <<'EOF'
independence_policy=own-preset
overheads_relation=wide-panorama
paired_compact_preset=ohs
EOF
      ;;
    *)
      cat <<'EOF'
independence_policy=own-preset
overheads_relation=none
EOF
      ;;
  esac
}

function reina_drum_detail_and_space_space_matrix() {
  emulate -L zsh
  local variant="${1:-detail}"

  case "$variant" in
    overheads-wide)
      cat <<'EOF'
space_role=overheads
perspective=wide-panorama
air_amount=high
stereo_image=expanded
EOF
      ;;
    overheads-compact)
      cat <<'EOF'
space_role=overheads
perspective=compact-focus
air_amount=moderate
stereo_image=narrow
EOF
      ;;
    room-trash)
      cat <<'EOF'
space_role=room
room_character=trash-aggressive
air_amount=dirty
decay_shape=broken
EOF
      ;;
    room-smash)
      cat <<'EOF'
space_role=room
room_character=smash-dominant
air_amount=compressed
decay_shape=flattened
EOF
      ;;
    fill)
      cat <<'EOF'
space_role=fill
motion_character=transitional
air_amount=expressive
detail_focus=internal-movement
EOF
      ;;
    *)
      cat <<'EOF'
space_role=detail
detail_focus=micro-activity
air_amount=light
brightness=high
EOF
      ;;
  esac
}

function reina_drum_detail_and_space_default_profile() {
  emulate -L zsh
  local variant="${1:-detail}"
  local slug="${2:-drum-detail-and-space}"
  local profile

  profile="$(reina_drum_detail_and_space_space_matrix "$variant")"
  profile+=$'\n'
  profile+="$(reina_drum_detail_and_space_independence_policy "$slug")"
  profile+=$'\n'
  profile+="detail_family=drum-detail-and-space"$'\n'
  profile+="variant=$variant"$'\n'

  print -rn -- "$profile"
}

function reina_drum_detail_and_space_variant_label() {
  emulate -L zsh
  local variant="${1:-detail}"

  case "$variant" in
    overheads-wide) print -- "overheads-wide" ;;
    overheads-compact) print -- "overheads-compact" ;;
    room-trash) print -- "room-trash" ;;
    room-smash) print -- "room-smash" ;;
    fill) print -- "fill" ;;
    *) print -- "detail" ;;
  esac
}

function reina_drum_detail_and_space_variant_transform() {
  emulate -L zsh
  local variant="${1:-detail}"
  local slug="${2:-}"

  case "$variant" in
    overheads-wide)
      cat <<'EOF'
transform=drums-overheads-wide
steps=open-panorama|capture-kit-air|wide-stereo|spatial-detail
intent=perspectiva amplia y panoramica del kit
EOF
      ;;
    overheads-compact)
      cat <<'EOF'
transform=ohs-compact
steps=focus-overheads|compact-stereo|targeted-air|distinct-from-wide
intent=overheads compactos con identidad propia
independence=not-alias-of-drums-overheads
EOF
      ;;
    room-trash)
      cat <<'EOF'
transform=trash-drum-room
steps=break-room|dirty-decay|aggressive-air|trash-texture
intent=room roto, sucio y agresivo
EOF
      ;;
    room-smash)
      cat <<'EOF'
transform=drum-room-smash
steps=compress-room|flatten-decay|dominant-smash|controlled-air
intent=room aplastado y dominante
EOF
      ;;
    fill)
      cat <<'EOF'
transform=fill-kollin
steps=transitional-motion|ornament-detail|internal-movement|fill-bridge
intent=transicion, adorno y movimiento interno
EOF
      ;;
    *)
      cat <<'EOF'
transform=hats-detail
steps=micro-detail|surface-brightness|hat-activity|light-air
intent=microdetalle, brillo y actividad superficial
EOF
      ;;
  esac
}

function reina_drum_detail_and_space_ensure_profile() {
  emulate -L zsh
  local variant="${1:-detail}"
  local slug="${2:-}"
  local profile

  profile="$(reina_preset_profile_get profile "")"
  if [[ -z "$profile" ]]; then
    profile="$(reina_drum_detail_and_space_default_profile "$variant" "$slug")"
    reina_preset_profile_put profile "$profile"
  fi

  print -rn -- "$profile"
}

function reina_drum_detail_and_space_build_recipe() {
  emulate -L zsh
  local profile="${1:-}"
  local variant="${2:-detail}"
  local slug="${3:-drum-detail-and-space}"
  local label transform

  label="$(reina_drum_detail_and_space_variant_label "$variant")"
  transform="$(reina_drum_detail_and_space_variant_transform "$variant" "$slug")"

  print -- "preset=$slug"
  print -- "family=drum-detail-and-space"
  print -- "variant=$variant"
  print -- "label=$label"
  print -- "$profile"
  print -- "$transform"
}

function reina_drum_detail_and_space_run_core() {
  emulate -L zsh
  local slug="${1:-}"
  local variant="${2:-detail}"
  local implementation="${3:-drum-detail-and-space-core}"
  local profile recipe message label

  [[ -n "$slug" ]] || {
    reina_preset_set_result failed "slug de drum-detail-and-space vacio" "$implementation"
    return 1
  }

  profile="$(reina_drum_detail_and_space_ensure_profile "$variant" "$slug")"
  recipe="$(reina_drum_detail_and_space_build_recipe "$profile" "$variant" "$slug")"
  reina_preset_snapshot_record "$recipe" "run"

  label="$(reina_drum_detail_and_space_variant_label "$variant")"
  message="drum-detail-and-space $label purificado: $slug"
  reina_preset_set_result ok "$message" "$implementation"
  return 0
}

function reina_family_drum_detail_and_space_run() {
  emulate -L zsh

  reina_drum_detail_and_space_run_core \
    "$REINA_PRESET_SLUG" \
    "$REINA_PRESET_VARIANT" \
    "drum-detail-and-space-family"
}