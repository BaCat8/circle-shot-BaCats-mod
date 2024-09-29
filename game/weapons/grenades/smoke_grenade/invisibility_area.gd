extends Area2D


func _ready() -> void:
	if not multiplayer.is_server():
		process_mode = PROCESS_MODE_DISABLED


func _on_body_entered(body: Node2D) -> void:
	var entity := body as Entity
	if entity:
		entity.add_timeless_effect.rpc(Effect.INVISIBILITY)


func _on_body_exited(body: Node2D) -> void:
	var entity := body as Entity
	if entity:
		entity.remove_timeless_effect.rpc(Effect.INVISIBILITY)
