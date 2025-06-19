shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx, depth_test_disabled;

uniform int Hframes = 4;
uniform int Vframes = 4;
uniform int frame;

uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;


void vertex() {
	vec3 uv1_offset = vec3(0,0,0);
	float H = float(Hframes);
	float V = float(Vframes);
	uv1_offset.x = float(frame)/H ;
	uv1_offset.y = floor( float(frame)/H ) / V;

	vec3 uv1_scale = vec3(1.0/H, 1.0/V, 1);

	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo_tex.rgb;
	ALPHA *= albedo_tex.a;

}