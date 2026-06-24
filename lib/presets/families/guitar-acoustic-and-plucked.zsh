# Familia guitar-acoustic-and-plucked — cuerda resonante, ataque natural, cola consciente.
#
# Semantica (Dia 17):
#   wet        — acustica con cola y contexto humedo
#   base       — preset acustico canonico (alias explicito: ac-gtr)
#   muted      — cuatro muteada, percusiva y contenida
#   muted-wet  — extension humeda de muted-cuatro
#
# Cadena de derivacion:
#   muted-cuatro (muted)  →  muted-cuatro-wet (muted-wet)
#
# Politica alias:
#   ac-gtr NO es preset nuevo; resuelve a acoustic-gtr en runtime.

function reina_guitar_acoustic_and_plucked_resonance_core() {
  emulate -L zsh

  cat <<'EOF'
plucked_mode=resonant
attack_character=natural
body_resonance=wood-forward
string_family=acoustic-plucked
EOF
}

function reina_guitar_acoustic_and_plucked_wet_extension() {
  emulate -L zsh

  cat <<'EOF'
derivation=standalone-wet
wet_dimension=active
tail_character=natural-decay
space_blend=integrated
reverb_send=moderate
EOF
}

function reina_guitar_acoustic_and_plucked_muted_core() {
  emulate -L zsh

  cat <<'EOF'
plucked_mode=muted-percussive
attack_character=short-muted
body_resonance=contained
string_family=cuatro-muted
derivation_root=muted-cuatro
EOF
}

function reina_guitar_acoustic_and_plucked_muted_wet_extension() {
  emulate -L zsh

  cat <<'EOF'
derivation=extends-muted
derivation_parent=muted-cuatro
wet_dimension=active
tail_character=soft-muted
space_blend=layered
reverb_send=light
EOF
}

function reina_guitar_acoustic_and_plucked_derivation_chain() {
  emulate -L zsh
  local variant="${1:-base}"

  case "$variant" in
    muted-wet)
      print -- "muted-cuatro>muted-cuatro-wet"
      ;;
    muted)
      print -- "muted-cuatro"
      ;;
    wet)
      print -- "acoustic-guitar-wet"
      ;;
    *)
      print -- "acoustic-gtr"
      ;;
  esac
}

function reina_guitar_acoustic_and_plucked_resonance_matrix() {
  emulate -L zsh
  local variant="${1:-base}"

  case "$variant" in
    wet)
      cat <<'EOF'
resonance_mode=acoustic-wet
dry_wet_balance=wet-integrated
tail_presence=extended
EOF
      ;;
    muted)
      cat <<'EOF'
resonance_mode=muted-percussive
dry_wet_balance=dry-muted
percussive_focus=high
EOF
      ;;
    muted-wet)
      cat <<'EOF'
resonance_mode=muted-wet
dry_wet_balance=wet-layered
percussive_focus=moderate
EOF
      ;;
    *)
      cat <<'EOF'
resonance_mode=acoustic-base
dry_wet_balance=dry-resonant
canonical_preset=acoustic-gtr
EOF
      ;;
  esac
}

function reina_guitar_acoustic_and_plucked_default_profile() {
  emulate -L zsh
  local variant="${1:-base}"
  local profile

  profile="$(reina_guitar_acoustic_and_plucked_resonance_matrix "$variant")"
  profile+=$'\n'
  profile+="plucked_family=guitar-acoustic-and-plucked"$'\n'
  profile+="variant=$variant"$'\n'
  profile+="derivation_chain=$(reina_guitar_acoustic_and_plucked_derivation_chain "$variant")"$'\n'

  case "$variant" in
    wet)
      profile+="$(reina_guitar_acoustic_and_plucked_resonance_core)"
      profile+=$'\n'
      profile+="$(reina_guitar_acoustic_and_plucked_wet_extension)"
      ;;
    muted)
      profile+="$(reina_guitar_acoustic_and_plucked_muted_core)"
      ;;
    muted-wet)
      profile+="$(reina_guitar_acoustic_and_plucked_muted_core)"
      profile+=$'\n'
      profile+="$(reina_guitar_acoustic_and_plucked_muted_wet_extension)"
      ;;
    *)
      profile+="$(reina_guitar_acoustic_and_plucked_resonance_core)"
      profile+=$'\n'
      profile+="alias_policy=ac-gtr-explicit-short"$'\n'
      profile+="canonical_alias=ac-gtr"$'\n'
      ;;
  esac

  print -rn -- "$profile"
}

