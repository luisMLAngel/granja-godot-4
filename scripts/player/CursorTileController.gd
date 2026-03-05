extends Node2D

# ════════════════════════════════════════════════════════════
# TILE CURSOR
#
# Muestra un recuadro frente al jugador del tamaño de un tile.
# Sigue automáticamente la dirección del jugador.
# Al presionar interact, le pregunta al tile o al objeto
# en esa posición cómo reaccionar a la herramienta equipada.
# ════════════════════════════════════════════════════════════

enum EstadoTile {
	CORRUPTED,      # Tile de suelo marcado como corrompido.
	                # No se puede hacer nada hasta purificar.

	OCCUPIED,        # Hay un objeto instanciado encima (árbol, roca,
	                # cultivo, cerca). No se puede interactuar con el suelo.

	EMPTY_WILD,     # Hay pasto liso encima del suelo limpio.
	                # El jugador puede removerlo con la hoz.

	CLEAN_GROUND,   # Solo hay suelo, sin pasto ni objetos encima.
	                # El jugador puede arar aquí.

	TILLED,         # Hay tierra arada (tile en capa Terreno).
	                # El jugador puede sembrar un cultivo.

	OUT_OF_RANGE, # No hay tile de suelo — fuera del rancho.
}

@onready var sprite: Sprite2D = $Sprite2D
@onready var tile_system: Node = $"../TileSystem"

# Posición actual del cursor en coordenadas de grid
var pos_actual: Vector2i = Vector2i.ZERO

# Distancia en píxeles desde el jugador al centro del cursor
# Ajusta según el tamaño de tu tile (ej: 16px por tile)
const DISTANCIA_FRENTE: float = 16.0

func _ready() -> void:
	sprite.visible = false

func _process(_delta: float) -> void:
	var jugador = GameManager.jugador
	if jugador == null:
		return

	# El cursor siempre sigue al jugador — se actualiza cada frame
	_actualizar_posicion(jugador)

func _actualizar_posicion(jugador: Node) -> void:
	# Calcula el tile frente al jugador según su última dirección
	var offset = _offset_desde_direccion(jugador.ultima_direccion)
	var pos_mundo = jugador.global_position + offset

	# Convierte a coordenada de grid
	var nueva_pos = tile_system.mundo_a_grid(pos_mundo)

	# Solo actualiza el visual si el tile cambió
	if nueva_pos != pos_actual:
		pos_actual = nueva_pos
		_actualizar_visual()

	# Muestra el cursor solo si hay algo interactuable frente al jugador
	sprite.visible = _hay_algo_interactuable(pos_actual)

func _offset_desde_direccion(direccion: Vector2) -> Vector2:
	# Convierte la dirección del jugador en un offset en píxeles
	# para saber qué tile está frente a él
	if abs(direccion.x) > abs(direccion.y):
		return Vector2(DISTANCIA_FRENTE * sign(direccion.x), 0)
	elif direccion.y < 0:
		return Vector2(0, -DISTANCIA_FRENTE)
	else:
		return Vector2(0, DISTANCIA_FRENTE)

func _actualizar_visual() -> void:
	global_position = tile_system.grid_a_mundo(pos_actual)

func _hay_algo_interactuable(pos: Vector2i) -> bool:
	# El cursor solo se muestra si hay algo con lo que
	# tenga sentido interactuar en ese tile
	var estado = tile_system.get_estado(pos)
	return estado != EstadoTile.OUT_OF_RANGE

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_just_pressed("interact"):
		return

	var jugador = GameManager.jugador
	if jugador == null:
		return

	# Obtiene la herramienta equipada del jugador
	var herramienta = jugador.herramienta_equipada

	# Primero busca si hay un objeto instanciado en ese tile
	# Los objetos tienen prioridad sobre los tiles
	var objeto = _get_objeto_en(pos_actual)
	if objeto:
		objeto.recibir_interaccion(herramienta)
		return

	# Si no hay objeto, interactúa con el tile directamente
	_interactuar_con_tile(pos_actual, herramienta)

func _interactuar_con_tile(pos: Vector2i, herramienta: String) -> void:
	var estado = tile_system.get_estado(pos)

	match estado:
		EstadoTile.EMPTY_WILD:
			# Solo la hoz puede remover pasto
			if herramienta == "hoz":
				tile_system.remover_pasto(pos)
				_animar_jugador(herramienta) # ver si conviene aqui o en la maquina de estados mejor

		EstadoTile.CLEAN_GROUND:
			# Solo la pala puede arar
			if herramienta == "pala":
				tile_system.arar(pos)
				_animar_jugador(herramienta)

		EstadoTile.TILLED:
			# Solo semillas pueden sembrar — FarmingSystem lo maneja
			if herramienta == "semillas":
				# EventBus.tile_accion_ejecutada.emit(pos, "sembrar", {
				# 	"semilla_id": jugador.item_equipado_id
				# })
				_animar_jugador(herramienta)

		EstadoTile.CORRUPTED:
			# Solo el purificador puede limpiar corrupción
			if herramienta == "purificador":
				tile_system.purificar(pos)
				_animar_jugador(herramienta)

func _animar_jugador(herramienta: String) -> void:
	# Le dice a la máquina de estados que reproduzca
	# la animación correspondiente a la herramienta usada
	var anim_sm = GameManager.jugador.get_node("AnimationStateMachine")
	var tool_enum = _herramienta_a_enum(herramienta)
	anim_sm.solicitar_estado(
		anim_sm.Estado.TOOL_USE,
		tool_enum
	)

func _herramienta_a_enum(herramienta: String) -> int:
	var anim_sm = GameManager.jugador.get_node("AnimationStateMachine")
	match herramienta:
		"hacha":       return anim_sm.Herramienta.HACHA
		"pala":        return anim_sm.Herramienta.PICO
		"hoz":         return anim_sm.Herramienta.PICO
		"purificador": return anim_sm.Herramienta.PICO
		"semillas":    return anim_sm.Herramienta.SEMILLAS
		_:             return anim_sm.Herramienta.NINGUNA

func _get_objeto_en(pos: Vector2i) -> Node:
	# Busca un objeto instanciado en WorldObjects que ocupe este tile
	var world_objects = get_parent().get_node_or_null("WorldObjects")
	if world_objects == null:
		return null

	for objeto in world_objects.get_children():
		if not objeto.has_method("recibir_interaccion"):
			continue

		# Objeto simple — ocupa su propio tile
		if not objeto.has_method("get_tiles_ocupados"):
			if tile_system.mundo_a_grid(objeto.global_position) == pos:
				return objeto
		else:
			# Objeto grande — declara sus tiles
			if pos in objeto.get_tiles_ocupados():
				return objeto

	return null