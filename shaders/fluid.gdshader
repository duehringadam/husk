// Water shader modified to remove sun highlights
// Original by Somebody (Telegram: https://t.me/somebody_dev)
// License: MIT

shader_type spatial;

// Color and material properties
uniform vec3 water_color : source_color = vec3(0.0, 0.635, 0.639); // Base color of the water
uniform float color_ratio : hint_range(0.0, 1.0, 0.001) = 0.01; // Ratio for blending water color with screen texture
uniform float alpha_scale : hint_range(0.0, 1.0, 0.01) = 0.8; // Controls overall transparency of the water
uniform float roughness : hint_range(0.0, 1.0, 0.01) = 0.2; // Surface roughness for reflections
uniform float normal : hint_range(0.0, 1.0, 0.01) = 0.4; // Normal map intensity

// Texture inputs
uniform sampler2D water_normal_noise_1: filter_nearest_mipmap_anisotropic; // First normal map for water surface
uniform sampler2D water_normal_noise_2: filter_nearest_mipmap_anisotropic; // Second normal map for water surface
uniform sampler2D foam_texture: filter_nearest_mipmap_anisotropic; // Texture for foam effect
uniform sampler2D screen_tex : filter_nearest_mipmap_anisotropic, hint_screen_texture, repeat_disable; // Screen texture for background
uniform sampler2D depth_tex : filter_nearest_mipmap_anisotropic, hint_depth_texture; // Depth texture for depth-based effects

// Animation and scaling parameters
uniform float time_scale : hint_range(0.0, 10.0, 0.1) = 1.0; // Speed of water animation
uniform vec2 normal_scroll_speed_1 = vec2(0.01, 0.01); // Direction and speed for normal 1
uniform vec2 normal_scroll_speed_2 = vec2(-0.01, -0.01); // Direction and speed for normal 2
uniform float uv_scale : hint_range(0.0, 200.0, 0.1) = 1.0; // Scale of UV coordinates for textures
uniform float normal_blend : hint_range(0.0, 1.0, 0.01) = 0.5; // Blend factor between two normal maps

// Depth and foam parameters
uniform float depth_distance : hint_range(0.0, 10.0, 0.1) = 0.5; // Distance for depth-based blending
uniform float foam_intensity : hint_range(0.0, 1.0, 0.01) = 0.5; // Intensity of foam effect
uniform float foam_width : hint_range(0.0, 1.0, 0.01) = 0.1; // Width of foam transition
uniform float shore_fade_distance : hint_range(0.0, 5.0, 0.01) = 1.0; // Distance for shore fading effect

void fragment() {
    // Scale UV coordinates for texture sampling
    vec2 _uv = UV * uv_scale;
    vec2 _suv = SCREEN_UV;
    
    // Calculate UV offsets for first normal map with linear scroll and wave distortion
    vec2 uv_offset_1 = _uv + (TIME * time_scale * normal_scroll_speed_1);
    uv_offset_1.x += sin(TIME * time_scale + (uv_offset_1.x + uv_offset_1.y) * 25.0) * 0.01;
    uv_offset_1.y += cos(TIME * time_scale + (uv_offset_1.x + uv_offset_1.y) * 25.0) * 0.01;
    
    // Calculate UV offsets for second normal map with opposite linear scroll and wave distortion
    vec2 uv_offset_2 = _uv + (TIME * time_scale * normal_scroll_speed_2);
    uv_offset_2.x += sin(-TIME * time_scale + (uv_offset_2.x + uv_offset_2.y) * 25.0) * 0.01;
    uv_offset_2.y += cos(-TIME * time_scale + (uv_offset_2.x + uv_offset_2.y) * 25.0) * 0.01;
    
    // Apply subtle distortion to screen UVs for a wavy effect
    _suv.x += sin(TIME * time_scale + (_suv.x + _suv.y)) * 0.002;
    _suv.y += cos(TIME * time_scale + (_suv.x + _suv.y)) * 0.002;
    
    // Get the clean, distorted background screen color
    vec3 background_color = texture(screen_tex, _suv).rgb;
    
    // Sample and blend normal maps for water surface
    vec3 normal_1 = texture(water_normal_noise_1, uv_offset_1).rgb;
    vec3 normal_2 = texture(water_normal_noise_2, uv_offset_2).rgb;
    vec3 blended_normal = mix(normal_1, normal_2, normal_blend);
    
    // Calculate depth for blending water with the scene
    float depth_r = textureLod(depth_tex, SCREEN_UV, 0.0).r;
    vec4 world = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth_r, 1.0);
    world.xyz /= world.w;
    float scene_depth = world.z;
    float depth_blend = smoothstep(world.z + depth_distance, world.z, VERTEX.z);
    
    // Blend water color with the background scene based on depth
    vec3 water_albedo = mix(background_color, water_color, color_ratio) * depth_blend;
    
    // Calculate foam effect based on depth difference
    float depth_diff = abs(scene_depth - VERTEX.z);
    float foam_mask = 1.0 - smoothstep(0.0, foam_width, depth_diff);
    
    // Sample and blend foam textures
    vec4 foam1 = texture(foam_texture, uv_offset_1);
    vec4 foam2 = texture(foam_texture, uv_offset_2);
    vec4 foam = mix(foam1, foam2, normal_blend);
    vec3 foam_color = foam.rgb;
    float foam_alpha = foam.a;
    
    // Apply foam to water albedo
    water_albedo += foam_color * foam_alpha * foam_mask * foam_intensity;
    
    // Calculate shore fading effect based on depth difference
    float shore_alpha = smoothstep(0.0, shore_fade_distance, depth_diff);
    
    // Set final shader outputs
    ALBEDO = water_albedo; // Final color of the water
    NORMAL_MAP = blended_normal; // Normal map for lighting
    NORMAL *= normal; // Apply normal intensity
    ROUGHNESS = roughness; // Apply roughness value
    ALPHA = alpha_scale * shore_alpha; // Final transparency with shore fading
}
