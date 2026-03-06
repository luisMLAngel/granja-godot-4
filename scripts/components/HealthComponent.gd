class_name HealthComponent extends Node

@export var max_healt: int = 100
var current_healt: int

#signals
signal health_changed(current_healt: int)
signal died

func _ready() -> void:
    current_healt = max_healt

func take_damage(amount: int) -> void:
    current_healt = clamp(current_healt - amount, 0, max_healt)
    health_changed.emit(current_healt)
    print("Current health: ", current_healt)
    if current_healt == 0:
        die()

func die() -> void:
    print("I'm dead")
    died.emit()