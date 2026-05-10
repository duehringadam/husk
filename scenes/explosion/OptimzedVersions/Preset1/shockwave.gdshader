shader_type spatial;
render_mode unshaded, cull_disabled, depth_test_disabled;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
uniform float wave_speed : hint_range(0.1, 50.0) = 50.0;
uniform float wave_amplitude : hint_range(0.0, 0.5) = 0.06;
uniform float elastic_frequency : hint_range(0.1, 100.0) = 25.0;
uniform float damping_time : hint_range(0.1, 10.0) = 4.0;
uniform float damping_spatial : hint_range(0.01, 1.0) = 0.1;
uniform float chromatic_aberration : hint_range(0.0, 5.0) = 1.0;

uniform float progress = 0.0;


void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	vec4 world = INV_VIEW_MATRIX * vec4(view.xyz, 1.0);
	vec3 bg_world_pos = world.xyz;

	vec3 center = NODE_POSITION_WORLD;
	float dist = distance(center, bg_world_pos);

	float arrival_time = dist / wave_speed;
	float active_time = progress - arrival_time;

	float ripple = 0.0;
	float envelope = 0.0;
	
	if (active_time > 0.0) {
		envelope = wave_amplitude * exp(-active_time * damping_time) * exp(-dist * damping_spatial);
		ripple = sin(active_time * elastic_frequency) * envelope;
	}

	vec4 center_proj = PROJECTION_MATRIX * VIEW_MATRIX * vec4(center, 1.0);
	vec2 screen_center = (center_proj.xy / center_proj.w) * 0.5 + 0.5;
	vec2 dir = normalize(SCREEN_UV - screen_center);

	if (length(SCREEN_UV - screen_center) < 0.001) {
		dir = vec2(0.0);
	}

	float r = texture(screen_texture, SCREEN_UV - dir * ripple * (1.0 + chromatic_aberration * 0.1)).r;
	float g = texture(screen_texture, SCREEN_UV - dir * ripple).g;
	float b = texture(screen_texture, SCREEN_UV - dir * ripple * (1.0 - chromatic_aberration * 0.1)).b;

	ALBEDO = vec3(r, g, b);
	ALPHA = clamp(envelope * 1000.0, 0.0, 1.0);
}
