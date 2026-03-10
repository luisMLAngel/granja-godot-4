class_name InteractableComponent extends Area2D

# ════════════════════════════════════════════════════════════
# INTERACTABLE COMPONENT
#
# Detecta cuando el jugador entra o sale del área de interacción.
# Emite señales al EventBus para que el HUD muestre el tooltip.
# Configura el InteractionData en el editor por cada objeto.
# ════════════════════════════════════════════════════════════

@export var data: InteractionData

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		EventBus.interaction_prompt_show.emit(data)

func _on_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		EventBus.interaction_prompt_hide.emit()

func _on_area_entered(area: Area2D) -> void:
	if area is CursorTileController:
		EventBus.interaction_prompt_show.emit(data)

func _on_area_exited(area: Area2D) -> void:
	if area is CursorTileController:
		EventBus.interaction_prompt_hide.emit()