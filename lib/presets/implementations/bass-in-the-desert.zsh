source "$REINA_PROJECT_ROOT/lib/presets/families/bass.zsh"

# Referencia arquitectonica de la familia bass (Dia 7).
#
# Patron recomendado para presets fundacionales:
#   1. delegar logica compartida al core de familia
#   2. fijar implementation id propio para trazabilidad
#   3. conservar semantica de variante desde el manifiesto

function reina_preset_bass_in_the_desert_run() {
  emulate -L zsh

  reina_bass_run_core \
    "$REINA_PRESET_SLUG" \
    "${REINA_PRESET_VARIANT:-foundational}" \
    "bass-in-the-desert"
}