shader_type canvas_item;
const vec4 tint = vec4(1, 0, 0, 1);
uniform float mix_amount : hint_range(0, 1) = 0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
	if (tex.a != 0.0){
		COLOR = mix(tex, tint, mix_amount);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
