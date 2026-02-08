extends Node3D

@onready var static_body: StaticBody3D = $spike/Cube_001/StaticBody3D
@onready var metal: AudioStreamPlayer3D = $metal

func _on_damage_component_damage_dealt(types: Dictionary, actual: float, stance_damage: float, target: hurtbox_component) -> void:
	if target.get_parent() is PhysicalBone3D:
		var pin = PinJoint3D.new()
		self.add_child(pin)
		pin.global_position = target.global_position
		pin.node_b = target.get_parent().get_path()
		metal.play()
		target.get_parent().linear_velocity = Vector3.ZERO
