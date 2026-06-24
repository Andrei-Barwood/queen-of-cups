# Familia vocal-utility — consciencia operativa de la red vocal.
#
# Semantica (Dia 11):
#   lead       — voz principal, foco frontal, liderazgo en la mezcla
#   assist     — diagnostico y asistencia: reporta estado util, no solo procesa
#   background — capa de apoyo, movimiento contextual, fondos con vida
#
# vocal-help es preset diagnostico: expone red, runtime y recomendaciones
# en modo humano y --json via REINA_PRESET_RESULT_MESSAGE.

function reina_vocal_utility_operational_matrix() {
  emulate -L zsh
  local variant="${1:-lead}"

  case "$variant" in
    assist)
      cat <<'EOF'
operational_mode=assist
consciousness_level=diagnostic
mix_role=support-operator
output_kind=state-report
EOF
      ;;
    background)
      cat <<'EOF'
operational_mode=background
consciousness_level=support
mix_role=contextual-life
output_kind=transform
EOF
      ;;
    *)
      cat <<'EOF'
operational_mode=lead
consciousness_level=frontal
mix_role=pop-lead
output_kind=transform
EOF
      ;;
  esac
}

function reina_vocal_utility_default_profile() {
  emulate -L zsh
  local variant="${1:-lead}"
  local profile

  profile="$(reina_vocal_utility_operational_matrix "$variant")"
  profile+=$'\n'
  profile+="vocal_stack=vocals-atmospheric,female-vocal,vocal-utility"$'\n'

  case "$variant" in
    assist)
      profile+=$'diagnostic_mode=active\nassist_scope=vocal-chain\n'
      ;;
    background)
      profile+=$'background_motion=gentle\nsupport_depth=layered\nlife_injection=moderate\n'
      ;;
    *)
      profile+=$'lead_presence=forward\npop_focus=high\nmasking_guard=active\n'
      ;;
  esac

  print -rn -- "$profile"
}

function reina_vocal_utility_variant_label() {
  emulate -L zsh
  local variant="${1:-lead}"

  case "$variant" in
    assist) print -- "assist" ;;
    background) print -- "background" ;;
    *) print -- "lead" ;;
  esac
}

function reina_vocal_utility_variant_transform() {
  emulate -L zsh
  local variant="${1:-lead}"

  case "$variant" in
    assist)
      cat <<'EOF'
transform=vocal-help-diagnostic
steps=scan-vocal-stack|report-network|check-runtime|emit-recommendations
intent=diagnostico y asistencia operativa de la cadena vocal
diagnostic=true
EOF
      ;;
    background)
      cat <<'EOF'
transform=background-life
steps=inject-movement|layer-support|preserve-context|gentle-life
intent=fondos con vida y movimiento contextual
EOF
      ;;
    *)
      cat <<'EOF'
transform=pop-lead-front
steps=frontal-focus|pop-presence|masking-guard|lead-clarity
intent=voz principal con liderazgo en la mezcla
EOF
      ;;
  esac
}

function reina_vocal_utility_build_diagnostic_report() {
  emulate -L zsh
  local network_mode network_status config_dir state_dir report

  network_mode="$(reina_network_mode)"
  network_status="${REINA_NETWORK_LAST_STATUS:-idle}"
  config_dir="${REINA_STORE_CONFIG_DIR:-$(reina_storage_config_dir 2>/dev/null || print -- unknown)}"
  state_dir="${REINA_STORE_STATE_DIR:-$(reina_storage_state_dir 2>/dev/null || print -- unknown)}"

  report=$'Vocal Help Diagnostic\n'
  report+=$'  role: assist\n'
  report+=$"  network_mode: ${network_mode}\n"
  report+=$"  network_status: ${network_status}\n"
  report+=$"  config: ${config_dir}\n"
  report+=$"  state: ${state_dir}\n"
  report+=$'  vocal_stack: vocals-atmospheric,female-vocal,vocal-utility\n'
  report+=$'  active_vocal_families: 3\n'
  report+=$'  assist_mode: diagnostic\n'
  report+=$'  recommendation: verify pop-lead-vocal before background processing\n'

  print -rn -- "$report"
}

function reina_vocal_utility_ensure_profile() {
  emulate -L zsh
  local variant="${1:-lead}"
  local profile

  profile="$(reina_preset_profile_get profile "")"
  if [[ -z "$profile" ]]; then
    profile="$(reina_vocal_utility_default_profile "$variant")"
    reina_preset_profile_put profile "$profile"
  fi

  print -rn -- "$profile"
}

function reina_vocal_utility_build_recipe() {
  emulate -L zsh
  local profile="${1:-}"
  local variant="${2:-lead}"
  local slug="${3:-vocal-utility}"
  local label transform diagnostic_report

  label="$(reina_vocal_utility_variant_label "$variant")"
  transform="$(reina_vocal_utility_variant_transform "$variant")"

  print -- "preset=$slug"
  print -- "family=vocal-utility"
  print -- "variant=$variant"
  print -- "label=$label"
  print -- "$profile"
  print -- "$transform"

  if [[ "$variant" == "assist" ]]; then
    diagnostic_report="$(reina_vocal_utility_build_diagnostic_report)"
    print -- "diagnostic_report<<EOF"
    print -- "$diagnostic_report"
    print -- "EOF"
  fi
}

function reina_vocal_utility_run_core() {
  emulate -L zsh
  local slug="${1:-}"
  local variant="${2:-lead}"
  local implementation="${3:-vocal-utility-core}"
  local profile recipe message label diagnostic_report

  [[ -n "$slug" ]] || {
    reina_preset_set_result failed "slug de vocal-utility vacio" "$implementation"
    return 1
  }

  profile="$(reina_vocal_utility_ensure_profile "$variant")"
  recipe="$(reina_vocal_utility_build_recipe "$profile" "$variant" "$slug")"
  reina_preset_snapshot_record "$recipe" "run"

  label="$(reina_vocal_utility_variant_label "$variant")"

  if [[ "$variant" == "assist" ]]; then
    diagnostic_report="$(reina_vocal_utility_build_diagnostic_report)"
    reina_preset_set_result ok "$diagnostic_report" "vocal-help-diagnostic"
    return 0
  fi

  message="vocal-utility $label purificados: $slug"
  reina_preset_set_result ok "$message" "$implementation"
  return 0
}

function reina_family_vocal_utility_run() {
  emulate -L zsh

  reina_vocal_utility_run_core \
    "$REINA_PRESET_SLUG" \
    "$REINA_PRESET_VARIANT" \
    "vocal-utility-family"
}