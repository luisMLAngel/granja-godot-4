class_name PlayerController extends CharacterBody2D

@export var base_speed: float = 80.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var anim_sm: Node = $AnimationStateMachine # referencia a la máquina
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var can_move: bool = true
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	GameManager.player = self
	EventBus.dialogue_started.connect(_on_dialogue_started)
	EventBus.dialogue_finished.connect(_on_dialogue_finished)

func _physics_process(_delta: float) -> void:
	_read_input()

	if can_move:
		_apply_movement()

	# Siempre actualiza la dirección en la máquina de estados,
	# incluso si no puede moverse (para que el idle sea correcto)
	# anim_sm.set_direction(direction)
	_request_animation_movement()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_just_pressed("interact"):
		_try_interact()

	# Esquiva
	if event.is_action_just_pressed("dodge") and can_move:
		_dodge()

# ── Movimiento ───────────────────────────────────────────────

func _read_input() -> void:
	direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()

func _apply_movement() -> void:
	velocity = direction * base_speed * _energy_modifier()
	move_and_slide()

func _energy_modifier() -> float:
	var ratio = GameManager.get_energy() / 100.0
	return lerp(0.7, 1.0, ratio)

func _request_animation_movement() -> void:
	print("direction: ", direction)
	# Solo solicita walk/idle — no sobreescribe estados bloqueantes
	# La máquina de estados rechaza el cambio si está en TOOL_USE, etc.
	# if direction != Vector2.ZERO:
	# 	anim_sm.request_state(anim_sm.Estado.WALK)
	# else:
	# 	anim_sm.request_state(anim_sm.Estado.IDLE)

func _dodge() -> void:
	print("dodge")
	# anim_sm.request_state(anim_sm.Estado.DODGE)
	# La lógica de física del dodge va aquí después

# ── Interacción ──────────────────────────────────────────────

func _try_interact() -> void:
	var objetivos = interaction_area.get_overlapping_bodies() + \
					interaction_area.get_overlapping_areas()
	var objetivo = _get_closest_target(objetivos)
	if objetivo and objetivo.has_method("interactuar"):
		objetivo.interactuar()

func _get_closest_target(candidates: Array) -> Node:
	var closest_target: Node = null
	var distancia_min: float = INF
	for c in candidates:
		var d = global_position.distance_to(c.global_position)
		if d < distancia_min:
			distancia_min = d
			closest_target = c
	return closest_target

# ── Cómo otros sistemas usan la herramienta del jugador ─────

func use_tool(tool: int) -> void:
	# Los sistemas externos (TileSystem, FarmingSystem) llaman esto
	# cuando el jugador ejecuta una acción con herramienta
	anim_sm.request_state(
		anim_sm.Estado.TOOL_USE,
		tool
	)

func receive_damage(_amount: float) -> void:
	anim_sm.request_state(anim_sm.Estado.HURT)

func die() -> void:
	anim_sm.request_state(anim_sm.Estado.DIE)
	can_move = false

# ── Eventos globales ─────────────────────────────────────────

func _on_dialogue_started(_npc_id: String) -> void:
	can_move = false
	velocity = Vector2.ZERO
	anim_sm.request_state(anim_sm.Estado.IDLE)

func _on_dialogue_finished(_npc_id: String) -> void:
	can_move = true
