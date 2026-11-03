class_name status_effect
extends Resource

@export_category("Damage")
@export var effect_type: Global.STATUS_TYPE
@export var damage_component_scene: PackedScene
@export var duration: float

@export_category("Overlay Effect")
@export var ember_core: Color
@export var ember_mid: Color
@export var ember_edge: Color
@export var char_color: Color

@export_range(0.0,1.0) var progress: float = 0.5
@export_range(1.0, 50.0) var wave_density: float = 15.0
@export_range(0.1, 10.0) var wave_speed: float = 3.0
@export_range(0.0, 1.0) var wave_amplitude: float = 0.35

@export_range(0.0, 30.0) var ember_brightness: float = 8
@export_range(0.01, 12.0) var noise_scale: float = 1.0;
@export_range(0.01, 1.0) var edge_sharpness : float = 0.22;
@export_range(0.0, 1.0) var char_opacity :float = 0.85;
@export_range(0.0, 2.0) var turbulence: float = 1
@export_range(1.0, 15.0) var flicker_speed: float = 8.5

@export_range(0.0, 5.0) var time_scale_noise_slow: float = 1.0;
@export_range(0.0, 5.0) var time_scale_noise_fast: float = 1.0;
@export_range(0.0, 5.0) var time_scale_turbulence: float = 1.0;
@export_range(0.0, 5.0) var time_scale_flicker : float = 1.0;
