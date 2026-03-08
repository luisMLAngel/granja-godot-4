extends PlayerState

var animation_finished: bool = false

func _ready() -> void:
	pass

func _on_process(_delta: float) -> void:
	pass

func _on_physics_process(_delta: float) -> void:
	pass

func _on_next_transitions() -> void:
	if PlayerMovementUtils.is_moving(player.velocity):
		transition.emit("WalkState")
	elif InputUtils.is_action_pressed("action"):
		player.set_can_move(false)
		var current_tool_type = player.tool_controller.get_tool_type()
		transition.emit(current_tool_type + "State")


func _on_enter() -> void:
	animation_finished = false
	print("Axe State")
	if player.face_direction == Vector2.DOWN:
		player.animation_player.play('tool_axe_down')
	elif player.face_direction == Vector2.UP:
		player.animation_player.play('tool_axe_up')
	elif player.face_direction == Vector2.LEFT:
		player.animation_player.play('tool_axe_left')
	elif player.face_direction == Vector2.RIGHT:
		player.animation_player.play('tool_axe_right')
	else:
		player.animation_player.play('tool_axe_down')


func _on_exit() -> void:
	player.set_can_move(true)
	animation_finished = false

func on_animation_finished() -> void:
	var anim: String = player.animation_player.animation
	if anim.contains("axe"):
		animation_finished = true
