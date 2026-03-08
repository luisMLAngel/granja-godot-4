class_name HitboxComponent extends Area2D

signal hurt(damage: int)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is HitboxComponent:
		print('emite')
		in_interactable_zone.emit(true)


func _on_body_exited(body: Node2D) -> void:
	if body is HitboxComponent:
		print('sale')
	    in_interactable_zone.emit(false)