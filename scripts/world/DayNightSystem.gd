extends Node

# ════════════════════════════════════════════════════════════
# CONFIGURACIÓN
# ════════════════════════════════════════════════════════════

@export var day_duration_seconds: float = 600.0
@export var initial_hour: float = 6.0

const DAWN_TIME: float = 6.0
const DUSK_TIME: float = 20.0
const PENALTY_FOR_NIGHT: float = 25.0
const MAX_ENERGY: float = 100.0
const MULTIPLY_TIME: float = 10.0 # 1.0 = normal, 2.0 = 2x tiempo, 0.5 = 0.5x tiempo

# ════════════════════════════════════════════════════════════
# ESTADO
# ════════════════════════════════════════════════════════════

var current_hour: float = 0.0
var current_day: int = 1
var is_night: bool = false
var nights_without_sleeping: int = 0
var vital_energy: float = MAX_ENERGY

var _seconds_per_hour: float = 0.0

func _ready() -> void:
	GameManager.day_night_system = self
	_seconds_per_hour = day_duration_seconds / 24.0 # 600 / 24 = 25 segundos por hora, o sea 10 minutos reales por día
	current_hour = initial_hour

	EventBus.energy_changed.emit(vital_energy, MAX_ENERGY)
	EventBus.hour_changed.emit(current_hour)

func _process(delta: float) -> void:
	_advance_time(delta)

# ════════════════════════════════════════════════════════════
# TIEMPO
# ════════════════════════════════════════════════════════════

func _advance_time(delta: float) -> void:
	current_hour += delta / _seconds_per_hour * MULTIPLY_TIME

	if current_hour >= 24.0:
		current_hour -= 24.0
		_new_day()

	_verify_transition()
	EventBus.hour_changed.emit(current_hour)

func _verify_transition() -> void:
	var should_be_night = current_hour >= DUSK_TIME or current_hour < DAWN_TIME

	if should_be_night and not is_night:
		_start_night()
	elif not should_be_night and is_night:
		_start_day()

func _start_night() -> void:
	is_night = true
	nights_without_sleeping += 1
	_apply_sleep_penalty()
	GameManager.is_night = true
	EventBus.started_night.emit(current_day)

func _start_day() -> void:
	is_night = false
	GameManager.is_night = false
	EventBus.started_day.emit(current_day)

func _new_day() -> void:
	current_day += 1
	GameManager.current_day = current_day

# ════════════════════════════════════════════════════════════
# ENERGÍA VITAL
# ════════════════════════════════════════════════════════════

func _apply_sleep_penalty() -> void:
	# La penalización es acumulativa — cada noche sin dormir
	# reduce el máximo de energía disponible para el día siguiente
	var penalty = PENALTY_FOR_NIGHT * nights_without_sleeping
	print("Penalty: ", penalty)
	vital_energy = max(0.0, MAX_ENERGY - penalty)
	print("Vital energy: ", vital_energy)
	EventBus.energy_changed.emit(vital_energy, MAX_ENERGY)

	if vital_energy <= 0.0:
		print("Energy depleted")
		EventBus.energy_depleted.emit()

func sleep() -> void:
	# El jugador decide dormir — resetea todo
	nights_without_sleeping = 0
	vital_energy = MAX_ENERGY

	# Salta la hora al amanecer
	current_hour = DAWN_TIME
	is_night = false
	GameManager.is_night = false

	EventBus.energy_changed.emit(vital_energy, MAX_ENERGY)
	EventBus.started_day.emit(current_day)

func modify_energy(amount: float) -> void:
	# Para efectos externos — pociones, comida, daño por corrupción
	# cantidad positiva = restaurar, negativa = reducir
	vital_energy = clamp(vital_energy + amount, 0.0, MAX_ENERGY)
	EventBus.energy_changed.emit(vital_energy, MAX_ENERGY)

	if vital_energy <= 0.0:
		EventBus.energy_depleted.emit()

# ════════════════════════════════════════════════════════════
# HELPERS PÚBLICOS
# ════════════════════════════════════════════════════════════

func get_formatted_hour() -> String:
	# Devuelve "06:30" para mostrar en la UI
	var hours = int(current_hour)
	var minutes = int((current_hour - hours) * 60)
	return "%02d:%02d" % [hours, minutes]

func get_day_percentage() -> float:
	# 0.0 = amanecer, 1.0 = anochecer
	# Útil para interpolar el color del cielo
	return clamp(
		(current_hour - DAWN_TIME) / (DUSK_TIME - DAWN_TIME),
		0.0, 1.0
	)

func is_night_time() -> bool:
	return current_hour >= DUSK_TIME or current_hour < DAWN_TIME

# ════════════════════════════════════════════════════════════
# SAVE / LOAD
# ════════════════════════════════════════════════════════════

func get_save_data() -> Dictionary:
	return {
		"current_hour":        current_hour,
		"current_day":         current_day,
		"nights_without_sleeping":  nights_without_sleeping,
		"vital_energy":      vital_energy,
	}

func load_save_data(data: Dictionary) -> void:
	current_hour       = data.get("current_hour",       DAWN_TIME)
	current_day        = data.get("current_day",        1)
	nights_without_sleeping = data.get("nights_without_sleeping", 0)
	vital_energy     = data.get("vital_energy",     MAX_ENERGY)

	# Determina si es de noche al cargar sin disparar transición
	is_night = is_night_time()
	GameManager.is_night = is_night
	GameManager.current_day = current_day

	EventBus.energy_changed.emit(vital_energy, MAX_ENERGY)
	EventBus.hour_changed.emit(current_hour)
