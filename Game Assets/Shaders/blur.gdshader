shader_type canvas_item;

uniform sampler2D SCREEN : hint_screen_texture;
uniform float blur = 2.0;
uniform vec2 res = vec2(1024.0, 1024.0);

void fragment() {
	vec4 color = vec4(0.0);
	vec2 _res = vec2(1.0) / res;
	
	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			color += texture(SCREEN, SCREEN_UV + (vec2(float(x), float(y)) * blur * _res));
		}
	}
	
	color /= 9.0;
	
	COLOR = color;
}