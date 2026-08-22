shader_type spatial;
render_mode blend_mix, cull_disabled, particle_trails;

uniform sampler2D noise_tex : filter_linear, repeat_enable;
uniform vec2 scroll_speed = vec2(0.2, 1.5); 
uniform float distortion_strength = 0.3;    

group_uniforms colors_and_intensity;
uniform float fire_intensity = 64.0;
uniform float lava_intensity = 8.0;
uniform vec3 smoke_color = vec3(0.04, 0.015, 0.015);

group_uniforms timing_and_curves;
uniform float fire_to_lava_time : hint_range(0.0, 1.0) = 0.15;
uniform float lava_to_smoke_time : hint_range(0.0, 1.0) = 0.5;
uniform float color_curve : hint_range(0.1, 5.0) = 1.5; 

group_uniforms shaping;
uniform float head_taper_length : hint_range(0.0, 1.0) = 0.2; 
uniform float head_taper_start_width : hint_range(0.0, 1.0) = 0.0; 
uniform float edge_softness : hint_range(0.001, 1.0) = 0.1; 

void fragment() {
    vec2 noise_uv = UV + (TIME * scroll_speed);
    float noise_val = texture(noise_tex, noise_uv).r;

    vec3 base_col = vec3(0.2, 0.07, 0.01);
    vec3 col = pow(base_col, vec3(1.4));

    vec3 fire  = col * fire_intensity;
    vec3 lava  = col * lava_intensity;
    vec3 smoke = smoke_color;

    float color_axis = UV.y + ((noise_val - 0.5) * distortion_strength);
    color_axis = clamp(color_axis, 0.0, 1.0); 

    vec3 current_color;
    if (color_axis < fire_to_lava_time) {
        float t = color_axis / max(fire_to_lava_time, 0.001);
        t = pow(t, color_curve);
        current_color = mix(fire, lava, t);
    } else if (color_axis < lava_to_smoke_time) {
        float t = (color_axis - fire_to_lava_time) / max(lava_to_smoke_time - fire_to_lava_time, 0.001);
        t = pow(t, color_curve);
        current_color = mix(lava, smoke, t);
    } else {
        current_color = smoke;
    }

    // shape n masking
    // how far along the taper we are, 0 at head, 1 at the end of the taper length
    float taper_factor = smoothstep(0.0, head_taper_length, UV.x);
    float current_width = mix(head_taper_start_width, 1.0, taper_factor);
    // calculating distance from the center of the trail, UV.y=0.5 is center and 1.0 at outer edges
    float dist_from_center = abs(UV.y - 0.5) * 2.0;
    float shape_mask = smoothstep(current_width, current_width - edge_softness, dist_from_center);

    // trasnaprency gradient
    float alpha_axis = UV.x;
    float alpha = smoothstep(1.0, 0.0, alpha_axis); 
    alpha *= mix(0.5, 1.0, noise_val);
    alpha *= shape_mask;

    ALBEDO = current_color;
    EMISSION = current_color * smoothstep(lava_to_smoke_time, fire_to_lava_time, color_axis);
    ALPHA = alpha * COLOR.a;
}