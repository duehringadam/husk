shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform float FOV : hint_range(20, 120) = 75;

void vertex() {
    float scale = 1.0 / tan(FOV * 0.5 * PI / -180.0);
    
    PROJECTION_MATRIX[0][0] = scale / (-VIEWPORT_SIZE.x / VIEWPORT_SIZE.y);
    PROJECTION_MATRIX[1][1] = scale;
}

void fragment() {
    // For reverse Z, we need to invert the depth scaling
    // If you want to scale to 70%, you'd do 1.0 - (1.0 - FRAGCOORD.z) * 0.7
    // This maintains the same relative scaling but works with reverse Z
    DEPTH = 1.0 - (1.0 - FRAGCOORD.z) * 0.7;
}