class_name HurtboxComponent extends Area2D

signal hurt(tool: ToolController)

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		print('emite')
		hurt.emit(area.current_tool)


func _on_area_exited(area: Area2D) -> void:
	if area is HitboxComponent:
		print('sale')
		# hurt.emit()
