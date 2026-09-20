extends StaticBody3D

signal lock_broken
@onready var padlock_rigid_body: RigidBody3D = $padlockRigidBody
@onready var break_sfx: AudioStreamPlayer3D = $padlockRigidBody/break
@onready var spark: GPUParticles3D = $padlockRigidBody/spark
@onready var spark_light: OmniLight3D = $padlockRigidBody/spark_light


func _on_open_on_complete(controller: InteractionController) -> void:
	ContextPopUp.set_popup_text("Locked...")
	ContextPopUp.activate()

func _on_health_component_died() -> void:
	lock_broken.emit()
	spark.emitting =true
	break_sfx.play()
	var tween = get_tree().create_tween()
	tween.tween_property(spark_light, "light_energy", 0,.1)
	padlock_rigid_body.reparent(get_tree().current_scene)
	padlock_rigid_body.visible = true
	padlock_rigid_body.freeze = false
	get_tree().create_timer(25).timeout.connect(func(): padlock_rigid_body.queue_free())
	self.queue_free()
