class_name PlayerMovementUtils extends Node

## Devuelve true si el jugador se está moviendo (velocidad mayor a un umbral pequeño)
static func is_moving(velocity: Vector2, threshold := 1.0) -> bool:
	return velocity.length() > threshold

## Normaliza la entrada para movimiento (por ejemplo, de WASD o joystick)
static func get_input_vector() -> Vector2:
	return Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

## Determina la dirección cardinal dominante: "front", "back" o "side"
static func get_facing_direction(velocity: Vector2) -> String:
	if abs(velocity.x) > abs(velocity.y):
		return "side"
	elif velocity.y < 0:
		return "back"
	elif velocity.y > 0:
		return "front"
	return "front" # por defecto

## Devuelve la dirección como vector discreto (-1, 0, 1)
static func get_discrete_direction(velocity: Vector2) -> Vector2:
	var dir = velocity.normalized()
	return Vector2(sign(dir.x), sign(dir.y))
