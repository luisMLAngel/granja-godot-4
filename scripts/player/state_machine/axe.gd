extends PlayerState

var animation_finished: bool = false

func _ready() -> void:
	pass

func _on_process(_delta: float) -> void:
	pass

func _on_physics_process(_delta: float) -> void:
	pass

func _on_next_transitions() -> void:
	if animation_finished:
		transition.emit("IdleState")

func _on_enter() -> void:
	animation_finished = false
	if not player.animation_player.animation_finished.is_connected(on_animation_finished):
		player.animation_player.animation_finished.connect(on_animation_finished)
		
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
	if player.animation_player.animation_finished.is_connected(on_animation_finished):
		player.animation_player.animation_finished.disconnect(on_animation_finished)
	player.set_can_move(true)
	animation_finished = false

func on_animation_finished(anim_name: String) -> void:
	if "axe" in anim_name:
		animation_finished = true
