extends Node

@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"

func _on_idle_state_entered() -> void:
	pass # Replace with function body.


func _on_idle_state_exited() -> void:
	pass # Replace with function body.


func _on_idle_state_physics_processing(delta: float) -> void:
	if Input.is_action_just_pressed("attack_secondary"):
		animation_player.play("spray_poison")
