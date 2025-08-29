// NOTE: Shader automatically converted from Godot Engine 4.4.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx, unshaded;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_disable;


uniform float depth_bias = 0.01;

void vertex() {
	//First solution, clip breaks after moving cam back
	//vec4 clip = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	//clip.z += depth_bias*0.1 * clip.w;
	//POSITION = clip;
	
	//Solution 2, camera needs to move further before clipping
	vec4 clip = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	float scaled_bias = depth_bias / (clip.w*3.0); // shrink bias with distance
	clip.z += scaled_bias*0.1 * clip.w;
	POSITION = clip;
}


void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ALPHA *= albedo.a * albedo_tex.a;
}
