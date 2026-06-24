# Familia low-end — purificacion del subsuelo sonoro bajo 120 Hz.
#
# Relacion bass <-> low-end:
#   bass       — low-end fundacional y generalista (familia hermana, prioridad 010-050)
#   low-end    — profundiza organicidad, sintesis e impacto controlado (060-080)
#   808-boom-control actua como gobernador de subgrave dominante; upright-bass hereda
#   contencion del core bass; synth-bass permanece aislado para no interferir.
#
# Semantica de transformacion (Dia 8):
#   organic / upright   — cuerpo resonante, armonicos maderosos, sub contenido con herencia bass
#   synthetic / synth   — sub sintetico limpio, armonicos controlados, sin resonancia organica
#   impact / 808        — golpe de sub dominante con contencion firme y headroom reservado

function reina_low_end_bass_inherit_enabled() {
  emulate -L zsh
  local variant="${1:-}"

  [[ "$variant" == "organic" ]]
}

function reina_low_end_load_bass_core() {
  emulate -L zsh

  if (( ! ${+functions[reina_bass_default_profile]} )); then
    source "$REINA_PROJECT_ROOT/lib/presets/families/bass.zsh"
  fi
}

function reina_low_end_sub_policy() {
  emulate -L zsh
  local variant="${1:-base}"

  case "$variant" in
    organic)
      cat <<'EOF'
sub_policy=contain-gentle
headroom_db=7
frequency_band=below_120hz
bass_relation=inherit-containment
boom_control=defer-to-bass-body
EOF
      ;;
    synthetic)
      cat <<'EOF'
sub_policy=contain-moderate
headroom_db=5
frequency_band=below_120hz
bass_relation=isolated
non_interference=upright-bass
boom_control=none
EOF
      ;;
    impact)
      cat <<'EOF'
sub_policy=contain-firm
headroom_db=4
frequency_band=sub_dominant
bass_relation=govern-808
boom_control=active
808_governor=true
EOF
      ;;
    *)
      cat <<'EOF'
sub_policy=contain-moderate
headroom_db=6
frequency_band=below_120hz
bass_relation=coordinate
boom_control=passive
EOF
      ;;
  esac
}

function reina_low_end_default_profile() {
  emulate -L zsh
  local variant="${1:-base}"
  local profile bass_hint

  case "$variant" in
    organic)
      profile=$'source_character=woody\nresonance_mode=body-forward\nsub_blend=natural\nharmonic_texture=organic\n'
      ;;
    synthetic)
      profile=$'source_character=synthetic\nresonance_mode=sub-forward\nsub_blend=isolated\nharmonic_texture=controlled\n'
      ;;
    impact)
      profile=$'source_character=808\nresonance_mode=sub-dominant\nsub_blend=punchy\nharmonic_texture=minimal\n'
      ;;
    *)
      profile=$'source_character=mixed\nresonance_mode=balanced\nsub_blend=moderate\nharmonic_texture=neutral\n'
      ;;
  esac

  if reina_low_end_bass_inherit_enabled "$variant"; then
    reina_low_end_load_bass_core
    bass_hint="$(reina_bass_default_profile base)"
    profile+=$'bass_inherit=enabled\n'
    profile+="$bass_hint"
  else
    profile+=$'bass_inherit=disabled\n'
  fi

  profile+="$(reina_low_end_sub_policy "$variant")"
  print -rn -- "$profile"
}

function reina_low_end_variant_label() {
  emulate -L zsh
  local variant="${1:-base}"

  case "$variant" in
    organic) print -- "upright" ;;
    synthetic) print -- "synth" ;;
    impact) print -- "808" ;;
    *) print -- "sub" ;;
  esac
}

function reina_low_end_variant_transform() {
  emulate -L zsh
  local variant="${1:-base}"

  case "$variant" in
    organic)
      cat <<'EOF'
transform=upright-organic
steps=inherit-bass-containment|warm-body|wood-harmonics|gentle-sub-roll|preserve-resonance
intent=lectura organica y resonante del subsuelo
isolation=synth-bass
EOF
      ;;
    synthetic)
      cat <<'EOF'
transform=synth-sub
steps=clean-sub-synthesis|control-harmonics|isolate-organic-bleed|tight-transients
intent=sub sintetico limpio sin resonancia organica
isolation=upright-bass
EOF
      ;;
    impact)
      cat <<'EOF'
transform=808-boom-govern
steps=firm-sub-contain|punch-transient|reserve-headroom|govern-sub-dominance|coordinate-bass-body
intent=impacto controlado y subgrave dominante
isolation=stacking-guard
EOF
      ;;
    *)
      cat <<'EOF'
transform=low-end-neutral
steps=balance-sub|coordinate-bass|preserve-headroom
intent=subsuelo sonoro equilibrado
EOF
      ;;
  esac
}

function reina_low_end_ensure_profile() {
  emulate -L zsh
  local variant="${1:-base}"
  local profile

  profile="$(reina_preset_profile_get profile "")"
  if [[ -z "$profile" ]]; then
    profile="$(reina_low_end_default_profile "$variant")"
    reina_preset_profile_put profile "$profile"
  fi

  print -rn -- "$profile"
}

function reina_low_end_build_recipe() {
  emulate -L zsh
  local profile="${1:-}"
  local variant="${2:-base}"
  local slug="${3:-low-end}"
  local label transform

  label="$(reina_low_end_variant_label "$variant")"
  transform="$(reina_low_end_variant_transform "$variant")"

  print -- "preset=$slug"
  print -- "family=low-end"
  print -- "variant=$variant"
  print -- "label=$label"
  print -- "$profile"
  print -- "$transform"
}

function reina_low_end_run_core() {
  emulate -L zsh
  local slug="${1:-}"
  local variant="${2:-base}"
  local implementation="${3:-low-end-core}"
  local profile recipe message label

  [[ -n "$slug" ]] || {
    reina_preset_set_result failed "slug de low-end vacio" "$implementation"
    return 1
  }

  profile="$(reina_low_end_ensure_profile "$variant")"
  recipe="$(reina_low_end_build_recipe "$profile" "$variant" "$slug")"
  reina_preset_snapshot_record "$recipe" "run"

  label="$(reina_low_end_variant_label "$variant")"
  message="low-end $label purificado: $slug"
  reina_preset_set_result ok "$message" "$implementation"
  return 0
}

function reina_family_low_end_run() {
  emulate -L zsh

  reina_low_end_run_core \
    "$REINA_PRESET_SLUG" \
    "$REINA_PRESET_VARIANT" \
    "low-end-family"
}