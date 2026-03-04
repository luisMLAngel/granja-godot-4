extends CanvasLayer

@onready var day_label: RichTextLabel = $Control/TextureRect/Control/Day
@onready var time_label: RichTextLabel = $Control/TextureRect/Control/Time
@onready var month_label: RichTextLabel = $Control/TextureRect/Control/Month
@onready var year_label: RichTextLabel = $Control/TextureRect/Control/Year

func _ready() -> void:
	EventBus.hour_changed.connect(_on_hour_changed)
	# EventBus.day_changed.connect(_on_day_changed)
	# EventBus.month_changed.connect(_on_month_changed)
	# EventBus.year_changed.connect(_on_year_changed)

func _on_hour_changed(hour: float) -> void:
	time_label.text = "%02d:%02d" % [int(hour), int((hour - int(hour)) * 60)]

func _on_day_changed(day: int) -> void:
	day_label.text = "%02d" % day

func _on_month_changed(month: int) -> void:
	month_label.text = "%02d" % month

func _on_year_changed(year: int) -> void:
	year_label.text = "%02d" % year
