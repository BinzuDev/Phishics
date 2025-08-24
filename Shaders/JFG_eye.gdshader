shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx, depth_test_disabled, unshaded;


uniform sampler2D mask_tex;
uniform sampler2D pupil_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform vec2 pupil_offset = vec2(0.0, 0.0);


void fragment() {
	
	vec4 albedo_tex = texture(pupil_tex, UV + pupil_offset * -0.01);
	ALBEDO = albedo_tex.rgb;
	ALPHA *= albedo_tex.a;
	
	vec4 mask_alpha = texture(mask_tex, UV);
	ALPHA *= mask_alpha.a;
	
}

