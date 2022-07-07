extends RichTextLabel

var completed = -1

func _ready() -> void:
	SignalBus.connect("load_level", self, "_update_completed_count")
	
func _update_completed_count(level):
	completed += 1
	text = String(completed)

