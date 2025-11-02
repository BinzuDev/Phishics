//--------------------------------------------------------------------
// This shader allows me to animate JFG pupils by moving them around
// and only rendering them on pixels with the eye whites.
// You can change the frame of the eye white to make her wink or squint.
//--------------------------------------------------------------------

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx, depth_test_disabled, unshaded;


uniform sampler2D mask_tex;
uniform int mask_Hframes = 4;
uniform int mask_Vframes = 4;
uniform int mask_frame = 0;



uniform sampler2D pupil_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform vec2 pupil_offset = vec2(0.0, 0.0);


void fragment() {
	
	//iris
	vec4 albedo_tex = texture(pupil_tex, UV + pupil_offset * -0.01);
	ALBEDO = albedo_tex.rgb;
	ALPHA *= albedo_tex.a;
	
	
	

	vec3 uv2_offset = vec3(0,0,0);
	float H = float(mask_Hframes);
	float V = float(mask_Vframes);
	uv2_offset.x = float(mask_frame)/H;
	uv2_offset.y = floor( float(mask_frame)/H )/V;
	
	vec3 uv2_scale = vec3(1.0/H, 1.0/V, 1);
	//UV ;
	
	vec4 mask_alpha = texture(mask_tex, UV* uv2_scale.xy + uv2_offset.xy);
	
	
	
	ALPHA *= mask_alpha.a;
	
}

