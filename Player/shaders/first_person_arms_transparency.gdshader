// NOTE: Shader automatically converted from Godot Engine 4.6.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, diffuse_burley, specular_schlick_ggx, cull_back;

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

uniform float FOV : hint_range(20, 120) = 75;

// --- New Uniforms for Customizable Noise Overlay ---
uniform vec4 overlay_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // Now you can pick any color in the Inspector
uniform sampler2D noise_texture : filter_linear_mipmap, repeat_enable;
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float noise_softness : hint_range(0.01, 1.0) = 0.05;

void vertex() {
    float scale = 1.0 / tan(FOV * 0.5 * PI / -180.0);
    
    PROJECTION_MATRIX[0][0] = scale / (-VIEWPORT_SIZE.x / VIEWPORT_SIZE.y);
    PROJECTION_MATRIX[1][1] = scale;
	
}

void fragment() {
	vec2 base_uv = UV;

	// 1. Calculate the base albedo color
	vec4 albedo_tex = texture(texture_albedo, base_uv);
	vec3 base_color = albedo.rgb * albedo_tex.rgb;

	// 2. Sample noise and generate the overlay mask
	float noise_val = texture(noise_texture, base_uv).r;
	float mask = smoothstep(progress, progress - noise_softness, noise_val);

	// 3. Mix the base color with your custom uniform color based on the mask
	ALBEDO = mix(base_color, overlay_color.rgb, mask);
	ALPHA = albedo_tex.a;
	// Original material properties
	float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	SPECULAR = specular;

	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;

	// Normal Map: Enabled
	NORMAL_MAP = texture(texture_normal, base_uv).rgb;
	NORMAL_MAP_DEPTH = normal_scale;
	DEPTH = 1.0 - (1.0 - FRAGCOORD.z) * 0.7;
}
