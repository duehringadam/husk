shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform vec3 ember_core : source_color = vec3(1.0, 0.95, 0.4);
uniform vec3 ember_mid : source_color = vec3(1.0, 0.55, 0.1);
uniform vec3 ember_edge : source_color = vec3(1.0, 0.25, 0.0);
uniform vec3 char_color : source_color = vec3(0.12, 0.08, 0.05);

uniform float progress : hint_range(0.0, 1.0) = 0.65;

uniform float wave_density : hint_range(1.0, 50.0) = 15.0;
uniform float wave_speed : hint_range(0.1, 10.0) = 3.0;
uniform float wave_amplitude : hint_range(0.0, 1.0) = 0.35;

uniform float ember_brightness : hint_range(0.5, 30.0) = 18.0;
uniform float noise_scale : hint_range(0.01, 12.0) = 0.2;
uniform float edge_sharpness : hint_range(0.01, 1.0) = 0.22;
uniform float char_opacity : hint_range(0.0, 1.0) = 0.85;
uniform float turbulence : hint_range(0.0, 2.0) = 1.1;
uniform float flicker_speed : hint_range(1.0, 15.0) = 8.5;

uniform sampler3D noise_texture : repeat_enable, filter_nearest_mipmap_anisotropic;

float get_noise(sampler3D tex, vec3 pos) {
    return texture(tex, pos).r * 2.0 - 1.0;
}

void fragment() {
    vec3 pos = vec3(UV * noise_scale, 0.0);
    
    float n1 = get_noise(noise_texture, pos * 1.1);
    float n2 = get_noise(noise_texture, pos * 2.4 + vec3(TIME * 0.4, TIME * 0.35, 0.0));
    float n3 = get_noise(noise_texture, pos * 4.7 + vec3(TIME * 0.7, TIME * 0.6, TIME * 0.3));
    
    float combined = n1 * 0.5 + n2 * 0.35 + n3 * 0.15;
    
    float turb = get_noise(noise_texture, pos * 7.8 + vec3(TIME * 1.1, TIME * 0.9, TIME * 1.3)) * turbulence * 0.18;
    combined += turb;
    
    combined = (combined + 1.0) * 0.5;
    
    vec2 wave_uv = UV + (combined * 0.15);
    
    float w1 = sin((wave_uv.x + wave_uv.y) * wave_density - TIME * wave_speed);
    float w2 = sin((wave_uv.x - wave_uv.y) * wave_density + TIME * (wave_speed * 0.8));
    
    float wave_pattern = (w1 + w2) * 0.5;
    wave_pattern = pow((wave_pattern + 1.0) * 0.5, 2.0);
    
    float local_burn = clamp(progress + (wave_pattern * wave_amplitude) - (wave_amplitude * 0.5), 0.0, 1.0);

    float threshold = 1.0 - local_burn;
    float burn_front = smoothstep(threshold - 0.15, threshold + edge_sharpness, combined);
    
    float fire_t = clamp((combined - threshold) / (edge_sharpness + 0.1), 0.0, 1.0);
    vec3 fire_color = mix(ember_edge, ember_mid, smoothstep(0.0, 0.45, fire_t));
    fire_color = mix(fire_color, ember_core, smoothstep(0.35, 1.0, fire_t));
    
    vec3 final_color = mix(char_color, fire_color * 1.4, burn_front);
    
    EMISSION = fire_color * burn_front * ember_brightness;
    
    float flicker_noise = get_noise(noise_texture, vec3(UV * noise_scale * 5.2, TIME * flicker_speed * 0.08));
    float edge_flicker = smoothstep(0.0, 0.8, burn_front) * (0.6 + 0.4 * flicker_noise);
    
    float alpha = mix(char_opacity, 0.96, edge_flicker);
    
    ALBEDO = final_color;
    ALPHA = alpha;
}