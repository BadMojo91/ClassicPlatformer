extends KinematicBody2D
class_name Actor

const FLOOR_NORMAL: = Vector2.UP

export var gravity: = 4000.0
export var max_speed: = Vector2(50.0,1000.0)
export var jump_force: = 150.0
export var elasticity = 0.8
var dead = false
var velocity: = Vector2.ZERO
var spawn_location: = Vector2.ZERO

func _ready() -> void:
	spawn_location = get_transform().get_origin()
	
func respawn() -> void:
	#get_tree().reload_current_scene()
	transform.origin = spawn_location
	dead = false



