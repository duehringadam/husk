extends LookAtModifier3D


func _ready() -> void:
	get_tree().create_timer(1).timeout.connect(func(): target_node = Global.player.head.get_path())
	
