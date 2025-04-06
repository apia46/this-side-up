shader_type spatial;
render_mode unshaded;

uniform vec4 outline_color : source_color = vec4(1.0);

void vertex() {
	if (VERTEX.x < 0.0) { VERTEX.x -= 0.03; }
	else { VERTEX.x -= 0.001; }
	VERTEX.y -= 0.001;
	if (VERTEX.z < 0.0) { VERTEX.z -= 0.03; }
	else { VERTEX.z -= 0.001; }
}

void fragment() {
	ALBEDO = outline_color.rgb;
}