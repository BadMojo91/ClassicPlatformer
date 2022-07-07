extends RichTextLabel

func _ready():
	SignalBus.connect("update_level_name", self, "_update_level")
	
func _update_level(level: String):
	text = level

