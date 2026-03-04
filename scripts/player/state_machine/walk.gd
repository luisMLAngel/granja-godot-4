extends PlayerState

func _on_process(_delta: float) -> void:
	pass


func _on_physics_process(_delta: float) -> void:
	if player.face_direction == Vector2.DOWN:
		player.animation_player.play('walk_down')
	elif player.face_direction == Vector2.UP:
		player.animation_player.play('walk_up')
	elif player.face_direction == Vector2.LEFT:
		player.animation_player.play('walk_left')
	elif player.face_direction == Vector2.RIGHT:
		player.animation_player.play('walk_right')
	else:
		player.animation_player.play('walk_down')

func _on_next_transitions() -> void:
	if !PlayerMovementUtils.is_moving(player.velocity):
		transition.emit("IdleState")
	elif InputUtils.is_action_pressed("action"):
		player.tool_component.use_tool()


func _on_enter() -> void:
	pass


func _on_exit() -> void:
	player.animation_player.stop()
