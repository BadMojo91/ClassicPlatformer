extends KinematicBody2D
class_name Actor

const FLOOR_NORMAL: = Vector2.UP

export var gravity: = 4000.0
export var max_speed: = Vector2(50.0,1000.0)
export var jump_force: = 150.0
export var elasticity = 0.8

var death_count = 0
var dead = false
var velocity: = Vector2.ZERO
var spawn_location: = Vector2.ZERO
onready var anim_sprite = $AnimatedSprite

func _ready() -> void:
	spawn_location = get_transform().get_origin()
	SignalBus.connect("kill",self,"die")
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("kill"):
		die()
	if Input.is_action_just_pressed("respawn"):
		SignalBus.emit_signal("respawn")
		

func die() -> void:
	if !dead: 
		dead = true
		death_count += 1
		SignalBus.emit_signal("update_death_count", death_count)
		anim_sprite.play("death")
		print("dead")

func _respawn():
	dead = false




