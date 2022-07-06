extends CanvasLayer

onready var death_text: RichTextLabel = get_node("/root/Game/CanvasLayer/Panel/HBoxContainer/Control/Death_Count")

func _ready():
	SignalBus.connect("update_death_count",self,"set_death_count")
	
func set_death_count(value: int):
	if death_text != null:
		death_text.text = str(value)
