extends RichTextLabel

var current_score = 0

func _ready() -> void:
	SignalBus.connect("add_to_score", self, "_add_to_score")
	update_score()
	
func _add_to_score(score: int):
	current_score += score
	update_score()
	
func update_score():
	text = String(current_score)
