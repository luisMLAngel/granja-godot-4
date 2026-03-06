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
@export var tile_system: TileSystem

# Posición actual del cursor en coordenadas de grid
var pos_actual: Vector2i = Vector2i.ZERO

func _ready() -> void:
	sprite.position = Vector2.ZERO
	sprite.visible = false

func _process(_delta: float) -> void:
	var jugador = GameManager.player
	if jugador == null:
		return

	# El cursor siempre sigue al jugador — se actualiza cada frame
	_actualizar_posicion(jugador)

func _actualizar_posicion(jugador: Node) -> void:
	# 1. Obtiene en qué celda exacta del grid está el jugador actualmente
	var jugador_grid_pos = tile_system.mundo_a_grid(jugador.global_position)
	
	# 2. Calcula el tile contiguo basado en su dirección
	var grid_offset = _grid_offset_desde_direccion(jugador.face_direction)
	var nueva_pos = jugador_grid_pos + grid_offset

	# Solo actualiza el visual si el tile cambió
	if nueva_pos != pos_actual:
		pos_actual = nueva_pos
		_actualizar_visual()

	# Muestra el cursor solo si hay algo interactuable frente al jugador
	sprite.visible = _hay_algo_interactuable(pos_actual)
	# sprite.visible = true

func _grid_offset_desde_direccion(direccion: Vector2) -> Vector2i:
	# En lugar de píxeles, devolvemos offsets de 1 coordenada de grilla
	if abs(direccion.x) > abs(direccion.y):
		return Vector2i(sign(direccion.x), 0)
	elif direccion.y < 0:
		return Vector2i(0, -1)
	else:
		return Vector2i(0, 1)

func _actualizar_visual() -> void:
	global_position = tile_system.grid_a_mundo(pos_actual)

func _hay_algo_interactuable(pos: Vector2i) -> bool:
	# El cursor solo se muestra si hay algo con lo que
	# tenga sentido interactuar en ese tile
	var info = tile_system.get_tile_info(pos)
	if info["estado"] == EstadoTile.OCCUPIED:
		# si hay un objeto se debe mover el cursor justo encima del objeto
		global_position = tile_system.grid_a_mundo(info["pos"])
		return true
	return info["estado"] != EstadoTile.OUT_OF_RANGE

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("action"):
		return

	var jugador: PlayerController = GameManager.player
	print('jugador', jugador)
	if jugador == null:
		return

	# Obtiene la herramienta equipada del jugador
	var tool: ToolController.Tool = jugador.tool_controller.get_tool()

	# Primero busca si hay un objeto instanciado en ese tile
	# Los objetos tienen prioridad sobre los tiles
	var objeto = _get_objeto_en(pos_actual)
	if objeto:
		objeto.recibir_interaccion(tool)
		return

	# Si no hay objeto, interactúa con el tile directamente
	_interactuar_con_tile(pos_actual, tool)

func _interactuar_con_tile(pos: Vector2i, tool: ToolController.Tool) -> void:
	print('interactuar con tile', pos, tool)
	var estado = tile_system.get_estado(pos)
	print('estado', estado)
	match estado:
		EstadoTile.EMPTY_WILD:
			# Solo la hoz puede remover pasto
			if tool == ToolController.Tool.SCYTHE:
				tile_system.remover_pasto(pos)
				_animar_jugador(tool) # ver si conviene aqui o en la maquina de estados mejor

		EstadoTile.CLEAN_GROUND:
			# Solo la pala puede arar
			if tool == ToolController.Tool.PICKAXE:
				tile_system.arar(pos)
				_animar_jugador(tool)

		EstadoTile.TILLED:
			# Solo semillas pueden sembrar — FarmingSystem lo maneja
			if tool == ToolController.Tool.HOE:
				# EventBus.tile_accion_ejecutada.emit(pos, "sembrar", {
				# 	"semilla_id": jugador.item_equipado_id
				# })
				_animar_jugador(tool)

		EstadoTile.CORRUPTED:
			# Solo el purificador puede limpiar corrupción
			if tool == ToolController.Tool.HOE:
				tile_system.purificar(pos)
				_animar_jugador(tool)

func _animar_jugador(tool: ToolController.Tool) -> void:
	pass
	# Le dice a la máquina de estados que reproduzca
	# la animación correspondiente a la herramienta usada
	# var anim_sm = GameManager.player.get_node("AnimationStateMachine")
	# var tool_enum = _herramienta_a_enum(tool)
	# anim_sm.solicitar_estado(
	# 	anim_sm.Estado.TOOL_USE,
	# 	tool_enum
	# )

func _herramienta_a_enum(tool: ToolController.Tool) -> int:
	var anim_sm = GameManager.player.get_node("AnimationStateMachine")
	match tool:
		ToolController.Tool.AXE:       return anim_sm.Herramienta.HACHA
		ToolController.Tool.PICKAXE:        return anim_sm.Herramienta.PICO
		ToolController.Tool.SCYTHE:         return anim_sm.Herramienta.PICO
		ToolController.Tool.HOE: return anim_sm.Herramienta.PICO
		ToolController.Tool.WATERING_CAN:    return anim_sm.Herramienta.SEMILLAS
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
