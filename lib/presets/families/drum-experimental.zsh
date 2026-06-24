# Familia drum-experimental — capas paralelas y texturas no lineales.
#
# Semantica (Dia 13):
#   parallel      — base experimental de capas paralelas
#   parallel-pop  — paralelo pulido y pop (myon-pop-parallel-magic)
#   parallel-wild — paralelo salvaje y contrastado (wildin-camel-drums)
#   gated         — cortes deliberados y gating no lineal
#
# Degradacion segura: si faltan dependencias opcionales, la capa experimental
# continua con fallback local y marca degraded — nunca fallo fatal.

function reina_drum_experimental_missing_dependencies() {
  emulate -L zsh
  local variant="${1:-parallel}"
  local -a missing=()
  local curl_bin="${REINA_NETWORK_CURL_BIN:-curl}"

  if [[ -n "${REINA_DRUM_EXPERIMENTAL_FORCE_MISSING:-}" ]]; then
    print -rn -- "$REINA_DRUM_EXPERIMENTAL_FORCE_MISSING"
    return 0
  fi

  case "$variant" in
    gated)
      command -v awk >/dev/null 2>&1 || missing+=("awk")
      ;;
    parallel|parallel-pop|parallel-wild)
      if (( REINA_OFFLINE )); then
        missing+=("network-online")
      elif ! command -v "$curl_bin" >/dev/null 2>&1; then
        missing+=("curl")
      fi
      ;;
  esac

  print -rn -- "${(j:,:)missing}"
}

function reina_drum_experimental_layer_mode() {
  emulate -L zsh
  local variant="${1:-parallel}"
  local missing

  missing="$(reina_drum_experimental_missing_dependencies "$variant")"
  if [[ -n "$missing" ]]; then
    print -- "local-fallback"
  else
    print -- "full-experimental"
  fi
}

function reina_drum_experimental_apply_degradation_if_needed() {
  emulate -L zsh
  local variant="${1:-parallel}"
  local missing layer_mode

  missing="$(reina_drum_experimental_missing_dependencies "$variant")"
  [[ -n "$missing" ]] || return 0

  layer_mode="$(reina_drum_experimental_layer_mode "$variant")"
  reina_degrade \
    ERR_RUNTIME_DEPENDENCY_MISSING \
    "capa experimental degradada; usando fallback local" \
    "preset" \
    "slug=${REINA_PRESET_SLUG:-} variant=$variant missing=$missing layer=$layer_mode" \
    "local_experimental_fallback"

  return 0
}

function reina_drum_experimental_texture_matrix() {
  emulate -L zsh
  local variant="${1:-parallel}"
  local layer_mode="${2:-full-experimental}"

  case "$variant" in
    parallel-pop)
      cat <<EOF
texture_mode=parallel-pop
parallel_blend=polished
pop_magic=active
layer_mode=$layer_mode
EOF
      ;;
    parallel-wild)
      cat <<EOF
texture_mode=parallel-wild
parallel_blend=contrast
camel_wild=active
layer_mode=$layer_mode
EOF
      ;;
    gated)
      cat <<EOF
texture_mode=gated
gate_shape=deliberate-cuts
nonlinear_texture=active
layer_mode=$layer_mode
EOF
      ;;
    *)
      cat <<EOF
texture_mode=parallel-base
parallel_blend=stacked
risk_control=moderate
layer_mode=$layer_mode
EOF
      ;;
  esac
}

function reina_drum_experimental_default_profile() {
  emulate -L zsh
  local variant="${1:-parallel}"
  local layer_mode="${2:-full-experimental}"
  local profile missing

  profile="$(reina_drum_experimental_texture_matrix "$variant" "$layer_mode")"
  profile+=$'\n'
  profile+="experimental_family=drum-experimental"$'\n'
  missing="$(reina_drum_experimental_missing_dependencies "$variant")"
  profile+="missing_dependencies=${missing:-none}"$'\n'

  print -rn -- "$profile"
}

