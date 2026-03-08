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
	print('interactable ready')
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		print('emite interactable')
		EventBus.interaction_prompt_show.emit(data)

func _on_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		EventBus.interaction_prompt_hide.emit()