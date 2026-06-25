# Familia utility-texture-and-master — cierre del ciclo: refresco, memoria, sonrisa final.
#
# Semantica (Dia 19):
#   refresh — recuperacion y reset util; camels-need-water hidrata la red
#   lofi    — textura repetitiva, memoria corta, degradacion amable
#   master  — balance final, sweetening y consciencia del conjunto
#
# Politica de cierre:
#   Purificar el master elevando la consciencia del conjunto, no solo el bus final.

function reina_utility_texture_and_master_closure_core() {
  emulate -L zsh

  cat <<'EOF'
utility_family=texture-and-master
consciousness_level=ensemble-aware
cycle_position=closure
ensemble_scope=full-catalog
EOF
}

function reina_utility_texture_and_master_utility_matrix() {
  emulate -L zsh
  local variant="${1:-master}"

  case "$variant" in
    refresh)
      cat <<'EOF'
utility_mode=recovery-refresh
recovery_policy=gentle-reset
hydration_axis=active
camel_semantic=camels-need-water
reset_scope=runtime-context
output_kind=recovery-report
EOF
      ;;
    lofi)
      cat <<'EOF'
utility_mode=lofi-texture
texture_character=repetitive-loop
memory_span=short
degradation_policy=gentle
loop_continuity=soft-repeat
EOF
      ;;
    *)
      cat <<'EOF'
utility_mode=master-closure
master_character=final-balance
sweetening=gentle-smile
ensemble_consciousness=elevated
headroom_guard=active
EOF
      ;;
  esac
}

function reina_utility_texture_and_master_default_profile() {
  emulate -L zsh
  local variant="${1:-master}"
  local profile

  profile="$(reina_utility_texture_and_master_utility_matrix "$variant")"
  profile+=$'\n'
  profile+="$(reina_utility_texture_and_master_closure_core)"
  profile+=$'\n'
  profile+="texture_family=utility-texture-and-master"$'\n'
  profile+="variant=$variant"$'\n'

  print -rn -- "$profile"
}

function reina_utility_texture_and_master_variant_label() {
  emulate -L zsh
  local variant="${1:-master}"

  case "$variant" in
    refresh) print -- "refresh" ;;
    lofi) print -- "lofi" ;;
    *) print -- "master" ;;
  esac
}

function reina_utility_texture_and_master_variant_transform() {
  emulate -L zsh
  local variant="${1:-master}"

  case "$variant" in
    refresh)
      cat <<'EOF'
transform=camels-need-water-refresh
steps=scan-runtime|hydrate-context|gentle-reset|emit-recovery-report
intent=preset de recuperacion y refresh util dentro del bloque utilitario
recovery=true
EOF
      ;;
    lofi)
      cat <<'EOF'
transform=lofi-looper
steps=short-memory|soft-repeat|gentle-degrade|texture-loop
intent=textura repetitiva, memoria corta y degradacion amable
EOF
      ;;
    *)
      cat <<'EOF'
transform=master-smiley-face
steps=ensemble-balance|gentle-sweetening|smile-closure|headroom-guard
intent=balance final, sweetening y cierre amable del conjunto
EOF
      ;;
  esac
}

function reina_utility_texture_and_master_build_recovery_report() {
  emulate -L zsh
  local network_mode network_status config_dir state_dir report

  network_mode="$(reina_network_mode)"
  network_status="${REINA_NETWORK_LAST_STATUS:-idle}"
  config_dir="${REINA_STORE_CONFIG_DIR:-$(reina_storage_config_dir 2>/dev/null || print -- unknown)}"
  state_dir="${REINA_STORE_STATE_DIR:-$(reina_storage_state_dir 2>/dev/null || print -- unknown)}"

  report=$'Camels Need Water Recovery\n'
  report+=$'  role: refresh\n'
  report+=$"  network_mode: ${network_mode}\n"
  report+=$"  network_status: ${network_status}\n"
  report+=$"  config: ${config_dir}\n"
  report+=$"  state: ${state_dir}\n"
  report+=$'  hydration_axis: active\n'
  report+=$'  reset_policy: gentle-reset\n'
  report+=$'  catalog_status: full-cycle-ready\n'
  report+=$'  recommendation: hydrate runtime context before next processing pass\n'

  print -rn -- "$report"
}

function reina_utility_texture_and_master_ensure_profile() {
  emulate -L zsh
  local variant="${1:-master}"
  local profile

  profile="$(reina_preset_profile_get profile "")"
  if [[ -z "$profile" ]]; then
    profile="$(reina_utility_texture_and_master_default_profile "$variant")"
    reina_preset_profile_put profile "$profile"
  fi

  print -rn -- "$profile"
}

function reina_utility_texture_and_master_build_recipe() {
  emulate -L zsh
  local profile="${1:-}"
  local variant="${2:-master}"
  local slug="${3:-utility-texture-and-master}"
  local label transform recovery_report

  label="$(reina_utility_texture_and_master_variant_label "$variant")"
  transform="$(reina_utility_texture_and_master_variant_transform "$variant")"

  print -- "preset=$slug"
  print -- "family=utility-texture-and-master"
  print -- "variant=$variant"
  print -- "label=$label"
  print -- "$profile"
  print -- "$transform"

  if [[ "$variant" == "refresh" ]]; then
    recovery_report="$(reina_utility_texture_and_master_build_recovery_report)"
    print -- "recovery_report<<EOF"
    print -- "$recovery_report"
    print -- "EOF"
  fi
}

function reina_utility_texture_and_master_run_core() {
  emulate -L zsh
  local slug="${1:-}"
  local variant="${2:-master}"
  local implementation="${3:-utility-texture-and-master-core}"
  local profile recipe message label recovery_report

  [[ -n "$slug" ]] || {
    reina_preset_set_result failed "slug de utility-texture-and-master vacio" "$implementation"
    return 1
  }

  profile="$(reina_utility_texture_and_master_ensure_profile "$variant")"
  recipe="$(reina_utility_texture_and_master_build_recipe "$profile" "$variant" "$slug")"
  reina_preset_snapshot_record "$recipe" "run"

  label="$(reina_utility_texture_and_master_variant_label "$variant")"

  if [[ "$variant" == "refresh" ]]; then
    recovery_report="$(reina_utility_texture_and_master_build_recovery_report)"
    reina_preset_set_result ok "$recovery_report" "camels-need-water-refresh"
    return 0
  fi

  message="utility-texture-and-master $label purificado: $slug"
  reina_preset_set_result ok "$message" "$implementation"
  return 0
}

function reina_family_utility_texture_and_master_run() {
  emulate -L zsh

  reina_utility_texture_and_master_run_core \
    "$REINA_PRESET_SLUG" \
    "$REINA_PRESET_VARIANT" \
    "utility-texture-and-master-family"
}