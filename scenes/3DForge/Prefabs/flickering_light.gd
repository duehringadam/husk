extends Node3D

@export var noise: NoiseTexture3D
var time_passed :float = 0.0
@export var light: OmniLight3D

func _ready() -> void:
	time_passed += randf()

func _process(delta: float) -> void:
	time_passed += delta
	
	
	var sample = noise.noise.get_noise_1d(time_passed)
	sample = abs(sample)
	
	light.light_energy = clampf(sample, .1, 1.5)
