//--------------------------------------------------------------------
// This shader is used by the eel's scope to make a circular hole in a 
// black rectangle, which fits the screen no matter the aspect ratio
//--------------------------------------------------------------------

shader_type canvas_item;
render_mode unshaded;

uniform float circle_size : hint_range(0.0, 1.1);
uniform float gradient: hint_range(0.0, 0.5) = 0.025;
uniform float opacity: hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float screen_width;
uniform float screen_height;

void fragment() {
	float ratio = screen_width / screen_height;
	float dist = distance( vec2(0.5, 0.5), vec2(mix(0.5, UV.x, ratio), UV.y) );
	COLOR.a = smoothstep(circle_size-(gradient*2.0), circle_size+gradient, dist);
	COLOR.a *= opacity;
}