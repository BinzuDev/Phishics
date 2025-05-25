shader_type spatial;

uniform sampler2D mask_texture : source_color;
uniform vec4 target_color : source_color; // The color to replace white with

void fragment() {
    vec4 mask_color = texture(mask_texture, UV);
    // Assume white means R, G, B are all 1.0 (or close to)
    float threshold = 0.5;
    bool is_white = mask_color.r > threshold && mask_color.g > threshold && mask_color.b > threshold;

    if (is_white) {
        ALBEDO = target_color.rgb;
    } else {
        ALBEDO = vec3(0.0); // Black or transparent
    }
}