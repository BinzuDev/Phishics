// NOTE: Shader automatically converted from Godot Engine 4.4.1.stable's StandardMaterial3D.
//--------------------------------------------------------------------
// This shader is used on the face on JFG's jellyfish hat.
// It allows the face to be INSIDE the hat, while being rendered ABOVE it,
// while still being rendered UNDER things in front, like the rim of the hat.
// This gives the face an "anime mouth viewed from the side" effect, where
// no matter at what angle you look from, the face will never touch the edge
// of the hat.


shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx, unshaded;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_disable;

uniform float depth_bias = 0.14;
uniform float cam_distance = 5.0;

//positive depth moves toward the camera in world units
uniform float depth_offset = 0.0;

void vertex() {
	//First solution, clip breaks after moving cam back
	//vec4 clip = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	//clip.z += depth_bias*0.1 * clip.w;
	//POSITION = clip;
	
	//Solution 2, camera needs to move further before clipping
	//vec4 clip = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	//float scaled_bias = depth_bias / (clip.w*cam_distance); // shrink bias with distance
	//clip.z += scaled_bias*0.1 * clip.w;
	//POSITION = clip;
	
	
	//Solution 3: taken from a better shader I found:
	//https://godotshaders.com/shader/depth-adjustment-for-clipping-protection/
	//model(local,object) to world(global) vertex position set to world_position
	vec3 world_position = vec4(MODEL_MATRIX * vec4(VERTEX,1)).xyz;
	//set direction vector from vertex to camera in world space
	vec3 dir2cam  = normalize(CAMERA_POSITION_WORLD - world_position);
	//offset depth by world(global) units.
	world_position += dir2cam * depth_offset;
	//transform world_position back to model(local, object) space and set vertex position.
	VERTEX = vec4(inverse(MODEL_MATRIX) * vec4(world_position,1)).xyz;
	
}


void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ALPHA *= albedo.a * albedo_tex.a;
}
