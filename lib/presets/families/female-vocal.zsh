# Familia female-vocal — presencia frontal con verdad timbral.
#
# Cadena de derivacion (Dia 10):
#   female-vox-1 (dry)  →  female-vox-1-wet (wet)  →  female-vocal-wet (wet-wide)
#   La variante wet extiende el core dry; wet-wide extiende wet. Sin copiar logica.
#
# Semantica de transformacion:
#   dry      — presencia frontal clara, minima mascara, señal seca y honesta
#   wet      — extiende dry con cola corta y mezcla humeda enfocada
#   wet-wide — extiende wet con espacio amplio y mezcla difusa

function reina_female_vocal_dry_core() {
  emulate -L zsh

  cat <<'EOF'
presence_mode=frontal
timbral_truth=high
mask_reduction=active
reverb_send=none
dry_wet_balance=dry-forward
clarity=present
derivation_root=female-vox-1
EOF
}

function reina_female_vocal_wet_extension() {
  emulate -L zsh

  cat <<'EOF'
derivation=extends-dry
derivation_parent=female-vox-1
reverb_send=moderate
wet_blend=focused
space_tail=short
delay_send=light
EOF
}

function reina_female_vocal_wet_wide_extension() {
  emulate -L zsh

  cat <<'EOF'
derivation=extends-wet
derivation_parent=female-vox-1-wet
reverb_send=wide
wet_blend=diffuse
space_tail=long
stereo_width=expanded
mix_presence=blended
EOF
}

function reina_female_vocal_derivation_chain() {
  emulate -L zsh
  local variant="${1:-dry}"

  case "$variant" in
    wet)
      print -- "female-vox-1>female-vox-1-wet"
      ;;
    wet-wide)
      print -- "female-vox-1>female-vox-1-wet>female-vocal-wet"
      ;;
    *)
      print -- "female-vox-1"
      ;;
  esac
}

function reina_female_vocal_default_profile() {
  emulate -L zsh
  local variant="${1:-dry}"
  local profile

  profile="$(reina_female_vocal_dry_core)"
  profile+=$'\n'
  profile+="derivation_chain=$(reina_female_vocal_derivation_chain "$variant")"$'\n'

  case "$variant" in
    wet)
      profile+="$(reina_female_vocal_wet_extension)"
      ;;
    wet-wide)
      profile+="$(reina_female_vocal_wet_extension)"
      profile+=$'\n'
      profile+="$(reina_female_vocal_wet_wide_extension)"
      ;;
  esac

  print -rn -- "$profile"
}

function reina_female_vocal_variant_label() {
  emulate -L zsh
  local variant="${1:-dry}"

  case "$variant" in
    wet) print -- "wet" ;;
    wet-wide) print -- "wet-wide" ;;
    *) print -- "dry" ;;
  esac
}

function reina_female_vocal_dry_transform() {
  emulate -L zsh

  cat <<'EOF'
transform=female-vox-dry
steps=frontal-presence|reduce-mask|preserve-clarity|dry-balance
intent=presencia frontal clara y timbralmente honesta
EOF
}

function reina_female_vocal_wet_transform() {
  emulate -L zsh
  local base

  base="$(reina_female_vocal_dry_transform)"
  print -- "$base"
  cat <<'EOF'
extend=add-focused-wet
steps+=short-tail|focused-wet-blend|inherit-dry-clarity
intent=extension humeda de female-vox-1 sin perder verdad seca
EOF
}

function reina_female_vocal_wet_wide_transform() {
  emulate -L zsh
  local base

  base="$(reina_female_vocal_wet_transform)"
  print -- "$base"
  cat <<'EOF'
extend=add-wide-wet
steps+=wide-space|diffuse-blend|expand-stereo
intent=extension amplia de la cadena wet con mezcla difusa
EOF
}

function reina_female_vocal_variant_transform() {
  emulate -L zsh
  local variant="${1:-dry}"

  case "$variant" in
    wet) reina_female_vocal_wet_transform ;;
    wet-wide) reina_female_vocal_wet_wide_transform ;;
    *) reina_female_vocal_dry_transform ;;
  esac
}

function reina_female_vocal_ensure_profile() {
  emulate -L zsh
  local variant="${1:-dry}"
  local profile

  profile="$(reina_preset_profile_get profile "")"
  if [[ -z "$profile" ]]; then
    profile="$(reina_female_vocal_default_profile "$variant")"
    reina_preset_profile_put profile "$profile"
  fi

  print -rn -- "$profile"
}

function reina_female_vocal_build_recipe() {
  emulate -L zsh
  local profile="${1:-}"
  local variant="${2:-dry}"
  local slug="${3:-female-vocal}"
  local label transform chain

  label="$(reina_female_vocal_variant_label "$variant")"
  transform="$(reina_female_vocal_variant_transform "$variant")"
  chain="$(reina_female_vocal_derivation_chain "$variant")"

  print -- "preset=$slug"
  print -- "family=female-vocal"
  print -- "variant=$variant"
  print -- "label=$label"
  print -- "derivation_chain=$chain"
  print -- "$profile"
  print -- "$transform"
}

function reina_female_vocal_run_core() {
  emulate -L zsh
  local slug="${1:-}"
  local variant="${2:-dry}"
  local implementation="${3:-female-vocal-core}"
  local profile recipe message label

  [[ -n "$slug" ]] || {
    reina_preset_set_result failed "slug de female-vocal vacio" "$implementation"
    return 1
  }

  profile="$(reina_female_vocal_ensure_profile "$variant")"
  recipe="$(reina_female_vocal_build_recipe "$profile" "$variant" "$slug")"
  reina_preset_snapshot_record "$recipe" "run"

  label="$(reina_female_vocal_variant_label "$variant")"
  message="female-vocal $label purificados: $slug"
  reina_preset_set_result ok "$message" "$implementation"
  return 0
}

function reina_family_female_vocal_run() {
  emulate -L zsh

  reina_female_vocal_run_core \
    "$REINA_PRESET_SLUG" \
    "$REINA_PRESET_VARIANT" \
    "female-vocal-family"
}