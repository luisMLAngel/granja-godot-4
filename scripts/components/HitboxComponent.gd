class_name HitboxComponent extends Area2D

@export var hitbox_size: Vector2 = Vector2(16, 16)
@export var hitbox_offset: Vector2 = Vector2(50, 0)
@export var damage: int = 10
@export var knockback: float = 50.0
@export var current_tool: ToolController

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	collision_shape.shape.size = hitbox_size
	collision_shape.position = hitbox_offset
	monitoring = false

func _on_body_entered(_body: Node2D) -> void:
	pass

func _on_body_exited(_body: Node2D) -> void:
	pass

func configurar(item_data: ItemData) -> void:
	$CollisionShape2D.shape.size = item_data.hitbox_size
	$CollisionShape2D.position = item_data.hitbox_offset
	damage = item_data.damage

func activar() -> void:
	monitoring = true
	await get_tree().create_timer(0.1).timeout
	monitoring = false
