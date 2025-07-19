shader_type spatial;
render_mode unshaded;

uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform vec2 frequency = vec2(0.0, 5.0);
uniform vec2 amplitutde = vec2(0.0, 0.05);
uniform float speed = 5;
uniform vec2 movement = vec2(-1.0, 0.0);


void fragment() {
	vec2 move = movement * TIME * 0.1;

	vec2 pos = mod((UV - amplitutde * sin(TIME*speed + vec2(UV.y, UV.x) * frequency)), 10);

	vec4 albedo_tex = texture(texture_albedo, pos + move);




	ALBEDO = albedo_tex.rgb;
	ALPHA = albedo_tex.a;
}
