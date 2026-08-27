shader_type spatial;

render_mode depth_prepass_alpha;
render_mode diffuse_toon;
render_mode specular_toon;

uniform sampler2D noise : repeat_enable, filter_linear_mipmap_anisotropic; // cutout & shading texture
uniform float noise_shading : hint_range(0.0, 1.0) = 1.0;
uniform float progress : hint_range(0.0, 1.0) = 0.0;

// 1. Replaced vec4 color with a gradient sampler
uniform sampler2D blood_gradient : hint_default_black, source_color; 

void fragment() {
	vec4 noise_texture = texture(noise, UV);
	
	vec4 gradient_color = texture(blood_gradient, UV);

	ALBEDO = gradient_color.rgb * mix(vec3(1.0), noise_texture.rgb, noise_shading);
	ALPHA = gradient_color.a * step(noise_texture.r, progress);
}
