//--------------------------------------------------------------------
// This shader makes JFG's skirt and shirt wobbly and watery.
//--------------------------------------------------------------------

shader_type spatial;

render_mode depth_draw_always; //transparency works but cant see other body parts through
render_mode cull_disabled;

uniform sampler2D noise_tex;
uniform sampler2D clothes_texture : source_color;
uniform float height_multiplier = 0.2;
uniform float noise_sample_size = 0.1;
uniform float animation_speed = 0.1;
uniform float transparency = 0.2;

varying float height;

float fresnel(vec3 normal, mat4 camera_matrix){
	vec3 view_direction_world = (camera_matrix * vec4(0.0, 0.0, transparency, 0.0)).xyz;
	vec3 normal_world = (camera_matrix * vec4(normal,0.0)).xyz;

	float d = dot(view_direction_world, normal_world);
	d = abs(d);
	d = clamp(d, 0.0, 1.0);

	return 1.0 - d;
}

void vertex(){
	height = texture(noise_tex, UV2 * noise_sample_size + vec2(TIME) * animation_speed*0.1).r;
	//height = texture(noise_tex, VERTEX.xz * noise_sample_size + vec2(TIME) * animation_speed*0.1).r;
	VERTEX += NORMAL * height * height_multiplier * 0.1;
}

void fragment(){
	//ROUGHNESS = mix(0.05, 0.1, 1.0 - height);
	SPECULAR = height;
	ALPHA = fresnel(NORMAL, INV_VIEW_MATRIX);
	vec4 tex_color = texture(clothes_texture, UV);
	ALBEDO = tex_color.rgb;
}