//shader by Anthony D. Salsbury; inverts the color currently on the screen, for ui stuff

shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec4 temp_color = texture(TEXTURE, UV);
	vec4 screen_color = textureLod(screen_texture, SCREEN_UV, 0.0);
	temp_color.r = 1.0 - screen_color.r;
	temp_color.g = 1.0 - screen_color.g;
	temp_color.b = 1.0 - screen_color.b;
	temp_color.a = temp_color.a * COLOR.a;
	COLOR = temp_color;
}