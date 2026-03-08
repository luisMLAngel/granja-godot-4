class_name InteractionData extends Resource

# ════════════════════════════════════════════════════════════
# INTERACTION DATA
#
# Resource que cada objeto interactuable configura en el editor.
# Define qué texto mostrar y qué tecla usar.
# Se pasa al EventBus para que el HUD lo muestre.
# ════════════════════════════════════════════════════════════

@export var label: String = "Interactuar" # "Talar", "Recoger", "Abrir"...
@export var action: String = "action" # Nombre del InputAction de Godot
