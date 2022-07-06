extends Area2D

onready var sprite : = $AnimatedSprite

func _on_SpikeTrap_body_entered(body: Actor) -> void:
	sprite.play("Trigger")
	var origin = transform.get_origin()
	body._set_position(origin - Vector2(0,8), true)

func _on_AnimatedSprite_animation_finished() -> void:
	SignalBus.emit_signal("kill")
	SignalBus.emit_signal("set_position", transform.get_origin())
	sprite.stop()
