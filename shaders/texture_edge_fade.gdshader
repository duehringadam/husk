shader_type canvas_item;

uniform sampler2D textureNoise: repeat_enable;
uniform float radius: hint_range(0.0, 1.0) = 0.459;
uniform float effectControl: hint_range(0.0, 1.0) = 0.309;
uniform float burnSpeed: hint_range(0.0, 1.0) = 0.076;
uniform float shape: hint_range(0.0, 1.0) = 1.0;
uniform vec4 my_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); 
uniform float feather: hint_range(0.0, 0.5) = 0.05; 

uniform float radius_scale: hint_range(0.0, 1.0, 0.1) = 0.1;
uniform bool rounded_corner_top_left = true;
uniform bool rounded_corner_top_right = true;
uniform bool rounded_corner_bottom_left = true;
uniform bool rounded_corner_bottom_right = true;
uniform float width = 1.0;
uniform float height = 1.0;

void fragment() {
    vec2 centerDistVec = vec2(0.5) - UV;
    
	float distToCircleEdge = length(centerDistVec) * radius;
	float distToSquareEdge = 0.5*(0.5 - min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y)));
	float distToEdge = mix(distToCircleEdge,distToSquareEdge,shape);

    float gradient = smoothstep(0.5, 0.5 - radius, distToEdge);

    vec2 direction = vec2(0, 1) * burnSpeed;
    float noiseValue = texture(textureNoise, UV + direction * TIME).r;
// The mixed value driving your burn/dissolve animation
    float burnValue = mix(gradient, noiseValue, effectControl) - distToEdge;
    float opacity = smoothstep(radius - feather, radius + feather, burnValue);

    COLOR = texture(TEXTURE, UV) * vec4(1.0, 1.0, 1.0, opacity) * my_color;
	
	vec4 image = texture(TEXTURE, UV);
	vec2 pos = vec2(UV.x*width, UV.y*height);
	float border_radius = min(width, height)*radius_scale/2.0;
	float dist;
	// Top left corner
	if (rounded_corner_top_left) {
		dist = length(pos - vec2(border_radius));
		if (dist > border_radius && pos.x < border_radius && pos.y < border_radius) {
			image.a = 0.0;
		}
		// debugging only
//		if (dist < radius){image.r = 1.0;}
	}
	// Top right corner
	if (rounded_corner_top_right) {
		dist = length(pos - vec2(width-border_radius, border_radius));
		if (dist > border_radius && pos.x > width-border_radius && pos.y < border_radius) {
			image.a = 0.0;
		}
		// debugging only
//		if (dist < radius){image.r = 1.0;}
	}
	// Bottom left corner
	if (rounded_corner_bottom_left) {
		dist = length(pos - vec2(border_radius, height-border_radius));
		if (dist > border_radius && pos.x < border_radius && pos.y > height-border_radius) {
			image.a = 0.0;
		}
		// debugging only
//		if (dist < radius){image.r = 1.0;}
	}
	// Bottom right corner
	if (rounded_corner_bottom_right) {
		dist = length(pos - vec2(width-border_radius, height-border_radius));
		if (dist > border_radius && pos.x > width-border_radius && pos.y > height-border_radius) {
			image.a = 0.0;
		}
		// debugging only
//		if (dist < radius){image.r = 1.0;}
	}
	COLOR = texture(TEXTURE, UV) * vec4(1.0, 1.0, 1.0, opacity) * my_color * image;
}
