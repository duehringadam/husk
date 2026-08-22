shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
// New uniforms for the noise texture distortion
uniform sampler2D noise_texture : hint_default_white;
uniform float noise_strength : hint_range(0.0, 0.1) = 0.02;

uniform int blur_amount : hint_range(1, 50) = 25;
uniform float blur_radius : hint_range(0.0, 1.0) = 0.6;
uniform float feather_amount : hint_range(0.0, 0.5) = 0.2; 

// Controls for the explosion shake
uniform float shake_speed : hint_range(0.0, 100.0) = 60.0;
uniform float shake_intensity : hint_range(0.0, 0.5) = 0.15;

// Pseudo-random generator function for erratic shaking
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

void vertex() {
    // Standard Godot billboard logic to face the camera
    MODELVIEW_MATRIX[0].xyz = vec3(length(MODEL_MATRIX[0].xyz), 0.0, 0.0);
    MODELVIEW_MATRIX[1].xyz = vec3(0.0, length(MODEL_MATRIX[1].xyz), 0.0);
    MODELVIEW_MATRIX[2].xyz = vec3(0.0, 0.0, length(MODEL_MATRIX[2].xyz));
}

void fragment() {
    vec2 screen_uv = SCREEN_UV;
    
    float stepped_time = floor(TIME * shake_speed);
    vec2 shake_offset = vec2(
        hash(vec2(stepped_time, 1.0)) * 2.0 - 1.0,
        hash(vec2(stepped_time, 2.0)) * 2.0 - 1.0
    ) * shake_intensity;
    
    // Apply the erratic shake to the screen-space blur center
    vec2 blur_center = vec2(0.5) + shake_offset;
    vec2 dir = blur_center - screen_uv;
    
    // Fetch a noise value using the screen UVs or Quad UVs
    // Multiplying TIME * shake_speed animates the grain so it doesn't look static
    vec2 noise_uv = screen_uv + vec2(stepped_time * 0.13);
    vec2 noise_offset = (texture(noise_texture, noise_uv).rg - 0.5) * noise_strength;
    
    // 2. Perform the heavy radial blur with noise injected
    vec4 blurred_color = vec4(0.0);
    float scale = blur_radius / float(blur_amount);
    
    for (int i = 0; i < blur_amount; i++) {
        vec2 offset = dir * (float(i) * scale);
        // Injecting the noise offset directly into the UV lookup per step
        blurred_color += texture(screen_texture, screen_uv + offset + noise_offset);
    }
    blurred_color /= float(blur_amount);
    
    // Fetch clean background color
    vec4 clean_color = texture(screen_texture, screen_uv);
    
    // 3. Calculate feathering based on Quad's UVs
    float dist = distance(UV, vec2(0.5));
    float mask = smoothstep(0.5, 0.5 - feather_amount, dist);
    
    // Mix clean image and blurred image
    vec3 final_color = mix(clean_color.rgb, blurred_color.rgb, mask);
    
    ALBEDO = final_color;
}
