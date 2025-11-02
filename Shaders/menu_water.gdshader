shader_type canvas_item;

uniform bool big_wave = true;
uniform float big_amplitude : hint_range(0.1, 40.0) = 30.0;
uniform float big_frequency : hint_range(0.1, 10.0) = 0.7;
uniform float big_speed : hint_range(0.0, 5.0) = 0.3;
uniform sampler2D noise_tex : source_color, repeat_enable;

uniform bool small_wave = true;
uniform float small_amplitude : hint_range(0.1, 40.0) = 10.0;
uniform float small_frequency : hint_range(0.1, 10.0) = 10.0;
uniform float small_speed : hint_range(0, 5.0) = 1.0;

// Tint settings
uniform bool tint_enabled = true;
uniform vec3 tint_color : source_color = vec3(0.2, 0.8, 1.0); // bluish light
uniform float tint_strength : hint_range(0.0, 2.0) = 0.5;
uniform float small_wave_reflection : hint_range(0.5, 5.0) = 2.0;

uniform vec3 final_color : source_color = vec3(0.2, 0.8, 1.0);
uniform float final_color_alpha : hint_range(0.0, 1.0) = 0.3;

uniform float transparency : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec2 uv = UV;
	vec4 orig = texture(TEXTURE, uv);
	
	vec2 total_offset = vec2(0.0);
	float brightness_factor = 0.0;
	
	// --- BIG WAVES ---
	if (big_wave) {
		float t = TIME * big_speed * 0.1;
	
		vec2 noise_uv_x = uv * big_frequency + vec2(t, 0.0);
		vec2 noise_uv_y = uv * big_frequency + vec2(0.0, t);
		float nx = texture(noise_tex, noise_uv_x).r;
		float ny = texture(noise_tex, noise_uv_y).g;
		vec2 rand_dir = normalize(vec2(nx * 2.0 - 1.0, ny * 2.0 - 1.0));
	
		float n = texture(noise_tex, uv * big_frequency + vec2(t * 0.5)).b;
		float offset = (n * 2.0 - 1.0) * big_amplitude;
	
		vec2 big_offset = rand_dir * offset * TEXTURE_PIXEL_SIZE;
		total_offset += big_offset;
		// Use absolute offset magnitude as a brightness cue
		brightness_factor = length(big_offset) / (big_amplitude * length(TEXTURE_PIXEL_SIZE));
	}
	
	// --- SMALL WAVES ---
	if (small_wave) {
		float t = TIME * small_speed * 0.1;
		
		vec2 noise_uv_x = uv * small_frequency + vec2(-t, 0.0);
		vec2 noise_uv_y = uv * small_frequency + vec2(0.0, -t);
		float nx = texture(noise_tex, noise_uv_x).r;
		float ny = texture(noise_tex, noise_uv_y).g;
		vec2 rand_dir = normalize(vec2(nx * 2.0 - 1.0, ny * 2.0 - 1.0));
		
		float n = texture(noise_tex, uv * small_frequency + vec2(-t * 0.5)).b;
		float offset = (n * 2.0 - 1.0) * small_amplitude;
		
		vec2 small_offset = rand_dir * offset * TEXTURE_PIXEL_SIZE;
		total_offset += small_offset;
		brightness_factor -= length(small_offset) / (small_amplitude*small_wave_reflection * length(TEXTURE_PIXEL_SIZE));
	}
	
	
	vec4 col = texture(TEXTURE, uv + total_offset);
	
	if (tint_enabled && big_wave) {
		// Remap brightness factor to 0–1 range
		float brightness = clamp(1.0-brightness_factor, 0.0, 1.0);
		// Apply contrast boost and sharpen transitions
		//brightness = pow(brightness, 5.0);
		brightness = smoothstep(0.5, 1.0, pow(brightness, 6.0));
		
		// Mix tint based on brightness
		
		col.rgb = mix(col.rgb * (1.0 - tint_strength * 0.1), //the dark color
					  col.rgb + tint_color * tint_strength*0.25, //the bright color
					  brightness); 
	}
	
	col.rgb = mix(col.rgb, final_color, final_color_alpha);
	
	COLOR = col;
	
	COLOR.a = transparency;
	
}
