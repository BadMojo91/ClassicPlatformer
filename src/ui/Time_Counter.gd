extends RichTextLabel
var start_time = 0
var current_time = 0

func _ready() -> void:
	start_time = OS.get_unix_time()
func _process(delta: float) -> void:
	current_time = OS.get_unix_time()
	var elapsed_time = current_time - start_time
	text = String(elapsed_time)

