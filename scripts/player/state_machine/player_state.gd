class_name PlayerState extends StateBase

var player: PlayerController:
	set(value):
		node_to_control = value
	get:
		return node_to_control

func _on_process(_delta: float) -> void:
	pass


func _on_physics_process(_delta: float) -> void:
	pass


func _on_next_transitions() -> void:
	pass


func _on_enter() -> void:
	pass


func _on_exit() -> void:
	pass
