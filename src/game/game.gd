extends Node

export var first_level: PackedScene
export var player: PackedScene
var current_level: Node
var current_player: KinematicBody2D
var spawn_location: Vector2
var root: Node

func _ready() -> void:
	SignalBus.connect("respawn", self, "_respawn")
	SignalBus.connect("load_level", self, "_load_level")
	SignalBus.emit_signal("load_level", first_level)
	
func _load_level(level: PackedScene):
	#unload current level
	if current_level != null:
		unload_level()
	
	#check if level exists
	if !check_for_errors({0: 0, 1: level}): return
	
	#add level to root 
	var root = get_tree().current_scene
	print("loading " + level.resource_name)
	current_level = level.instance()
	self.add_child(current_level)
	
	spawn_player()
	var level_name = current_level.name
	print(level_name + " has loaded") 
	SignalBus.emit_signal("update_level_name", level_name)
	return
	
func unload_level() -> void:
	current_level.queue_free()
	
		 
# check_for_errors(index, object)
# index:
# 0: current level
# 1: spawn
# 2: player
func check_for_errors(args={}) -> bool:
	var index = (-1 if typeof(args[0]) != TYPE_INT else args[0])
	var obj = args[1]
	match (index):
		-1:
			print("args error")
			return false
		0:
			if obj == null:
				print("level not set")
				return  false
		1:
			if obj == null:
				print("no spawn point")
				return false
		2:
			if obj == null:
				print("player not set")
				return false
		_:
			print("error: index out of range")
			return false
			
	return true

func spawn_player() -> bool:
	
	#check if player can be initialized
	if !check_for_errors({0: 2, 1: player}): return false 
	
	#find spawn point
	var spawn = current_level.find_node("PlayerSpawn")
	if !check_for_errors({0: 1, 1: spawn}): return false #check if spawn is not null
	spawn_location = spawn.global_position
	
	#create instance of player if there isnt one
	if current_player == null:
		print("spawning player")
		current_player = player.instance()
		add_child(current_player)
		
	#set player origin	
	SignalBus.emit_signal("set_spawn", spawn_location)
	SignalBus.emit_signal("respawn")
	
	return true
	
#func _respawn():
#	current_player.transform.origin = spawn_location
