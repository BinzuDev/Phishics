shader_type spatial;

render_mode depth_draw_always; //transparency works but cant see other body parts through


uniform sampler2D noise_tex;
uniform vec4 bubble_color: source_color;
uniform float height_multiplier = 0.2;
uniform float noise_sample_size = 0.1;
uniform float animation_speed = 0.1;
uniform float transparency = 0.2;
uniform sampler2D underwear_texture : source_color;

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
	height = (height + 1.0) * 0.5; //code that makes her grow less on average
	height = pow(height, 5.0);     //when you increase the height multiplier
	VERTEX += NORMAL * height * height_multiplier * 0.1;
}

void fragment(){

	// CUSTOM CODE //
	vec4 mask_color = texture(underwear_texture, UV);
	float threshold = 0.5;
	bool is_black = mask_color.r <= 0.5 && mask_color.g >= 0.5 && mask_color.b >= 0.5;
	bool is_no_tex = mask_color.r == 1.0 && mask_color.g == 1.0 && mask_color.b == 1.0;

    if (is_black) {
		ROUGHNESS = mix(0.05, 0.1, 1.0 - height);
		SPECULAR = height;
		ALPHA = fresnel(NORMAL, INV_VIEW_MATRIX);
		ALBEDO = bubble_color.rgb;
    } else {
        ALBEDO = mask_color.rgb;
    }

}
