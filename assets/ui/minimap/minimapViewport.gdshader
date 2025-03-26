shader_type canvas_item;
const vec4 BG_COLOR = vec4(0.2,0.2,0.2,1);
uniform float t = 0.785398163397;
uniform float size;

void fragment() {
	float lt = t * 0.32;
	if (abs(cos(t)*UV.x + sin(t)*UV.y) + abs(cos(t)*UV.y - sin(t)*UV.x) < size // square 1
	|| abs(sin(lt)*UV.x + cos(lt)*UV.y) + abs(sin(lt)*UV.y - cos(lt)*UV.x) < size) { // square 2
		float bgOpacity = 1.0 - COLOR.a;
		COLOR.r += bgOpacity * (BG_COLOR.r - COLOR.r);
		COLOR.g += bgOpacity * (BG_COLOR.g - COLOR.g);
		COLOR.b += bgOpacity * (BG_COLOR.b - COLOR.b);
		COLOR.a = 1.0;
	} else {
		COLOR.a = 0.0;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
