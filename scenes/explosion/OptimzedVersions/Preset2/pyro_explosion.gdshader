shader_type spatial;
render_mode blend_mix, cull_back;

uniform sampler3D noise_texture : repeat_enable, filter_linear_mipmap;
uniform float time_scale = 1.0;

group_uniforms colors_and_intensity;
uniform float fire_intensity = 40.0;
uniform float lava_intensity = 3.0;
uniform vec3  smoke_color    = vec3(0.04, 0.015, 0.015);

group_uniforms timing_and_curves;
uniform float fire_to_lava_time  : hint_range(0.0, 1.0) = 0.15;
uniform float lava_to_smoke_time : hint_range(0.0, 1.0) = 0.5;
uniform float color_curve        : hint_range(0.1, 5.0) = 1.5;
uniform float world_space_scale  : hint_range(0.01, 5.0) = 0.5;

group_uniforms fbm_shape;
uniform float fbm_evolution_speed : hint_range(0.0, 3.0) = 0.6; 
uniform float fbm_lacunarity      : hint_range(1.0, 4.0) = 2.1;
uniform float fbm_gain            : hint_range(0.1, 0.9) = 0.5;

group_uniforms texture_movement;
uniform float texture_outward_push : hint_range(0.0, 5.0) = 2.0;
uniform float texture_outward_friction : hint_range(1.0, 15.0) = 6.0;

uniform float dissolve_start : hint_range(0.0, 1.0) = 0.3;
uniform float dissolve_curve : hint_range(0.1, 5.0) = 2.0;

group_uniforms soft_volume;
uniform float proximity_fade_distance : hint_range(0.0, 10.0) = 2.0;
uniform float edge_transparency  : hint_range(0.0,  1.0) = 0.5;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

varying float custom_life;
varying flat float particle_seed;
varying vec3 local_pos;

varying vec3 v_r_off;
varying float v_fast_burst;
varying float v_dynamic_time;

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

void vertex() {
    custom_life   = INSTANCE_CUSTOM.y;
    particle_seed = float(INSTANCE_ID);
    local_pos     = VERTEX;

    v_fast_burst = 1.0 - exp(-texture_outward_friction * custom_life);
    v_dynamic_time = (v_fast_burst * 2.0) + (TIME * time_scale);

    v_r_off = vec3(
        fract(sin(particle_seed * 127.1) * 43758.5) * 4.0,
        fract(sin(particle_seed * 311.7) * 43758.5) * 4.0,
        fract(sin(particle_seed * 74.3)  * 31415.9) * 3.0
    );

    float wobble_speed  = 5.0;
    float wobble_amount = 0.01; 
    vec3 displacement = NORMAL * sin(VERTEX.y * 10.0 + VERTEX.x * 10.0 + TIME * wobble_speed + particle_seed) * wobble_amount;
    VERTEX += displacement;
}

void fragment() {
    vec3 dir = normalize(local_pos + vec3(0.0001));
    vec3 radial_scroll = dir * v_fast_burst * texture_outward_push;
    vec3 base_pos = (local_pos * world_space_scale) + v_r_off - radial_scroll;

    float rz = fbm_pyro(base_pos * 2.0, v_dynamic_time, fbm_lacunarity, fbm_gain, fbm_evolution_speed);

    vec3 base_col = vec3(0.2, 0.07, 0.01) / max(rz, 0.001);
    vec3 col      = pow(base_col, vec3(1.4));

    vec3 fire  = col * fire_intensity;
    vec3 lava  = col * lava_intensity;
    vec3 smoke = smoke_color * rz;

    vec3 current_color;
    if (custom_life < fire_to_lava_time) {
        float t = smoothstep(0.0, 1.0, custom_life / max(fire_to_lava_time, 0.001));
        t = pow(t, color_curve);
        current_color = mix(fire, lava, t);
    } else {
        float t = clamp((custom_life - fire_to_lava_time) / max(lava_to_smoke_time - fire_to_lava_time, 0.001), 0.0, 1.0);
        t = smoothstep(0.0, 1.0, t);
        t = pow(t, color_curve);
        current_color = mix(lava, smoke, t);
    }

    float raw_dissolve    = fbm_pyro(base_pos * 0.35, v_dynamic_time, fbm_lacunarity, fbm_gain, fbm_evolution_speed * 0.5);
    float dissolve_noise  = clamp(raw_dissolve * 0.85, 0.0, 1.0);
    float dissolve_t      = clamp((custom_life - dissolve_start) / max(1.0 - dissolve_start, 0.001), 0.0, 1.0);
    float dissolve_threshold = pow(dissolve_t, dissolve_curve);

    float alpha = smoothstep(dissolve_threshold, dissolve_threshold + 0.15, dissolve_noise);
    alpha *= smoothstep(1.0, 0.9, custom_life);

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
    float fluffy_edge = view_dot * mix(0.3, 1.0, clamp(rz * 0.5, 0.0, 1.0));
    float volume_alpha = smoothstep(0.0, edge_transparency, fluffy_edge);

    alpha *= volume_alpha;
    alpha *= proximity;
    alpha = clamp(alpha, 0.0, 1.0);

    ALBEDO   = current_color;
    EMISSION = current_color * smoothstep(lava_to_smoke_time, fire_to_lava_time, custom_life);
    ALPHA    = alpha;
}