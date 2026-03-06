class_name RockController extends Node2D

@export var health_component: HealthComponent
@export var anim_sprite: AnimatedSprite2D

func _ready() -> void:
	health_component.died.connect(_on_health_component_died)
	health_component.health_changed.connect(_on_health_component_health_changed)

func _on_health_component_died() -> void:
	print("Rock died")

func _on_health_component_health_changed(current_healt: int) -> void:
	print("Rock health changed: ", current_healt)
