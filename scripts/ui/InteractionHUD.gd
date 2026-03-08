class_name InteractionHUD extends CanvasLayer

# ════════════════════════════════════════════════════════════
# INTERACTION HUD
#
# Muestra un tooltip con el nombre de la acción y la tecla
# cuando el jugador está cerca de un objeto interactuable.
# Se conecta al EventBus — nunca necesita conocer los objetos.
# ════════════════════════════════════════════════════════════

@onready var panel: PanelContainer = $Panel
@onready var key_label: Label = $Panel/HBoxContainer/KeyLabel
@onready var action_label: Label = $Panel/HBoxContainer/ActionLabel

func _ready() -> void:
	panel.modulate.a = 0.0
	EventBus.interaction_prompt_show.connect(_show_prompt)
	EventBus.interaction_prompt_hide.connect(_hide_prompt)

func _show_prompt(data: InteractionData) -> void:
	if data == null:
		return
	# Obtiene el texto de la tecla desde el InputMap
	key_label.text = _get_key_text(data.action)
	action_label.text = data.label
	_animate_in()

func _hide_prompt() -> void:
	_animate_out()

func _animate_in() -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel, "modulate:a", 1.0, 0.18)
	tween.parallel().tween_property(panel, "scale", Vector2.ONE, 0.18)

func _animate_out() -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(panel, "modulate:a", 0.0, 0.12)
	tween.parallel().tween_property(panel, "scale", Vector2(0.85, 0.85), 0.12)

func _get_key_text(action: String) -> String:
	# Extrae el nombre de la primera tecla asignada al InputAction
	var events = InputMap.action_get_events(action)
	print('events', events)
	for event in events:
		if event is InputEventKey:
			return OS.get_keycode_string(event.physical_keycode)
		if event is InputEventJoypadButton:
			return "  " + _gamepad_button_label(event.button_index)
	return "?"

func _gamepad_button_label(button: int) -> String:
	match button:
		JOY_BUTTON_A: return "A"
		JOY_BUTTON_B: return "B"
		JOY_BUTTON_X: return "X"
		JOY_BUTTON_Y: return "Y"
		_: return str(button)
