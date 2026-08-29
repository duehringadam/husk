shader_type canvas_item;

uniform sampler2D noise_texture : repeat_enable;
uniform float mask_threshold : hint_range(0.0, 1.0) = 0.5;
uniform float feather : hint_range(0.0, 1.0) = 0.05;
uniform vec2 speed = vec2(0.0, 0.0);
uniform vec2 noise_offset = vec2(0.0,0.0);
// Border configuration (0.0 means no border effect, 0.5 means fully affected)
uniform float border_thickness : hint_range(0.0, 0.5) = 0.1;
uniform float border_feather : hint_range(0.0, 0.5) = 0.02;

varying vec2 global_position;

void vertex(){
	global_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    // 1. Get the original UI texture and color data
    vec4 tex_color = texture(TEXTURE, UV);
    
    // 2. Sample the noise texture
    vec2 moving_uv = UV + (TIME * speed) + noise_offset + (global_position * 0.005);
    vec4 noise = texture(noise_texture, moving_uv);
    
    // 3. Calculate distance to the closest edge (UVs range from 0.0 to 1.0)
    vec2 edge_dist = min(UV, vec2(1.0) - UV);
    float closest_edge = min(edge_dist.x, edge_dist.y);
    
    // 4. Create a border factor (1.0 at the center, 0.0 exactly at the outer edge)
    float border_factor = smoothstep(border_thickness - border_feather, border_thickness, closest_edge);
    
    // 5. Generate the noise mask
    float noise_mask = smoothstep(mask_threshold, mask_threshold + feather, noise.r);
    
    // 6. Only apply the noise mask where the border_factor says to (closer to edges)
    // If border_factor is 1 (center), final_mask is 1. If 0 (outer border), it takes the noise value.
    float final_mask = mix(noise_mask, 1.0, border_factor);
    
    // 7. Apply the final alpha mask and preserve Godot's built-in colors
    tex_color.a *= final_mask;
    COLOR = tex_color * COLOR;
}
