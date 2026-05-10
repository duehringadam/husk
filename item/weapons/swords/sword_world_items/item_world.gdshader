shader_type spatial;
render_mode unshaded;

uniform sampler2D main_texture:source_color;

void fragment() {
	ivec2 screen_pixel = ivec2(SCREEN_UV * VIEWPORT_SIZE);
	// get node position in clip space
	vec4 clip_pos = PROJECTION_MATRIX * vec4(NODE_POSITION_VIEW, 1.0);
	// position of node relative to screen uv
	vec2 node_uv = clip_pos.xy / clip_pos.w * 0.5 + vec2(0.5, 0.5);
	// offset screen pixel so centre of node matches centre of main_texture
	ivec2 offset = textureSize(main_texture, 0) / 2 - ivec2(node_uv * VIEWPORT_SIZE);
	ALBEDO = texelFetch(main_texture, screen_pixel + offset, 0).rgb;
}