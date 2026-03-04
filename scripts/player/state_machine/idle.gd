extends PlayerState

func _on_process(_delta: float) -> void:
	pass


func _on_physics_process(_delta: float) -> void:
	if player.direction == Vector2.DOWN:
		player.animation_player.play('idle_down')
	elif player.direction == Vector2.UP:
		player.animation_player.play('idle_up')
	elif player.direction == Vector2.LEFT:
		player.animation_player.play('idle_left')
	elif player.direction == Vector2.RIGHT:
		player.animation_player.play('idle_right')
	else:
		player.animation_player.play('idle_down')

func _on_next_transitions() -> void:
	if PlayerMovementUtils.is_moving(player.velocity):
		transition.emit("Walk")
	elif InputUtils.is_action_just_pressed("action"):
		player.tool_component.use_tool()


func _on_enter() -> void:
	pass


func _on_exit() -> void:
	pass
