shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform sampler2D Albedo: filter_nearest_mipmap_anisotropic;
uniform sampler2D BlendTexture: filter_nearest_mipmap_anisotropic;
uniform vec4 BlendColor : source_color = vec4(0.9, 0.0, 0.0, 1.0);

uniform float blend_offset : hint_range(-10.0, 10.0, 0.05) = 0.0;
uniform float blend_smoothness : hint_range(0.01, 5.0, 0.05) = 0.5;

varying float local_y;

void vertex() {
	local_y = VERTEX.y;
}

void fragment() {
	// Sample base and blend textures
	vec4 _albedo = texture(Albedo, UV);
	vec4 _blend_texture = texture(BlendTexture, UV);
	
	// Apply uniform color and its alpha to the blend texture
	vec3 blend_rgb = _blend_texture.rgb * BlendColor.rgb;
	float blend_alpha = _blend_texture.a * BlendColor.a;

	// Calculate the vertical height mask
	float vertical_mask = smoothstep(blend_offset - blend_smoothness, blend_offset + blend_smoothness, local_y);

	// The effective transparency of the blend texture depends on both its own alpha and the height slider
	float final_blend_factor = blend_alpha * vertical_mask;

	// Overlay the blend color on top of the base color using standard alpha blending math
	vec3 final_color = mix(_albedo.rgb, blend_rgb, final_blend_factor);

	// The overall opacity of the model is determined by the base texture, 
	// ensuring any parts missing from the blend texture still show the base albedo.
	ALBEDO = final_color;
	ALPHA = _albedo.a; 
}
