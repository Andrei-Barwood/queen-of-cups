# Familia bass — core compartido de low-end fundacional.
#
# Semantica de transformacion (Dia 7):
#   foundational / desert — low-end seco y respirable: fundamental ancha, armonicos
#     dispersos, transientes secos; el "desierto" es espacio, no vacio.
#   base — cadena neutra: contencion suave de sub, EQ equilibrada, dinamica transparente.
#   utility — cadena directa y opinionada para colocar rapido en una mezcla.
#   smooth / nice — compresion amable, transientes redondeados, brillo contenido.
#   aggressive / crunchy — saturacion armonica, presencia media, mordida en el ataque.

function reina_bass_default_profile() {
  emulate -L zsh
  local variant="${1:-base}"

  case "$variant" in
    foundational)
      cat <<'EOF'
sub_containment=tight
fundamental_focus=wide
harmonic_density=sparse
transient_shape=dry
headroom_db=6
desert_mode=true
EOF
      ;;
    utility)
      cat <<'EOF'
sub_containment=moderate
fundamental_focus=centered
harmonic_density=balanced
transient_shape=punchy
headroom_db=4
utility_chain=high-pass+compress+saturate
EOF
      ;;
    smooth)
      cat <<'EOF'
sub_containment=gentle
fundamental_focus=rounded
harmonic_density=warm
transient_shape=soft
headroom_db=5
nice_mode=true
EOF
      ;;
    aggressive)
      cat <<'EOF'
sub_containment=firm
fundamental_focus=mid-forward
harmonic_density=rich
transient_shape=bite
headroom_db=3
crunchy_mode=true
EOF
      ;;
    *)
      cat <<'EOF'
sub_containment=moderate
fundamental_focus=balanced
harmonic_density=neutral
transient_shape=even
headroom_db=6
EOF
      ;;
  esac
}

function reina_bass_variant_label() {
  emulate -L zsh
  local variant="${1:-base}"

  case "$variant" in
    foundational) print -- "desert" ;;
    utility) print -- "utility" ;;
    smooth) print -- "nice" ;;
    aggressive) print -- "crunchy" ;;
    *) print -- "base" ;;
  esac
}

function reina_bass_variant_transform() {
  emulate -L zsh
  local variant="${1:-base}"

  case "$variant" in
    foundational)
      cat <<'EOF'
transform=desert-purify
steps=contain-sub|widen-fundamental|thin-harmonics|dry-transients|preserve-headroom
intent=low-end fundacional seco y respirable
EOF
      ;;
    utility)
      cat <<'EOF'
transform=utility-chain
steps=high-pass|compress|saturate|level-match
intent=cadena directa y opinionada
EOF
      ;;
    smooth)
      cat <<'EOF'
transform=nice-smooth
steps=gentle-compress|round-transients|soften-upper-mids|preserve-body
intent=low-end amable y equilibrado
EOF
      ;;
    aggressive)
      cat <<'EOF'
transform=crunchy-drive
steps=firm-sub|harmonic-saturate|mid-presence|bite-transients
intent=low-end con contraste y textura
EOF
      ;;
    *)
      cat <<'EOF'
transform=bass-neutral
steps=balance-sub|even-dynamics|transparent-eq
intent=low-end neutro y generalista
EOF
      ;;
  esac
}

function reina_bass_ensure_profile() {
  emulate -L zsh
  local variant="${1:-base}"
  local profile

  profile="$(reina_preset_profile_get profile "")"
  if [[ -z "$profile" ]]; then
    profile="$(reina_bass_default_profile "$variant")"
    reina_preset_profile_put profile "$profile"
  fi

  print -rn -- "$profile"
}

function reina_bass_build_recipe() {
  emulate -L zsh
  local profile="${1:-}"
  local variant="${2:-base}"
  local slug="${3:-bass}"
  local label transform

  label="$(reina_bass_variant_label "$variant")"
  transform="$(reina_bass_variant_transform "$variant")"

  print -- "preset=$slug"
  print -- "family=bass"
  print -- "variant=$variant"
  print -- "label=$label"
  print -- "$profile"
  print -- "$transform"
}

function reina_bass_run_core() {
  emulate -L zsh
  local slug="${1:-}"
  local variant="${2:-base}"
  local implementation="${3:-bass-core}"
  local profile recipe message label

  [[ -n "$slug" ]] || {
    reina_preset_set_result failed "slug de bass vacio" "$implementation"
    return 1
  }

  profile="$(reina_bass_ensure_profile "$variant")"
  recipe="$(reina_bass_build_recipe "$profile" "$variant" "$slug")"
  reina_preset_snapshot_record "$recipe" "run"

  label="$(reina_bass_variant_label "$variant")"
  message="bass $label purificado: $slug"
  reina_preset_set_result ok "$message" "$implementation"
  return 0
}

function reina_family_bass_run() {
  emulate -L zsh

  reina_bass_run_core \
    "$REINA_PRESET_SLUG" \
    "$REINA_PRESET_VARIANT" \
    "bass-family"
}