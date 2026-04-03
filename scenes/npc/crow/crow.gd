extends Node3D

@onready var caw: AudioStreamPlayer3D = $caw
@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree

@export var target_flyaway_point: Node3D


func _ready() -> void:
	get_tree().create_timer(randf()).timeout.connect(func(): animation_tree.active = true)
	
func _on_timer_timeout() -> void:
	caw.play()
	caw.pitch_scale = randf_range(.8,1.2)
	timer.wait_time = randi_range(15,30)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		AudioManager.play_sound(load("res://sfx/freesound_community-075692_bird-flying-awaywav-86143.mp3"), self.global_position,0)
		animation_tree.set("parameters/conditions/scare", true)
		self.look_at(target_flyaway_point.global_position)
		var tween = get_tree().create_tween()
		tween.tween_property(self, "global_position", target_flyaway_point.global_position, 5).set_trans(Tween.TRANS_CUBIC)
		tween.tween_callback(func(): self.queue_free())
		
