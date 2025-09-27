extends Node

@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"

func _on_lower_state_entered() -> void:
	animation_player.play("lower")


func _on_lower_state_exited() -> void:
	animation_player.play("lower",-1,-1,true)


func _on_lower_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.
