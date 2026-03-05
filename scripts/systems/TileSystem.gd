class_name TileSystem extends Node

# ════════════════════════════════════════════════════════════
# ESTADOS DE UN TILE
#
# El estado no se guarda en una variable — se CALCULA leyendo
# las capas del TileMap en tiempo real. Esto significa que
# siempre refleja la realidad del mundo sin necesidad de
# sincronizar manualmente.
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

# ════════════════════════════════════════════════════════════
# REFERENCIAS A LAS CAPAS
#
# Rutas relativas desde donde vive TileSystem en la escena.
# Si cambias la estructura de nodos, solo actualizas estas rutas.
# ════════════════════════════════════════════════════════════

@export var layer_suelo:    TileMapLayer
@export var layer_pasto:    TileMapLayer
@export var layer_elevaciones:    TileMapLayer
@export var layer_suelo_elevaciones:    TileMapLayer
@export var layer_pasto_deco:     TileMapLayer
@export var layer_terreno:  TileMapLayer

# Contenedor de todos los objetos instanciados en el mundo.
# Se usa para detectar si hay un objeto ocupando un tile.
@export var world_objects: Node2D

# ════════════════════════════════════════════════════════════
# ATLAS COORDS DE LOS TILES DE TERRENO
#
# Cuando el jugador ara la tierra, el sistema coloca un tile
# visual en la capa Terreno. Estos son sus atlas_coords en
# tu TileSet — ajústalos según tu spritesheet.
# ════════════════════════════════════════════════════════════

# Atlas coords del tile de tierra arada en tu TileSet
const ATLAS_TIERRA_ARADA: Vector2i = Vector2i(0, 0)

# Source ID de tu TileSet (0 si solo tienes uno)
const SOURCE_ID: int = 0

# ════════════════════════════════════════════════════════════
# INICIALIZACIÓN
# ════════════════════════════════════════════════════════════

func _ready() -> void:
	# Se registra en GameManager para que otros sistemas
	# puedan acceder con GameManager.tile_system
	GameManager.tile_system = self

# ════════════════════════════════════════════════════════════
# API PÚBLICA — CONSULTA DE ESTADO
# ════════════════════════════════════════════════════════════

func get_estado(pos: Vector2i) -> EstadoTile:
	# Calcula el estado real del tile leyendo las capas.
	# Se llama cada vez que el jugador selecciona un tile —
	# no hay estado cacheado que pueda quedar desactualizado.

	# Sin tile de suelo = fuera del área del rancho
	if layer_suelo.get_cell_source_id(pos) == -1:
		return EstadoTile.OUT_OF_RANGE

	# Suelo corrompido — leer custom data del tile de suelo
	var suelo_data = layer_suelo.get_cell_tile_data(pos)
	if suelo_data and suelo_data.get_custom_data("tile_state") == "CORRUPTED":
		return EstadoTile.CORRUPTED

	# Hay un objeto instanciado ocupando este tile
	if _hay_objeto_en(pos):
		return EstadoTile.OCCUPIED

	# Hay tierra arada en la capa Terreno
	if layer_terreno.get_cell_source_id(pos) != -1:
		return EstadoTile.TILLED

	# Hay pasto liso — se puede remover para llegar al suelo
	if layer_pasto.get_cell_source_id(pos) != -1:
		return EstadoTile.EMPTY_WILD

	# Solo suelo limpio — se puede arar
	return EstadoTile.CLEAN_GROUND

func get_tile_info(pos: Vector2i) -> Dictionary:
	# Devuelve toda la información relevante del tile.
	# Se emite en tile_seleccionado para que la UI lo muestre.
	var estado = get_estado(pos)
	return {
		"pos":      pos,
		"estado":   estado,
		"acciones": 'Las define el objeto o tile',
	}

# ════════════════════════════════════════════════════════════
# API PÚBLICA — SELECCIÓN
# ════════════════════════════════════════════════════════════

func seleccionar_tile(pos: Vector2i) -> void:
	# Llamado por TileCursor cuando el jugador confirma selección.
	# Emite la señal con la info del tile para que el ActionMenu
	# la reciba y muestre las opciones correctas.
	var info = get_tile_info(pos)

	# Si no hay acciones disponibles, no hay nada que mostrar
	if info["acciones"].is_empty():
		return

	EventBus.tile_selected.emit(pos, info)

# ════════════════════════════════════════════════════════════
# ACCIONES SOBRE TILES
#
# Cada función modifica exactamente lo que necesita —
# solo la capa que corresponde a esa acción.
# ════════════════════════════════════════════════════════════

func remover_pasto(pos: Vector2i) -> void:
	if get_estado(pos) != EstadoTile.EMPTY_WILD:
		push_warning("TileSystem: no se puede remover pasto en %s" % pos)
		return

	# En lugar de erase_cell, usamos el sistema de terrenos.
	# El -1 como terrain_id le dice a Godot "este tile ya no
	# pertenece a ningún terrain" y recalcula los vecinos solos.
	layer_pasto.set_cells_terrain_connect([pos], 0, -1)
	layer_pasto_deco.erase_cell(pos)