function reina_guitar_acoustic_and_plucked_variant_label() {
  emulate -L zsh
  local variant="${1:-base}"

  case "$variant" in
    wet) print -- "wet" ;;
    muted) print -- "muted" ;;
    muted-wet) print -- "muted-wet" ;;
    *) print -- "base" ;;
  esac
}

function reina_guitar_acoustic_and_plucked_variant_transform() {
  emulate -L zsh
  local variant="${1:-base}"

  case "$variant" in
    wet)
      cat <<'EOF'
transform=acoustic-guitar-wet
steps=natural-attack|wood-resonance|wet-tail|contextual-space
intent=cuerda acustica con cola y contexto
EOF
      ;;
    muted)
      cat <<'EOF'
transform=muted-cuatro
steps=muted-attack|percussive-body|contained-resonance|short-decay
intent=cuatro muteada, percusiva y contenida
EOF
      ;;
    muted-wet)
      cat <<'EOF'
transform=muted-cuatro-wet
steps=extends-muted|soft-tail|layered-space|muted-wet-blend
intent=extension humeda de muted-cuatro
derivation_parent=muted-cuatro
EOF
      ;;
    *)
      cat <<'EOF'
transform=acoustic-gtr-base
steps=natural-attack|wood-body|dry-resonance|canonical-acoustic
intent=preset acustico canonico; ac-gtr es alias explicito
alias_resolution=ac-gtr>acoustic-gtr
EOF
      ;;
  esac
}

function reina_guitar_acoustic_and_plucked_ensure_profile() {
  emulate -L zsh
  local variant="${1:-base}"
  local profile

  profile="$(reina_preset_profile_get profile "")"
  if [[ -z "$profile" ]]; then
    profile="$(reina_guitar_acoustic_and_plucked_default_profile "$variant")"
    reina_preset_profile_put profile "$profile"
  fi

  print -rn -- "$profile"
}

function reina_guitar_acoustic_and_plucked_build_recipe() {
  emulate -L zsh
  local profile="${1:-}"
  local variant="${2:-base}"
  local slug="${3:-guitar-acoustic-and-plucked}"
  local label transform

  label="$(reina_guitar_acoustic_and_plucked_variant_label "$variant")"
  transform="$(reina_guitar_acoustic_and_plucked_variant_transform "$variant")"

  print -- "preset=$slug"
  print -- "family=guitar-acoustic-and-plucked"
  print -- "variant=$variant"
  print -- "label=$label"
  print -- "$profile"
  print -- "$transform"
}

function reina_guitar_acoustic_and_plucked_run_core() {
  emulate -L zsh
  local slug="${1:-}"
  local variant="${2:-base}"
  local implementation="${3:-guitar-acoustic-and-plucked-core}"
  local profile recipe message label

  [[ -n "$slug" ]] || {
    reina_preset_set_result failed "slug de guitar-acoustic-and-plucked vacio" "$implementation"
    return 1
  }

  profile="$(reina_guitar_acoustic_and_plucked_ensure_profile "$variant")"
  recipe="$(reina_guitar_acoustic_and_plucked_build_recipe "$profile" "$variant" "$slug")"
  reina_preset_snapshot_record "$recipe" "run"

  label="$(reina_guitar_acoustic_and_plucked_variant_label "$variant")"
  message="guitar-acoustic-and-plucked $label purificado: $slug"
  reina_preset_set_result ok "$message" "$implementation"
  return 0
}

function reina_family_guitar_acoustic_and_plucked_run() {
  emulate -L zsh

  reina_guitar_acoustic_and_plucked_run_core \
    "$REINA_PRESET_SLUG" \
    "$REINA_PRESET_VARIANT" \
    "guitar-acoustic-and-plucked-family"
}