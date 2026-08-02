extends Node3D

@onready var static_body: StaticBody3D =  %StaticBody3D
@onready var metal: AudioStreamPlayer3D = $spikes/Plane_002/metal
@onready var damage_component: SingleDamageComponent = $DamageComponent

func _on_damage_component_body_entered(body: Node3D) -> void:
	if body is PhysicalBone3D:
		var pin = PinJoint3D.new()
		self.add_child(pin)
		pin.global_position = body.global_position
		pin.node_b = body.get_path()
		body.linear_velocity = Vector3.ZERO


func _on_damage_component_damage_dealt(types: Dictionary, actual: float, stance_damage: float, target: hurtbox_component) -> void:
	metal.play()
