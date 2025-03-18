extends Node3D

@onready var wind: AudioStreamPlayer3D = $wind
@onready var wind_2: AudioStreamPlayer3D = $wind2
@onready var crow: AudioStreamPlayer3D = $crow


func _ready() -> void:
	wind.play()
	wind_2.play()
	crow.play()
	
func _physics_process(delta: float) -> void:
	pass
