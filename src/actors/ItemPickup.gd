tool
extends Area2D


export var score: int
export var sprite_frames: SpriteFrames
onready var anim = $AnimatedSprite

func _ready() -> void:
	if sprite_frames:
		anim.set_sprite_frames(sprite_frames)
	
func _on_ItemPickup_body_entered(body: Node) -> void:
	SignalBus.emit_signal("add_to_score", score)
	queue_free()
