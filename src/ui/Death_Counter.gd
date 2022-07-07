extends RichTextLabel

var deaths = 0

func _ready():
	text = String(deaths)
	SignalBus.connect("update_death_count", self, "_update_death_count")

func _update_death_count(count: int):
	deaths = String(count)
	text = deaths
