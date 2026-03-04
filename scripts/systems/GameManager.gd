extends Node

# ── Referencias a sistemas ───────────────────────────────────
# Se asignan solos cuando cada sistema hace _ready()
var day_night_system: Node = null
var farming_system: Node = null
var tile_system: Node = null
var inventory_system: Node = null
var zone_system: Node = null
var lore_system: Node = null

# ── Referencia al jugador ────────────────────────────────────
var player: Node = null

# ── Estado mínimo global ─────────────────────────────────────
# Solo lo que múltiples sistemas necesitan leer
var current_day: int = 1
var is_night: bool = false
var current_zone: String = "zona_0"

func _ready() -> void:
	# Escucha eventos que afectan el estado global
	EventBus.started_day.connect(_on_started_day)
	EventBus.started_night.connect(_on_started_night)
	EventBus.zone_changed.connect(_on_zone_changed)

func _on_started_day(day: int) -> void:
	current_day = day
	is_night = false

func _on_started_night(day: int) -> void:
	current_day = day
	is_night = true

func _on_zone_changed(zone_id: String) -> void:
	current_zone = zone_id

# ── Helpers para sistemas ────────────────────────────────────
# Atajos para no buscar el sistema cada vez
func get_energy() -> float:
	if day_night_system:
		return day_night_system.energy_vital
	return 100.0

func get_hour() -> float:
	if day_night_system:
		return day_night_system.hora_actual
	return 6.0