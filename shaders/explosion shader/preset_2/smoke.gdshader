shader_type spatial;
render_mode blend_mix, cull_back;

uniform sampler3D noise_texture : repeat_enable, filter_linear_mipmap;

float sample_noise(vec3 p) {
    return texture(noise_texture, p).r * 2.0 - 1.0;
}

float fbm_pyro(vec3 pos, float time, float lacunarity, float gain, float evolution_speed) {
    float H = 0.6;
    float t = 0.0;
    vec3 p = pos;
    for (int i = 0; i < 3; i++) {
        float octave_speed = pow(lacunarity, float(i));
        vec3 drift = vec3(0.2, 0.3, 1.0) * time * evolution_speed * octave_speed;
        t += abs(sample_noise(p + drift)) * H;
        p *= lacunarity;
        H *= gain;
    }
    return t;
}

uniform float time_scale = 1.0;

group_uniforms smoke_appearance;
uniform vec3 smoke_color_dark : source_color = vec3(0.1, 0.1, 0.12);
uniform vec3 smoke_color_light : source_color = vec3(0.5, 0.5, 0.5);

group_uniforms lava_to_smoke_transition;
uniform float lava_intensity : hint_range(0.5, 10.0) = 3.0;
uniform float lava_to_smoke_time : hint_range(0.0, 1.0) = 0.35;
uniform float color_curve : hint_range(0.1, 5.0) = 1.5;

uniform float spatial_scale : hint_range(0.01, 10.0) = 1.5; 

group_uniforms fbm_shape;
uniform float fbm_evolution_speed : hint_range(0.0, 5.0) = 2.0; 
uniform float fbm_lacunarity      : hint_range(1.0, 4.0) = 2.1;
uniform float fbm_gain            : hint_range(0.1, 0.9) = 0.5;

group_uniforms texture_movement;
uniform float texture_outward_push : hint_range(0.0, 5.0) = 1.8;
uniform float texture_outward_friction : hint_range(1.0, 15.0) = 7.0;

group_uniforms dissolve;
uniform float dissolve_start : hint_range(0.0, 1.0) = 0.2;
uniform float dissolve_curve : hint_range(0.1, 5.0) = 2.0;

group_uniforms soft_smoke_look;
uniform float proximity_fade_distance : hint_range(0.0, 10.0) = 2.0;
uniform float fresnel_power      : hint_range(0.1, 10.0) = 3.0;
uniform float edge_transparency  : hint_range(0.0,  1.0) = 0.5;
uniform float emission_energy    : hint_range(0.0,  2.0) = 0.1;

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

group_uniforms wobble;
uniform float wobble_frequency : hint_range(0.1, 10.0) = 2.0;
uniform float wobble_speed     : hint_range(0.0, 10.0) = 1.0;
uniform float wobble_amount    : hint_range(0.0, 1.0) = 0.05;

varying float custom_life;
varying flat float particle_seed;
varying vec3 local_pos; 

varying vec3 v_r_off;
varying float v_fast_burst;
varying float v_evolution_time;

void vertex() {
    custom_life   = INSTANCE_CUSTOM.y;
    particle_seed = float(INSTANCE_ID);
    local_pos = VERTEX; 

    v_fast_burst = 1.0 - exp(-texture_outward_friction * custom_life);
    v_evolution_time = (v_fast_burst * 3.0) + (TIME * time_scale);

    v_r_off = vec3(
        fract(sin(particle_seed * 127.1) * 43758.5) * 4.0,
        fract(sin(particle_seed * 311.7) * 43758.5) * 4.0,
        fract(sin(particle_seed * 74.3)  * 31415.9) * 3.0 
    );

    float fast_burst_wobble = (1.0 - exp(-15.0 * custom_life)) * 2.0;
    float slow_drift = TIME * 0.2;
    float wobble_time = fast_burst_wobble + slow_drift;
    
    vec3 wobble_pos = VERTEX * wobble_frequency + vec3(particle_seed) + (wobble_time * wobble_speed);
    
    float organic_wobble = textureLod(noise_texture, wobble_pos, 0.0).r * 2.0 - 1.0;
    
    VERTEX += NORMAL * organic_wobble * wobble_amount;
}

void fragment() {
    vec3 dir = normalize(local_pos + vec3(0.0001));
    vec3 radial_scroll = dir * v_fast_burst * texture_outward_push;
    
    vec3 base_pos = (local_pos * spatial_scale) + v_r_off - radial_scroll;

    float master_noise = fbm_pyro(base_pos, v_evolution_time, fbm_lacunarity, fbm_gain, fbm_evolution_speed);
    
    float smoke_mask = smoothstep(0.2, 0.8, master_noise);

    float dissolve_noise = clamp(master_noise * 0.85, 0.0, 1.0);
    float dissolve_t = clamp((custom_life - dissolve_start) / max(1.0 - dissolve_start, 0.001), 0.0, 1.0);
    float dissolve_threshold = pow(dissolve_t, dissolve_curve);

    float alpha = smoothstep(dissolve_threshold, dissolve_threshold + 0.1, dissolve_noise);
    alpha *= smoothstep(1.0, 0.8, custom_life);
    alpha *= COLOR.a;

    float depth_tex = textureLod(depth_texture, SCREEN_UV, 0.0).r;
    
    vec3 ndc;
    #if CURRENT_RENDERER == RENDERER_COMPATIBILITY
        ndc = vec3(SCREEN_UV, depth_tex) * 2.0 - 1.0;
    #else
        ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth_tex);
    #endif

    vec4 upos = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
    float opaque_depth = -(upos.xyz / upos.w).z;

    float frag_depth = -VERTEX.z;
    float proximity = smoothstep(0.0, proximity_fade_distance, opaque_depth - frag_depth);

    float view_dot = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
    float fluffy_edge = view_dot * mix(0.3, 1.0, smoke_mask);
    float volume_alpha = smoothstep(0.0, edge_transparency, fluffy_edge);

    alpha *= volume_alpha * proximity;
    alpha = clamp(alpha, 0.0, 1.0);

    vec3 smoke_color = mix(smoke_color_dark, smoke_color_light, smoke_mask);
    float top_down_light = smoothstep(-0.5, 1.0, NORMAL.y);
    float illumination = mix(0.15, 1.0, top_down_light * smoke_mask);
    smoke_color *= illumination;

    float rz = max(master_noise, 0.001); 
    vec3 base_col   = vec3(0.2, 0.07, 0.01) / rz;
    base_col        = pow(base_col, vec3(1.4));
    vec3 lava_color = base_col * lava_intensity;

    float blend_t = clamp(custom_life / max(lava_to_smoke_time, 0.001), 0.0, 1.0);
    blend_t = smoothstep(0.0, 1.0, blend_t);
    blend_t = pow(blend_t, color_curve);
    
    vec3 final_color = mix(lava_color, smoke_color, blend_t);
    final_color *= COLOR.rgb;
    final_color = max(final_color, vec3(0.0));

    float lava_frac = clamp(1.0 - custom_life / max(lava_to_smoke_time, 0.001), 0.0, 1.0);

    ALBEDO    = final_color;
    EMISSION  = final_color * alpha * mix(emission_energy, lava_intensity * 0.5, lava_frac);
    ALPHA     = clamp(alpha, 0.0, 1.0);
}