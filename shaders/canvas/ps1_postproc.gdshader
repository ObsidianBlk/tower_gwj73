shader_type canvas_item;
render_mode unshaded;

/*
Code adapted by: Bryan Miller
Original from: https://godotshaders.com/shader/ps1-post-processing/
*/

uniform int color_depth : hint_range(1, 8) = 5;
uniform bool dithering = true;
uniform int resolution_scale = 4;

uniform sampler2D screen_texture : hint_screen_texture;

int dithering_pattern(ivec2 fragcoord) {
	const int pattern[] = {
		-4, +0, -3, +1, 
		+2, -2, +3, -1, 
		-3, +1, -4, +0, 
		+3, -1, +2, -2
	};
	
	int x = fragcoord.x % 4;
	int y = fragcoord.y % 4;
	
	return pattern[y * 4 + x];
}

void fragment() {
	ivec2 uv = ivec2(FRAGCOORD.xy / float(resolution_scale));
	vec3 color = texture(TEXTURE, UV).rgb;
	ivec3 c = ivec3(round(color * 255.0));
	
	if (dithering) {
		c += ivec3(dithering_pattern(uv));
	}
	
	c >>= (8 - color_depth);
	
	COLOR = vec4(vec3(c) / float(1 << color_depth), 1.0);
}
