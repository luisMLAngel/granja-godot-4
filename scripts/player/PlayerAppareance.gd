extends Node

const OPTIONAL_LAYERS: Array[String] = ["Acc", "Tool"]

var _layers: Dictionary = {}

func _ready() -> void:
	for layerName in ["Body", "Eyes", "Hair", "Acc", "Outfit", "Tool"]:
		var nodo = get_parent().get_node_or_null("Layers/" + layerName)
		if nodo:
			_layers[layerName] = nodo
		else:
			push_warning("PlayerAppearance: nodo '%s' no encontrado" % layerName)
	
	for layerName in OPTIONAL_LAYERS:
		if _layers.has(layerName):
			_layers[layerName].visible = false

func set_flip_h(valor: bool) -> void:
	for layer in _layers.values():
		layer.flip_h = valor

func equip_layer(layerName: String, textura: Texture2D, hframes: int, vframes: int = 1) -> void:
	if not _layers.has(layerName):
		push_warning("PlayerAppearance: capa '%s' no existe" % layerName)
		return
	
	_layers[layerName].texture = textura
	_layers[layerName].hframes = hframes
	_layers[layerName].vframes = vframes
	_layers[layerName].visible = true

func unequip_layer(layerName: String) -> void:
	if not _layers.has(layerName) or layerName not in OPTIONAL_LAYERS:
		return
	_layers[layerName].texture = null
	_layers[layerName].visible = false