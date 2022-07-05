extends Node


func _on_HurtTrigger_body_entered(body: Node) -> void:
	SignalBus.emit_signal("kill")
