class_name HurtComponent extends Node

@export var sprite: Node2D # el sprite que va a parpadear
@export var hurt_color: Color = Color.RED
@export var flash_duration: float = 0.1
@export var invincibility_time: float = 0.0 # 0 = sin invencibilidad

var _can_be_hurt: bool = true

func on_hurt() -> void:
	_flash()
	if invincibility_time > 0:
		_start_invincibility()

func _flash() -> void:
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", hurt_color, flash_duration)
	tween.tween_property(sprite, "modulate", Color.WHITE, flash_duration)

func _start_invincibility() -> void:
	_can_be_hurt = false
	await get_tree().create_timer(invincibility_time).timeout
	_can_be_hurt = true

func can_be_hurt() -> bool:
	return _can_be_hurt