function reina_drum_experimental_variant_label() {
  emulate -L zsh
  local variant="${1:-parallel}"

  case "$variant" in
    parallel-pop) print -- "parallel-pop" ;;
    parallel-wild) print -- "parallel-wild" ;;
    gated) print -- "gated" ;;
    *) print -- "parallel" ;;
  esac
}

function reina_drum_experimental_variant_transform() {
  emulate -L zsh
  local variant="${1:-parallel}"
  local layer_mode="${2:-full-experimental}"

  case "$variant" in
    parallel-pop)
      cat <<EOF
transform=myon-pop-parallel-magic
steps=stack-parallel|pop-polish|blend-magic|preserve-punch
intent=paralelo pulido y pop con riesgo controlado
layer_mode=$layer_mode
EOF
      ;;
    parallel-wild)
      cat <<EOF
transform=wildin-camel-parallel
steps=stack-parallel|wild-contrast|camel-energy|controlled-risk
intent=paralelo salvaje y contrastado
layer_mode=$layer_mode
camel_wild=active
EOF
      ;;
    gated)
      cat <<EOF
transform=wierdly-gated
steps=analyze-transients|deliberate-gates|nonlinear-texture|preserve-groove
intent=gating deliberado y textura no lineal
layer_mode=$layer_mode
EOF
      ;;
    *)
      cat <<EOF
transform=parallel-processing
steps=split-signal|stack-layers|blend-parallel|controlled-risk
intent=capas paralelas experimentales con riesgo controlado
layer_mode=$layer_mode
EOF
      ;;
  esac
}

function reina_drum_experimental_ensure_profile() {
  emulate -L zsh
  local variant="${1:-parallel}"
  local layer_mode="${2:-full-experimental}"
  local profile

  profile="$(reina_preset_profile_get profile "")"
  if [[ -z "$profile" ]]; then
    profile="$(reina_drum_experimental_default_profile "$variant" "$layer_mode")"
    reina_preset_profile_put profile "$profile"
  fi

  print -rn -- "$profile"
}

function reina_drum_experimental_build_recipe() {
  emulate -L zsh
  local profile="${1:-}"
  local variant="${2:-parallel}"
  local slug="${3:-drum-experimental}"
  local layer_mode="${4:-full-experimental}"
  local label transform

  label="$(reina_drum_experimental_variant_label "$variant")"
  transform="$(reina_drum_experimental_variant_transform "$variant" "$layer_mode")"

  print -- "preset=$slug"
  print -- "family=drum-experimental"
  print -- "variant=$variant"
  print -- "label=$label"
  print -- "layer_mode=$layer_mode"
  print -- "$profile"
  print -- "$transform"
}

function reina_drum_experimental_run_core() {
  emulate -L zsh
  local slug="${1:-}"
  local variant="${2:-parallel}"
  local implementation="${3:-drum-experimental-core}"
  local layer_mode profile recipe message label result_status="ok"

  [[ -n "$slug" ]] || {
    reina_preset_set_result failed "slug de drum-experimental vacio" "$implementation"
    return 1
  }

  reina_drum_experimental_apply_degradation_if_needed "$variant"
  layer_mode="$(reina_drum_experimental_layer_mode "$variant")"
  [[ "$layer_mode" == "local-fallback" ]] && result_status="degraded"

  profile="$(reina_drum_experimental_ensure_profile "$variant" "$layer_mode")"
  recipe="$(reina_drum_experimental_build_recipe "$profile" "$variant" "$slug" "$layer_mode")"
  reina_preset_snapshot_record "$recipe" "run"

  label="$(reina_drum_experimental_variant_label "$variant")"
  if [[ "$result_status" == "degraded" ]]; then
    message="drum-experimental $label degradado (fallback local): $slug"
  else
    message="drum-experimental $label purificado: $slug"
  fi

  reina_preset_set_result "$result_status" "$message" "$implementation"
  return 0
}

function reina_family_drum_experimental_run() {
  emulate -L zsh

  reina_drum_experimental_run_core \
    "$REINA_PRESET_SLUG" \
    "$REINA_PRESET_VARIANT" \
    "drum-experimental-family"
}