class_name StateBase extends Node

var node_to_control: Node
var state_machine: StateMachineBase

@warning_ignore("unused_signal")
signal transition


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
