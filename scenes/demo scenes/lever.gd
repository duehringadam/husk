extends Node3D

@export var is_missing_lever: bool = false
@export var lever_to_find: Pickable
@export var door_to_unlock: InteractableDoor

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var item_area: Area3D = %itemArea
@onready var lever_mesh: MeshInstance3D = %lever
@onready var lever_position: Node3D = %leverPosition
@onready var collision: CollisionShape3D = %CollisionShape3D

var lever_returned: bool = true

func _ready() -> void:
	if is_missing_lever:
		lever_returned = false
		lever_mesh.visible = false
		item_area.monitorable = true
		item_area.monitoring = true
		
func _on_interact_on_complete(controller: InteractionController) -> void:
	if animation_player.is_playing(): return
	
	if !lever_returned:
		ContextPopUp.set_popup_text("Nothing Happens...")
		ContextPopUp.activate()
		return
	elif lever_returned:
		animation_player.play("Take 001")
		await animation_player.animation_finished
		door_to_unlock.interact(controller)


func _on_item_area_body_entered(body: Node3D) -> void:
	if body is Pickable and body == lever_to_find:
		collision.disabled = true
		var mesh = body.throwable_mesh
		mesh.reparent(self, true)
		body.queue_free()
		var tween = get_tree().create_tween()
		tween.set_parallel()
		tween.tween_property(mesh, "global_position", lever_position.global_position,1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
		tween.tween_property(mesh, "global_rotation", lever_mesh.global_rotation,1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
		await tween.finished
		mesh.queue_free()
		collision.disabled = false
		lever_mesh.visible = true
		lever_returned = true
