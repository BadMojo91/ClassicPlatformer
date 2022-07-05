extends Area2D

export var next_scene: PackedScene 

func _on_LevelExit_body_entered(body: Node) -> void:
	print("win")
	SignalBus.emit_signal("load_level", next_scene)
	
