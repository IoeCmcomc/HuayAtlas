shader_type canvas_item;

uniform vec4 border_color: hint_color = vec4(1);
uniform float border_width: hint_range(0, 10) = 1.0;


void fragment() {
    vec2 size = TEXTURE_PIXEL_SIZE * border_width;

    float left = texture(TEXTURE, UV + vec2(-size.x, 0)).a;
    float right = texture(TEXTURE, UV + vec2(size.x, 0)).a;
    float up = texture(TEXTURE, UV + vec2(0, size.y)).a;
    float down = texture(TEXTURE, UV + vec2(0, -size.y)).a;
    
    float sum = left + right + up + down;
    float outline = min(sum, 1.0);

    vec4 color = texture(TEXTURE, UV);
	
    COLOR = mix(color, border_color, outline - color.a);
}