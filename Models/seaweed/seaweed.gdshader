shader_type spatial;
render_mode cull_disabled;

uniform vec3 color : source_color;
uniform vec3 color2 : source_color;
uniform sampler2D noise;
uniform float noiseScale = 20.0;
uniform float noiseSpeed = 1.0;

uniform float amp = 0.2;
uniform float freq = 6.0;
uniform float speed = 1.0;

varying vec3 worldPos;


void vertex() {
	worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	//SINE WAVE        speed      make wave depend on y pos   make it not move at bottom
	VERTEX.z += sin((-TIME*speed)+(worldPos.y*freq))*amp * abs(1.0-UV.y);
	
	float height = texture(noise, (worldPos.xz + vec2(TIME) * speed*0.5) / noiseScale).r;
	VERTEX.x += (height*1.0-0.5) * abs(1.0-UV.y);
	//VERTEX.y += (height*0.1-0.05) * abs(1.0-UV.y);
}

void fragment() {
	float t = TIME * noiseSpeed;
	vec3 noiseLevel = texture(noise, vec2(worldPos.x+t, worldPos.y) / noiseScale).rgb;
	ALBEDO = mix(color, color2, UV.y) * mix(color, color2, noiseLevel.r);
}

