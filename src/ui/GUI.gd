extends CanvasLayer


var death_counter: = get_child(1)

func _on_Player_player_stats_changed(extra_arg_0: int) -> void:
	death_counter.text = extra_arg_0
	print(extra_arg_0)
