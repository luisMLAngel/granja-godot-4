class_name ToolController extends Node

enum Tool {
	HOE,
	PICKAXE,
	AXE,
	WATERING_CAN,
	SCYTHE,
	NONE
}

@export var current_tool: ItemData = null

func set_tool(tool: ItemData) -> void:
	current_tool = tool

func get_tool() -> ItemData:
	return current_tool

func get_tool_type() -> String:
	match current_tool.type:
		Tool.HOE: return "Hoe"
		Tool.PICKAXE: return "Pickaxe"
		Tool.AXE: return "Axe"
		Tool.WATERING_CAN: return "WateringCan"
		Tool.SCYTHE: return "Scythe"
		Tool.NONE: return "none"
		_: return "none"

func get_tool_name() -> String:
	match current_tool.type:
		Tool.HOE: return "azada"
		Tool.PICKAXE: return "pico"
		Tool.AXE: return "hacha"
		Tool.WATERING_CAN: return "regadera"
		Tool.SCYTHE: return "hoz"
		Tool.NONE: return "none"
		_: return "none"