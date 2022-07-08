extends Actor

signal is_dead

onready var ray = $RayCast2D

var is_falling = false
var last_velocity
var bounce_velocity = Vector2.ZERO
var bounce = false
var jump_active = false
var boost_active = false
var boost_just_pressed = false
var release_jump =  false
var compressed = false
var compression_value = 0.0
var boost_count = 0

var is_on_slope = false
var is_up_slope =  false

func _ready() -> void:
	anim_sprite.play("idle") #idle on spawn
	SignalBus.player_deaths = 0
	SignalBus.connect("respawn", self, "_respawn")
	connect("is_dead", self, "dead")

	 
func _process(delta: float) -> void:
	if(!dead && !jump_active && !compressed && abs(velocity.x) > 0.5):
		anim_sprite.play("Walk")
		anim_sprite.speed_scale = abs(velocity.x) * 0.05
		anim_sprite.flip_h = true if velocity.x < 0.0 else false
		
#	elif bounce:
#		#play bounce animation
#		if bounce_velocity.y < -50.0:
#			anim_sprite.play("bounce_hard")
#		elif bounce_velocity.y < -10:
#			anim_sprite.play("bounce_soft")
				
func _physics_process(delta: float) -> void:
	
	#if dead and not moving dont update physics
	if dead and velocity == Vector2.ZERO: 
		return
	
	#if velocity.y == 0.000:
	#	boost_count = 0
	
		#jump input
	jump_active = true if Input.is_action_pressed("jump") and is_on_floor() and !dead else false
	boost_active = true if Input.is_action_pressed("move_up") and is_on_floor() and !dead else false
	boost_just_pressed = true if Input.is_action_just_pressed("jump") and !is_on_floor() else false
	release_jump = Input.is_action_just_released("jump")
	
	var direction: = get_direction()
		
	
	#add compression or jump force
	if jump_active and !compressed:
		boost_count = 1
		anim_sprite.play("jump")
		anim_sprite.speed_scale = 1.0
	
	if release_jump:
		compressed = false
		jump_active = false
		if !dead: anim_sprite.play("idle")

	velocity = calculate_move_velocity(velocity, direction, max_speed, jump_force)
	velocity = move_and_slide(velocity, FLOOR_NORMAL)
	
	
		
func get_direction() -> Vector2:
	if !dead:
		return  Vector2(
			0.0 if jump_active else (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")),
			-1.0 if release_jump and is_on_floor() else 1.0
		)
	else:
		return Vector2.ZERO

func calculate_move_velocity(
	linear_velocity: Vector2,
	direction: Vector2,
	speed: Vector2,
	jump_force: float
	) -> Vector2:
		
	
	#get current velocity		
	var new_velocity: = linear_velocity
	
	#horizontal movement
	new_velocity.x = speed.x * direction.x
	
	#apply gravity
	new_velocity.y += gravity * get_physics_process_delta_time()
	
	#jump
	if direction.y == -1.0:
		var j_force = jump_force + (boost if boost_active else 0.0)
		new_velocity.y = (compression_value * j_force) * direction.y + (velocity.x * 0.2) #force + dir + run and jump boost 
		compression_value = 0.0 #reset compression
	
	#slow active momentum if compressing
	if jump_active:	
		new_velocity.x -= clamp(linear_velocity.x * 3, 0, max_speed.x)

	#do a boost mid air
	if boost_just_pressed && boost_count > 0:
		new_velocity.y -= boost
		boost_count -= 1
			
	#smooth movement
	new_velocity.x = lerp(linear_velocity.x, new_velocity.x, get_physics_process_delta_time())
	
	#apply bounce
	bounce = check_bounce()
	if bounce : new_velocity += bounce_velocity
	
	if(check_is_on_slope(Vector2(direction.x,0.0)) && is_on_floor()):
		new_velocity.y -= tan(0.785398) * abs(direction.x * speed.x*0.1)
	
	
	#remember current velocity
	last_velocity = velocity
	
	return new_velocity

#bounce off surfaces
func check_bounce() -> bool:
	bounce_velocity = Vector2.ZERO
	#dont do bounce
	if dead or compressed or jump_active or Input.is_action_pressed("move_down"):
		return false
	
	#do bounce
	var v = -last_velocity
	var e = elasticity
	var b = false
	if  is_on_wall():
		bounce_velocity.x = v.x * e
		b = true
	if is_on_ceiling() or is_on_floor():
		bounce_velocity.y = v.y * e #+ (v.y * 0.02)
		b = true
		
	return b


func check_is_on_slope(dir: Vector2) -> bool:
	ray.set_cast_to(dir * 9.0)
	if(ray.get_collider() != null):
		var h_normal = ray.get_collision_normal().angle()
		print(h_normal)
		return true
	
	return false

		

func _on_AnimatedSprite_animation_finished() -> void:
	
	if dead:
		anim_sprite.play("dead")
	elif is_on_floor() and ((jump_active and !compressed) or compressed):
		anim_sprite.play("compressed")
		compressed = true
	else: #do default animation
		anim_sprite.play("idle")
		
func _respawn():
	velocity = Vector2.ZERO
	transform.origin = spawn_location
	dead = false
	compressed = false
	jump_active = false
	release_jump = false
	last_velocity = Vector2.ZERO
	SignalBus.emit_signal("update_player_death_state", dead)
	

func _on_AnimatedSprite_frame_changed() -> void:
	if (jump_active && !compressed):
		var frame_delta = float(anim_sprite.frame) / float(anim_sprite.frames.get_frame_count("jump"))
		compression_value = frame_delta
	
