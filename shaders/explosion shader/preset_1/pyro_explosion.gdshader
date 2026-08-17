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

uniform float dissolve_start : hint_range(0.0, 1.0) = 0.3;
uniform float dissolve_curve : hint_range(0.1, 5.0) = 2.0;

varying float custom_life;

varying vec3 v_base_pos;
varying float v_local_time;

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
    custom_life = INSTANCE_CUSTOM.y;
    float particle_seed = float(INSTANCE_ID);
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

    v_local_time = TIME * time_scale;

    vec3 r_off = vec3(
        fract(sin(particle_seed * 127.1) * 43758.5) * 4.0,
        fract(sin(particle_seed * 311.7) * 43758.5) * 4.0,
        fract(sin(particle_seed * 74.3)  * 31415.9) * 3.0
    );

    v_base_pos = vec3(world_pos.xz * world_space_scale, v_local_time * fbm_evolution_speed) + r_off;

    float wobble_speed  = 5.0;
    float wobble_amount = 0.08;
    vec3 displacement = NORMAL * sin(VERTEX.y * 10.0 + VERTEX.x * 10.0 + TIME * wobble_speed + particle_seed) * wobble_amount;
    VERTEX += displacement;
}

void fragment() {
    float rz = fbm_pyro(v_base_pos * 2.0, v_local_time, fbm_lacunarity, fbm_gain, fbm_evolution_speed);

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

    float raw_dissolve    = fbm_pyro(v_base_pos * 0.35, v_local_time, fbm_lacunarity, fbm_gain, fbm_evolution_speed * 0.5);
    float dissolve_noise  = clamp(raw_dissolve * 0.85, 0.0, 1.0);
    float dissolve_t      = clamp((custom_life - dissolve_start) / max(1.0 - dissolve_start, 0.001), 0.0, 1.0);
    float dissolve_threshold = pow(dissolve_t, dissolve_curve);

    float alpha = smoothstep(dissolve_threshold, dissolve_threshold + 0.15, dissolve_noise);
    alpha *= smoothstep(1.0, 0.9, custom_life);

    ALBEDO   = current_color;
    EMISSION = current_color * smoothstep(lava_to_smoke_time, fire_to_lava_time, custom_life);
    ALPHA    = alpha;
}