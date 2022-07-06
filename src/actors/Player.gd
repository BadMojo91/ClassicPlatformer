extends Actor

signal is_dead

var is_falling = false
var last_velocity = Vector2.ZERO
var bounce_velocity = Vector2.ZERO
var bounce = false
var jump_active = false
var release_jump =  false
var compressed = false
var compression_value = 0.0

func _ready() -> void:
	anim_sprite.play("idle") #idle on spawn
	SignalBus.player_deaths = 0
	SignalBus.connect("respawn", self, "_respawn")
	connect("is_dead", self, "dead")


	
func _physics_process(delta: float) -> void:
	
	#if dead and not moving dont update physics
	if dead and velocity == Vector2.ZERO: 
		return
	
	#jump input
	jump_active = true if Input.is_action_pressed("jump") and is_on_floor() and !dead else false
	release_jump = Input.is_action_just_released("jump")
	
	if release_jump:
		compressed = false
		jump_active = false
		if !dead: anim_sprite.play("idle")
		
	var direction: = get_direction()
	
	#add compression or jump force
	if jump_active and !compressed:
		compression_value += delta * 5
		compression_value = clamp(compression_value,0.0,1.0)
		anim_sprite.play("jump")

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
		new_velocity.y = (compression_value * jump_force) * direction.y + (velocity.x * 0.2) #force + dir + run and jump boost 
		compression_value = 0.0 #reset compression
	
	#slow active momentum if compressing
	if jump_active:	
		new_velocity.x -= clamp(linear_velocity.x * 3, 0, max_speed.x)
		
	#smooth movement
	new_velocity.x = lerp(linear_velocity.x, new_velocity.x, get_physics_process_delta_time())
	
	#apply bounce
	if check_bounce():
		new_velocity += bounce_velocity
	
	#bounce off other surfaces
	#if is_on_wall() or is_on_ceiling():
	#	new_velocity -= last_velocity * elasticity
	
	#remember last velocity, used to detect how hard the player collided
	last_velocity = velocity
	
	return new_velocity

#bounce off surfaces
func check_bounce() -> bool:
	
	#dont do bounce
	if dead or compressed or jump_active or Input.is_action_pressed("move_down"):
		return false
	
	#do bounce
	if velocity == Vector2.ZERO and last_velocity != Vector2.ZERO and (is_on_floor() or is_on_wall() or is_on_ceiling()):
		var v = -last_velocity
		var e = elasticity
		bounce_velocity = Vector2(
							v.x * e,
							v.y * e + fmod((e * 100), .2))
		
		#play bounce animation
		if bounce_velocity.y < -50.0:
			anim_sprite.play("bounce_hard")
		elif bounce_velocity.y < -10:
			anim_sprite.play("bounce_soft")
		
		return true
	else:
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
	dead = false
	compressed = false
	SignalBus.emit_signal("update_player_death_state", dead)
	
