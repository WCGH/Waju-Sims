shader_type spatial;
 
render_mode unshaded, cull_front;

uniform float border_width : hint_range(0,1,0.001);
uniform vec4 color : source_color = vec4(1.0);
 
uniform bool pattern;
uniform float line_number : hint_range(0,100,1);
uniform float line_sharpness : hint_range(0,10,0.001);
 
uniform bool pulse;
uniform float pulse_speed : hint_range(0,100,1);
 
uniform bool line_movement;
uniform float line_movement_speed : hint_range(-100,100,1);
 
uniform bool wave;
 
void vertex() {
	VERTEX += VERTEX * border_width;
}
 
void fragment() {
	ALBEDO = color.xyz;
	if (pattern) 
	{
		vec2 uv = VERTEX.xy * line_number;
		ALBEDO = sin(uv.xxx + uv.yyy) * line_sharpness * color.xyz;
 
		if (pulse)
		{
			ALBEDO = sin(uv.xxx + uv.yyy) * line_sharpness * color.xyz * sin(TIME * pulse_speed);
		}
 
		if (line_movement)
		{
			ALBEDO = sin(uv.xxx + uv.yyy + TIME * line_movement_speed) * line_sharpness * color.xyz;
		}
 
		if (pulse && line_movement)
		{
			ALBEDO = sin(uv.xxx + uv.yyy + TIME * line_movement_speed) * line_sharpness * color.xyz * sin(TIME * pulse_speed);
		}
		
		//float size = 10 * 1.0 / float(textureSize(, 0).x)
	}
 
	if (wave)
	{
		vec2 uv = VERTEX.xy * line_number;
		ALBEDO = sin(uv.xxx + TIME * line_movement_speed) * line_sharpness * color.xyz;
	}
 
}