func arar(pos: Vector2i) -> void:
	# Coloca un tile de tierra arada en la capa Terreno.
	# Solo válido sobre suelo limpio (sin pasto ni objetos).

	if get_estado(pos) != EstadoTile.CLEAN_GROUND:
		push_warning("TileSystem: no se puede arar en %s" % pos)
		return

	layer_terreno.set_cell(pos, SOURCE_ID, ATLAS_TIERRA_ARADA)

func limpiar_arado(pos: Vector2i) -> void:
	# Remueve la tierra arada — vuelve a suelo limpio.
	# Útil si el jugador quiere deshacer el arado.
	layer_terreno.erase_cell(pos)

func purificar(pos: Vector2i) -> void:
	# Purifica un tile corrompido — lo convierte en suelo normal.
	# En el futuro esto puede requerir un item específico.

	if get_estado(pos) != EstadoTile.CORRUPTED:
		push_warning("TileSystem: el tile %s no está corrompido" % pos)
		return

	# Modifica el custom data del tile de suelo a "NORMAL"
	# Para esto necesitamos reemplazar el tile — Godot no permite
	# editar custom data en runtime, así que recolocamos el tile
	# con un source diferente o usamos un tile alternativo.
	# La forma más simple: recolocar el mismo tile con atlas diferente.
	var atlas_suelo_normal = layer_suelo.get_cell_atlas_coords(pos)
	layer_suelo.set_cell(pos, SOURCE_ID, atlas_suelo_normal)
	# Nota: necesitarás tener un tile de "suelo normal" con
	# tile_state = "NORMAL" en tu TileSet para esto.

# ════════════════════════════════════════════════════════════
# DETECCIÓN DE OBJETOS INSTANCIADOS
#
# Determina si hay un objeto (árbol, roca, cultivo, etc.)
# ocupando una posición del grid.
# ════════════════════════════════════════════════════════════

func _hay_objeto_en(pos: Vector2i) -> bool:
	# Convierte la posición del grid a posición mundial
	var pos_mundo = layer_suelo.to_global(layer_suelo.map_to_local(pos))

	# Revisa todos los objetos instanciados en WorldObjects
	for objeto in world_objects.get_children():
		if not objeto.has_method("get_tiles_ocupados"):
			# Objeto simple — ocupa solo el tile en su posición
			var objeto_tile = _mundo_a_grid(objeto.global_position)
			if objeto_tile == pos:
				return true
		else:
			# Objeto grande (árbol) — declara qué tiles ocupa
			if pos in objeto.get_tiles_ocupados():
				return true

	return false

func _mundo_a_grid(pos_mundo: Vector2) -> Vector2i:
	# Convierte posición global a coordenada del grid
	return layer_suelo.local_to_map(layer_suelo.to_local(pos_mundo))

# ════════════════════════════════════════════════════════════
# CONVERSIÓN DE COORDENADAS
#
# Helpers públicos para que otros sistemas (TileCursor,
# FarmingSystem) puedan convertir entre coordenadas.
# ════════════════════════════════════════════════════════════

func mundo_a_grid(pos_mundo: Vector2) -> Vector2i:
	return layer_suelo.local_to_map(layer_suelo.to_local(pos_mundo))

func grid_a_mundo(pos_grid: Vector2i) -> Vector2:
	return layer_suelo.to_global(layer_suelo.map_to_local(pos_grid))

# ════════════════════════════════════════════════════════════
# ESCUCHA EVENTOS
# ════════════════════════════════════════════════════════════


# ════════════════════════════════════════════════════════════
# SAVE / LOAD
#
# El TileSystem no guarda el estado de los tiles normales —
# eso lo hacen los TileMapLayer automáticamente si usas
# el sistema de guardado de Godot.
#
# Lo único que necesita guardar es qué tiles están corrompidos,
# porque eso es custom data que no persiste solo.
# ════════════════════════════════════════════════════════════

func get_save_data() -> Dictionary:
	# Guarda las posiciones de tiles corrompidos y tierra arada
	var corrompidos: Array = []
	var arados: Array = []

	for pos in layer_suelo.get_used_cells():
		var data = layer_suelo.get_cell_tile_data(pos)
		if data and data.get_custom_data("tile_state") == "CORRUPTED":
			corrompidos.append({ "x": pos.x, "y": pos.y })

	for pos in layer_terreno.get_used_cells():
		arados.append({ "x": pos.x, "y": pos.y })

	return {
		"corrompidos": corrompidos,
		"arados":      arados,
	}

func load_save_data(data: Dictionary) -> void:
	# Restaura la tierra arada
	layer_terreno.clear()
	for entry in data.get("arados", []):
		var pos = Vector2i(entry["x"], entry["y"])
		layer_terreno.set_cell(pos, SOURCE_ID, ATLAS_TIERRA_ARADA)

	# Los tiles corrompidos se restauran recolocando el tile
	# con el custom data correcto — esto depende de cómo
	# tengas configurado tu TileSet
	for entry in data.get("corrompidos", []):
		var pos = Vector2i(entry["x"], entry["y"])
		# Por ahora solo registra — implementar según TileSet
		pass