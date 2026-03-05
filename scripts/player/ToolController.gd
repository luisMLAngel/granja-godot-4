class_name ToolController extends Node

enum Tool {
	HOE,
	PICKAXE,
	AXE,
	WATERING_CAN,
	SCYTHE,
	NONE
}

@export var current_tool: Tool = Tool.NONE

func set_tool(tool: Tool) -> void:
	current_tool = tool

func get_tool() -> Tool:
	return current_tool

func get_tool_name() -> String:
	match current_tool:
		Tool.HOE: return "azada"
		Tool.PICKAXE: return "pico"
		Tool.AXE: return "hacha"
		Tool.WATERING_CAN: return "regadera"
		Tool.SCYTHE: return "hoz"
		Tool.NONE: return "none"
		_: return "none"