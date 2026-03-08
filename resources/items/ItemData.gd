class_name ItemData extends Resource

enum Tool {
	HOE,
	PICKAXE,
	AXE,
	WATERING_CAN,
	SCYTHE,
	NONE
}

@export var name: String = ""
@export var damage: int = 0
@export var hitbox_size: Vector2 = Vector2(16, 16)
@export var hitbox_offset: Vector2 = Vector2(12, 0)
@export var sprite_texture: Texture2D = null
@export var type: Tool = Tool.NONE