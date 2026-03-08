class_name HurtboxComponent extends Area2D

signal hurt(tool: ToolController)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is HitboxComponent:
		print('emite')
		hurt.emit(body.current_tool)


func _on_body_exited(body: Node2D) -> void:
	if body is HitboxComponent:
		print('sale')
	    # hurt.emit()