
shader_type canvas_item;

uniform vec4 silhouette_color : source_color = vec4(1.0, 0.4, 0.0, 1.0);

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // Replace all visible pixels with solid orange
    COLOR = vec4(silhouette_color.rgb, tex.a);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
