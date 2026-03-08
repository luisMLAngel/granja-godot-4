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
	CORRUPTED, # Tile de suelo marcado como corrompido.
					# No se puede hacer nada hasta purificar.

	OCCUPIED, # Hay un objeto instanciado encima (árbol, roca,
					# cultivo, cerca). No se puede interactuar con el suelo.

	EMPTY_WILD, # Hay pasto liso encima del suelo limpio.
					# El jugador puede removerlo con la hoz.

	CLEAN_GROUND, # Solo hay suelo, sin pasto ni objetos encima.
					# El jugador puede arar aquí.

	TILLED, # Hay tierra arada (tile en capa Terreno).
					# El jugador puede sembrar un cultivo.

	OUT_OF_RANGE, # No hay tile de suelo — fuera del rancho.
}

@onready var sprite: Sprite2D = $Sprite2D
@export var tile_system: TileSystem

# Posición actual del cursor en coordenadas de grid
var pos_actual: Vector2i = Vector2i.ZERO

var blocked_by_interaction: bool = false

func _ready() -> void:
	EventBus.interaction_prompt_show.connect(_show_interaction_prompt)
	EventBus.interaction_prompt_hide.connect(_hide_interaction_prompt)
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
	pos_actual = jugador_grid_pos + grid_offset

	# Muestra el cursor solo si hay algo interactuable frente al jugador
	if !blocked_by_interaction:
		sprite.visible = _hay_algo_interactuable(pos_actual)
		global_position = _actualizar_visual(pos_actual)

func _grid_offset_desde_direccion(direccion: Vector2) -> Vector2i:
	# En lugar de píxeles, devolvemos offsets de 1 coordenada de grilla
	if abs(direccion.x) > abs(direccion.y):
		return Vector2i(sign(direccion.x), 0)
	elif direccion.y < 0:
		return Vector2i(0, -1)
	else:
		return Vector2i(0, 1)

func _hay_algo_interactuable(pos: Vector2i) -> bool:
	# El cursor solo se muestra si hay algo con lo que
	# tenga sentido interactuar en ese tile
	var estado = tile_system.get_estado(pos)
	print('estado ->', estado)
	return estado != EstadoTile.OUT_OF_RANGE && estado != EstadoTile.OCCUPIED

func _actualizar_visual(pos: Vector2i) -> Vector2:
	# var objeto = _get_objeto_en(pos)
	# if objeto:
	# 	sprite.visible = false
	# 	return objeto.global_position
	return tile_system.grid_a_mundo(pos)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("action"):
		return

	var jugador: PlayerController = GameManager.player
	if jugador == null:
		return

	# Obtiene la herramienta equipada del jugador
	var tool: ItemData = jugador.tool_controller.get_tool()

	# Primero busca si hay un objeto instanciado en ese tile
	# Los objetos tienen prioridad sobre los tiles
	# var objeto = _get_objeto_en(pos_actual)
	# if objeto:
	# 	objeto.recibir_interaccion(tool )
	# 	return

	# Si no hay objeto, interactúa con el tile directamente
	_interactuar_con_tile(pos_actual, tool )

func _interactuar_con_tile(pos: Vector2i, tool: ItemData) -> void:
	var estado = tile_system.get_estado(pos)
	print('estado', estado)
	print('tool', tool )
	match estado:
		EstadoTile.EMPTY_WILD:
			# Solo la hoz puede remover pasto
			if tool.type == ItemData.Tool.SCYTHE:
				tile_system.remover_pasto(pos)

		EstadoTile.CLEAN_GROUND:
			# Solo la pala puede arar
			if tool.type == ItemData.Tool.PICKAXE:
				tile_system.arar(pos)

		EstadoTile.TILLED:
			# Solo semillas pueden sembrar — FarmingSystem lo maneja
			if tool.type == ItemData.Tool.HOE:
				# EventBus.tile_accion_ejecutada.emit(pos, "sembrar", {
				# 	"semilla_id": jugador.item_equipado_id
				# })
				pass

		EstadoTile.CORRUPTED:
			# Solo el purificador puede limpiar corrupción
			if tool.type == ItemData.Tool.HOE:
				tile_system.purificar(pos)

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

func _show_interaction_prompt(data: InteractionData) -> void:
	print("Show interaction prompt")
	blocked_by_interaction = true
	sprite.visible = false

func _hide_interaction_prompt() -> void:
	print("Hide interaction prompt")
	blocked_by_interaction = false
