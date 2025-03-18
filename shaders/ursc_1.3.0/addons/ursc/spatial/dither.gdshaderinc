global uniform sampler2D dither_texture: filter_nearest;
global uniform float dither_scale;
global uniform float dither_strength;
global uniform float dither_levels;

void light() {
    float light = clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION;
    vec2 ts = vec2(textureSize(dither_texture, 0)) * dither_scale;
    vec2 uv = mod(FRAGCOORD.xy, ts) / ts;
    light += (texture(dither_texture, uv).r - 0.5) * dither_strength;
    light = floor(light * dither_levels) / dither_levels;
    DIFFUSE_LIGHT += light * LIGHT_COLOR;
	
}