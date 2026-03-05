class_name PlayerInputUtils extends Node

# Verifica si el mouse está sobre un Control (UI)
func _is_mouse_over_ui() -> bool:
	return get_viewport().gui_get_hovered_control() != null

func _is_mouse_over_blocking_ui() -> bool:
	var hovered = get_viewport().gui_get_hovered_control()
	return hovered and hovered.is_in_group("block_input")

# Verifica si una acción acaba de ser presionada este frame
func is_action_just_pressed(action_name: String) -> bool:
	if _is_mouse_over_blocking_ui():
		return false
	return Input.is_action_pressed(action_name)

# Verifica si una acción está siendo sostenida
func is_action_pressed(action_name: String) -> bool:
	if _is_mouse_over_blocking_ui():
		return false
	return Input.is_action_pressed(action_name)

# Verifica si una acción acaba de ser soltada este frame
func is_action_just_released(action_name: String) -> bool:
	if _is_mouse_over_blocking_ui():
		return false
	return Input.is_action_just_released(action_name)
