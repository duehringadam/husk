extends Node3D

@export var noise: NoiseTexture3D
var time_passed :float = 0.0
@onready var light: OmniLight3D = $GPUParticles3D/OmniLight3D


func _process(delta: float) -> void:
	time_passed += delta
	
	var sample = noise.noise.get_noise_1d(time_passed)
	sample = abs(sample)
	
	light.light_energy = clampf(sample, .15, 1.5)
