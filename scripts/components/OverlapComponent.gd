class_name OverlapComponent extends Area2D

signal overlapping(value: bool)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
func _on_body_entered(body: Node2D) -> void:
	print('body entered')
	if body is PlayerController:
		print('emite')
		overlapping.emit(true)


func _on_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		print('sale')
		overlapping.emit(false)
