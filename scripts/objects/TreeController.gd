class_name TreeController extends Node2D

@export var health_component: HealthComponent
@export var hurt_component: HurtComponent
@export var anim_sprite: AnimatedSprite2D
@export var overlap: OverlapComponent
# InteractableComponent se conecta solo al EventBus — no necesita código aquí

func _ready() -> void:
	health_component.died.connect(_on_health_component_died)
	health_component.health_changed.connect(_on_health_component_health_changed)
	overlap.overlapping.connect(_on_overlapping)


func _on_health_component_died() -> void:
	print("Rock died")

func _on_health_component_health_changed(current_healt: int) -> void:
	print("Rock health changed: ", current_healt)
	hurt_component.on_hurt()
	# reproducir sonido de golpe

func _on_overlapping(value: bool) -> void:
	var tween = create_tween()
	if value:
		# Jugador entró — hacer semitransparente
		tween.tween_property($AnimatedSprite2D, "modulate:a", 0.3, 0.2)
	else:
		# Jugador salió — volver a opaco
		tween.tween_property($AnimatedSprite2D, "modulate:a", 1.0, 0.2)

func recibir_interaccion(tool: ToolController.Tool) -> void:
	if tool == ToolController.Tool.PICKAXE:
		health_component.take_damage(25)
	else:
		print('Me la pela con lo que interactuas, no es un pico')
