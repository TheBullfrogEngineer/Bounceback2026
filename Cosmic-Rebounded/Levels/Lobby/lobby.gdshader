shader_type canvas_item;

uniform float SPEED = 1.5;

void vertex() {
	UV.x += TIME * SPEED;
	UV.y += TIME * SPEED;
	}
