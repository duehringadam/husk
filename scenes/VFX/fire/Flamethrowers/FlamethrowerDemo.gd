
# this demo script has no purpose other than showing turning flaemthrowers,
# sapwning of effects like impacts.. it is suedful reference for
# using raycast nodes for detecting flaemthrower hit...
# raycast size decreases when flamethrower is turning fast, to account for
# particles lag.

@tool
extends Node3D

@export var animate_flamethrowers: bool = true
@export var sweep_speed: float = 1.0
@export var sweep_angle_deg: float = 90.0
@export var raycast_lag_speed: float = 5.0
@export var burn_fade_in_speed: float = 2.0
@export var burn_fade_out_speed: float = 0.5

const RAYCAST_MAX_LENGTH = 6.8
const RAYCAST_MIN_LENGTH = 3.2

const FT_POSITIONS = [
	Vector3(0.0, 0.0, -0.031),
	Vector3(1.822, 0.0, -0.031),
	Vector3(3.64, 0.0, -0.031),
	Vector3(5.46, 0.0, -0.031),
	Vector3(7.28, 0.0, -0.031)
]

const IMP_POSITIONS = [
	Vector3(0.0, 0.0, -4.4),
	Vector3(1.822, 0.0, -4.4),
	Vector3(3.64, 0.0, -4.4),
	Vector3(5.46, 0.0, -4.4),
	Vector3(7.28, 0.0, -4.4)
]

var cubes = []
var flamethrowers = []
var impacts = []
var overlays = []
var raycasts = []
var time_passed = 0.0
var prev_angle = 0.0

func _ready():
	_setup_nodes()

func _setup_nodes():
	cubes.clear()
	flamethrowers.clear()
	impacts.clear()
	overlays.clear()
	raycasts.clear()
	
	var ft_names = ["FlameThrow", "FlameThrow2", "FlameThrow3", "FlameThrow4", "FlameThrow5"]
	var imp_names = ["FlamethrowImpact", "FlamethrowImpact2", "FlamethrowImpact3", "FlamethrowImpact4", "FlamethrowImpact5"]
	var cube_names = ["Surface/Cube", "Surface/Cube2", "Surface/Cube3", "Surface/Cube4", "Surface/Cube5"]
	
	for i in range(5):
		if not has_node(ft_names[i]) or not has_node(imp_names[i]) or not has_node(cube_names[i]):
			continue
			
		var ft = get_node(ft_names[i])
		var imp = get_node(imp_names[i])
		var cb = get_node(cube_names[i])
		
		# first apply the hardcoded default transform to prevent problems due to @tool nature of script
		ft.transform = Transform3D(Basis(), FT_POSITIONS[i])
		imp.transform = Transform3D(Basis(), IMP_POSITIONS[i])
		
		flamethrowers.append(ft)
		impacts.append(imp)
		cubes.append(cb)
		
		# keep track of overlay_materials used for burning surface
		var mat = cb.material_overlay
		overlays.append(mat)
		if mat:
			mat.set("shader_parameter/burn_coverage", 0.0)
		
		# initial state
		_set_impact_emitting(imp, false)
		
		# raycasts for hit detection
		var ray = ft.get_node_or_null("HitDetectRaycast")
		if ray:
			raycasts.append(ray)

func _exit_tree():
	_reset_all()

func _reset_all():
	for i in range(flamethrowers.size()):
		if is_instance_valid(flamethrowers[i]):
			flamethrowers[i].transform = Transform3D(Basis(), FT_POSITIONS[i])
		if is_instance_valid(impacts[i]):
			impacts[i].transform = Transform3D(Basis(), IMP_POSITIONS[i])
			_set_impact_emitting(impacts[i], true)
		if is_instance_valid(overlays[i]):
			overlays[i].set("shader_parameter/burn_coverage", 0.0)

func _physics_process(delta: float) -> void:
	if not animate_flamethrowers:
		if time_passed > 0.0:
			_reset_all()
			time_passed = 0.0
			prev_angle = 0.0
		return
		
	if flamethrowers.is_empty() or raycasts.is_empty() or not is_instance_valid(raycasts.front()):
		_setup_nodes()
		if flamethrowers.is_empty() or raycasts.is_empty():
			return
			
	time_passed += delta
	var sweep_t = (-cos(time_passed * sweep_speed) + 1.0) / 2.0
	var current_angle = lerp(0.0, deg_to_rad(sweep_angle_deg), sweep_t)
	var turn_speed = 0.0
	if delta > 0.0:
		turn_speed = abs(current_angle - prev_angle) / delta
	var max_turn_speed = max((deg_to_rad(sweep_angle_deg) * sweep_speed) * 0.5, 0.0001)
	var turn_ratio = clamp(turn_speed / max_turn_speed, 0.0, 1.0)
	var dynamic_raycast_length = lerp(RAYCAST_MAX_LENGTH, RAYCAST_MIN_LENGTH, turn_ratio)
	prev_angle = current_angle
	
	var is_getting_hit = []
	for i in range(cubes.size()):
		is_getting_hit.append(false)
	
	for i in range(flamethrowers.size()):
		var ft = flamethrowers[i]
		var imp = impacts[i]
		var ray = raycasts[i]
		
		var init_trans = Transform3D(Basis(), FT_POSITIONS[i])
		# rotating flamethrowers on y axis
		ft.transform = init_trans.rotated_local(Vector3.UP, current_angle)
		ray.target_position = Vector3(0.0, 0.0, -dynamic_raycast_length)
		
		# simualting particle lag on raycast (important when flamethrower is turning)
		ray.global_transform = ray.global_transform.interpolate_with(ft.global_transform, delta * raycast_lag_speed)
		
		# force physics update manually for @tool context
		ray.force_raycast_update()
		
		if ray.is_colliding():
			imp.global_position = ray.get_collision_point()
			_set_impact_emitting(imp, true)
			
			var hit_col = ray.get_collider()
			if hit_col:
				# hit_col is the StaticBody3D, its parent is the Cube
				var cb_node = hit_col.get_parent()
				var hit_idx = cubes.find(cb_node)
				if hit_idx != -1:
					is_getting_hit[hit_idx] = true
		else:
			# if raycast not hitting,, deactivate effects
			_set_impact_emitting(imp, false)
			
	# burn animations
	for i in range(cubes.size()):
		if not is_instance_valid(overlays[i]):
			continue
			
		var current_cov = overlays[i].get("shader_parameter/burn_coverage")
		if current_cov == null: current_cov = 0.0
		var cov = float(current_cov)
		
		if is_getting_hit[i]:
			cov += delta * burn_fade_in_speed
		else:
			cov -= delta * burn_fade_out_speed
			
		cov = clamp(cov, 0.0, 1.0)
		overlays[i].set("shader_parameter/burn_coverage", cov)

func _set_impact_emitting(impact_node: Node3D, emitting: bool):
	for child in impact_node.get_children():
		if child is GPUParticles3D:
			if child.emitting != emitting:
				child.emitting = emitting
