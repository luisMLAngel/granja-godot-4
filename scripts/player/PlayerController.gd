class_name PlayerController extends CharacterBody2D

@export var base_speed: float = 30.0

@onready var interaction_area: Area2D = $InteractionArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var tool_controller: ToolController = $CurrentTool

var can_move: bool = true
var direction: Vector2 = Vector2.ZERO
var face_direction: Vector2 = Vector2.DOWN # indica hacia donde mira el jugador

func _ready() -> void:
	GameManager.player = self
	EventBus.dialogue_started.connect(_on_dialogue_started)
	EventBus.dialogue_finished.connect(_on_dialogue_finished)

func _physics_process(_delta: float) -> void:
	_read_input()

	if can_move:
		_apply_movement()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_try_interact()

# ── Movimiento ───────────────────────────────────────────────

func _read_input() -> void:
	direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized()

	if direction != Vector2.ZERO:
		face_direction = direction

func _apply_movement() -> void:
	velocity = direction * base_speed * _energy_modifier()
	move_and_slide()

func _energy_modifier() -> float:
	var ratio = GameManager.get_energy() / 100.0
	return lerp(0.25, 1.0, ratio)

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

# ── Eventos globales ─────────────────────────────────────────

func _on_dialogue_started(_npc_id: String) -> void:
	can_move = false
	velocity = Vector2.ZERO
	# pasar a estado idle

func _on_dialogue_finished(_npc_id: String) -> void:
	can_move = true
