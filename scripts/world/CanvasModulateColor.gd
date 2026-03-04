# En un script simple en Zone0_Parcela.gd o similar

extends Node

@export var modulate_node: CanvasModulate

# Colores del cielo en distintos momentos del día
const DAY_COLOR:      Color = Color(1.0,  1.0,  1.0)   # blanco normal
const DUSK_COLOR:    Color = Color(1.0,  0.75, 0.5)   # naranja cálido
const NIGHT_COLOR:    Color = Color(0.08, 0.08, 0.18)  # azul muy oscuro
const DAWN_COLOR: Color = Color(0.6,  0.5,  0.7)   # violeta suave

func _ready() -> void:
	EventBus.hour_changed.connect(_on_hour_changed)

func _on_hour_changed(hour: float) -> void:
	modulate_node.color = _color_for_hour(hour)

func _color_for_hour(hour: float) -> Color:
	# Interpola entre colores según la hora
	if hour < 6.0:    # madrugada
		return NIGHT_COLOR.lerp(DAWN_COLOR, hour / 6.0)
	elif hour < 8.0:  # amanecer
		return DAWN_COLOR.lerp(DAY_COLOR, (hour - 6.0) / 2.0)
	elif hour < 17.0: # día
		return DAY_COLOR
	elif hour < 20.0: # tarde
		return DAY_COLOR.lerp(DUSK_COLOR, (hour - 17.0) / 3.0)
	elif hour < 21.0: # anochecer
		return DUSK_COLOR.lerp(NIGHT_COLOR, (hour - 20.0) / 1.0)
	else:             # noche
		return NIGHT_COLOR
