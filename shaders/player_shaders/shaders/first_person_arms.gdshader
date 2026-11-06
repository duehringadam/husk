shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled;

global uniform vec4 overlay_color;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_nearest_mipmap_anisotropic, repeat_enable;
uniform ivec2 albedo_texture_size;
uniform float point_size : hint_range(0.1, 128.0, 0.1);

uniform float roughness : hint_range(0.0, 1.0);
uniform sampler2D texture_metallic : hint_default_white, filter_nearest_mipmap_anisotropic, repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r, filter_nearest_mipmap_anisotropic, repeat_enable;

uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float metallic : hint_range(0.0, 1.0, 0.01);

uniform sampler2D texture_normal : hint_roughness_normal, filter_nearest_mipmap_anisotropic, repeat_enable;
uniform float normal_scale : hint_range(-16.0, 16.0) = 1.0;

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

global uniform float FOV : hint_range(20, 120) = 75;

uniform sampler2D BlendTexture : filter_nearest_mipmap_anisotropic, repeat_enable;
global uniform vec4 BlendColor : source_color = vec4(0.9, 0.0, 0.0, 1.0);

// --- Blend UV Adjustments (Repeating & Offsets) ---
uniform vec2 blend_uv_scale = vec2(1.0, 1.0);
uniform vec2 blend_uv_offset = vec2(0.0, 0.0);

// --- Blend Normal Map Uniforms ---
uniform sampler2D BlendNormal : hint_roughness_normal, filter_nearest_mipmap_anisotropic, repeat_enable;
uniform float blend_normal_scale : hint_range(-16.0, 16.0) = 1.0;

// --- New Blend Roughness Uniform ---
uniform float blend_roughness : hint_range(0.0, 1.0) = 0.5;

// --- Vertical Blend Controls ---
uniform float blend_offset : hint_range(-1.5, 1.0, 0.05) = -0.5;
uniform float blend_smoothness : hint_range(0.01, 5.0, 0.05) = 0.5;
uniform bool invert_blend_direction = false;

// Changed to a vec2 to pass both the local Y and the scale factor
varying vec2 local_y_and_scale;

void vertex() {
	// Extract the absolute Y-scale factor from the model's transformation matrix
	float y_scale = length(MODEL_MATRIX[1].xyz);
	local_y_and_scale = vec2(VERTEX.y, y_scale);

	// Custom camera projection calculation
	float scale = 1.0 / tan(FOV * 0.5 * PI / -180.0);
	PROJECTION_MATRIX[0][0] = scale / (-VIEWPORT_SIZE.x / VIEWPORT_SIZE.y);
	PROJECTION_MATRIX[1][1] = scale;
}

void fragment() {
	vec2 base_uv = UV;
	
	// Apply scaling and offsets to the blend UV space
	vec2 blend_uv = (UV * blend_uv_scale) + blend_uv_offset;

	// 1. Calculate the base albedo color
	vec3 base_color = albedo.rgb * texture(texture_albedo, base_uv).rgb;

	// 2. Sample and prepare the custom Blend Texture
	vec4 blend_tex = texture(BlendTexture, blend_uv);
	vec3 blend_rgb = blend_tex.rgb * BlendColor.rgb;
	float blend_alpha = blend_tex.a * BlendColor.a;

	// --- FIX HERE: Divide local_y by the extracted y_scale ---
	float normalized_y = local_y_and_scale.x / local_y_and_scale.y;

	// 3. Calculate the vertical height mask using the normalized coordinate
	float vertical_mask = smoothstep(blend_offset - blend_smoothness, blend_offset + blend_smoothness, normalized_y);

	// 4. Handle direction inversion if selected
	if (invert_blend_direction) {
		vertical_mask = 1.0 - vertical_mask;
	}

	// 5. Compute final overlay factor
	float final_overlay_weight = blend_alpha * vertical_mask;

	// 6. Layer the blend texture color over the base color
	ALBEDO = mix(base_color, blend_rgb, final_overlay_weight);

	// Original material properties
	float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	SPECULAR = specular;

	// 7. Calculate and Mix Roughness Channel
	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float base_roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	float final_base_roughness = base_roughness_tex * roughness;
	
	// Blend the calculated base roughness with the new custom blend value
	ROUGHNESS = mix(final_base_roughness, blend_roughness, final_overlay_weight);

	// 8. Process and Mix the Normal Maps
	vec3 base_normal = texture(texture_normal, base_uv).rgb;
	vec3 blend_normal = texture(BlendNormal, blend_uv).rgb;
	
	NORMAL_MAP = mix(base_normal, blend_normal, final_overlay_weight);
	NORMAL_MAP_DEPTH = mix(normal_scale, blend_normal_scale, final_overlay_weight);

	DEPTH = 1.0 - (1.0 - FRAGCOORD.z) * 0.7;
}
