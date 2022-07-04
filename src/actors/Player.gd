extends Actor

signal player_stats_changed

onready var anim_sprite = $AnimatedSprite
var is_falling = false
var last_velocity = Vector2.ZERO
var bounce_velocity = Vector2.ZERO
var bounce = false
var has_jump_started = false
var release_jump =  false
var compressed = false
var compression_value = 0.0
var death_count = 0

func _ready() -> void:
	emit_signal("player_stats_changed", self, 0)
	anim_sprite.play("idle")

func die() -> void:
	if !dead:
		dead = true
		anim_sprite.play("death")
		death_count += 1
		emit_signal("player_stats_changed", self, death_count)
		

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		die()
	if Input.is_key_pressed(KEY_R):
		respawn()

func _physics_process(delta: float) -> void:
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.name == "WorldDmg":
			die()
		
	#bounce animation
	bounce = has_fallen()
	
	if Input.is_action_pressed("jump") and is_on_floor() and !dead:
		bounce = false
		has_jump_started = true

	
	if bounce:
		if bounce_velocity.y < -50.0:
			anim_sprite.play("bounce_hard")
		elif bounce_velocity.y < -10:
			anim_sprite.play("bounce_soft")
		
	#set falling state
	if velocity.y > 2.0:
		 is_falling = true
	else:
		is_falling = false
		
	
	
	release_jump = Input.is_action_just_released("jump")
	if release_jump and !dead:
		compressed = false
		has_jump_started = false
		anim_sprite.play("idle")
		

	var direction: = get_direction()
	
	if has_jump_started and !compressed:
		compression_value += delta * 5
		compression_value = clamp(compression_value,0.0,1.0)
		#print(compression_value)
		anim_sprite.play("jump")

	velocity = calculate_move_velocity(velocity, direction, max_speed, jump_force)
	velocity = move_and_slide(velocity, FLOOR_NORMAL)
	
	
func get_direction() -> Vector2:
	if !dead:
		return  Vector2(
			0.0 if has_jump_started else (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")),
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
	var new_velocity: = linear_velocity
	
	new_velocity.x = speed.x * direction.x
	new_velocity.y += gravity * get_physics_process_delta_time()
	if direction.y == -1.0:
		new_velocity.y = (compression_value * jump_force) * direction.y + (velocity.x * 0.2) #force + dir + run and jump boost 
		compression_value = 0.0
	
	if !has_jump_started:	
		new_velocity.x = lerp(linear_velocity.x, new_velocity.x, get_physics_process_delta_time())
	
	if bounce:
		new_velocity.y += bounce_velocity.y
		#print(new_velocity)
	
	if is_on_wall() or is_on_ceiling():
		new_velocity -= last_velocity * elasticity
		
	last_velocity = velocity
	
	return new_velocity

func has_fallen() -> bool:
	if compressed or dead:
		return false
	
	if velocity.y == 0.0 and is_falling:
		bounce_velocity = -last_velocity * 0.8
		return true
	elif velocity.y > 0.0:
		last_velocity.y = velocity.y
		return false
	else:
		return false


func _on_AnimatedSprite_animation_finished() -> void:
	
	if dead:
		anim_sprite.play("dead")
		return 
	
	if (has_jump_started and !compressed) or compressed:
		anim_sprite.play("compressed")
		compressed = true
	else:
		anim_sprite.play("idle")
		
