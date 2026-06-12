shader_type spatial;
render_mode unshaded;
uniform float size: hint_range(0.0, 0.25);
uniform float alpha: hint_range(0.0, 1.0);
uniform vec3 color;

void fragment() {
	vec2 center = vec2(0.25, 0.75);
	float df = distance(UV, center);
	float circle = step(size, df);
	ALBEDO = vec3(circle) * color;
	ALPHA = alpha;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
