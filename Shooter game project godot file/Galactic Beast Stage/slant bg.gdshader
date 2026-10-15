
shader_type canvas_item;

uniform float depth : hint_range(0.0, 0.5) = 0.30;
uniform bool flip = false;
uniform float scroll_speed = 0.8;

void fragment() {
    vec2 uv = UV;

    // Left edge remains full height.
    // Right edge becomes shorter.
    float x = flip ? 1.0 - uv.x : uv.x;

    // Compress the vertical range toward the inner edge.
    float compression = depth * x;

    float top = compression;
    float bottom = 1.0 - compression;

    // Discard pixels outside the trapezoid.
    if (uv.y < top || uv.y > bottom) {
        COLOR = vec4(0.0);
    } else {
        // Remap the texture to fill the trapezoid.
        float warped_y = (uv.y - top) / (bottom - top);

        vec2 texture_uv = vec2(
            uv.x,
            fract(warped_y - TIME * 0.5)
        );

        COLOR = texture(TEXTURE, texture_uv);
    }
}
