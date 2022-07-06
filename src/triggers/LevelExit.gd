extends Area2D

export var default_scene: PackedScene
export var next_scene: PackedScene 

var player_dead : bool


func _ready() -> void:
	SignalBus.connect("update_player_death_state", self, "_player_dead")
	if next_scene == null:
		next_scene = load("res://levels/LevelTemplate.tscn")
		
func _player_dead(dead: bool):
	player_dead = dead

func _on_LevelExit_body_entered(body: Node) -> void:
	if(player_dead): return
	print("win")

	SignalBus.emit_signal("load_level", next_scene)
	
