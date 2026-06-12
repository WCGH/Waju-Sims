shader_type spatial;
render_mode depth_draw_opaque, unshaded, shadows_disabled;

uniform sampler2D noise_tex;
uniform vec4 root_color : source_color = vec4( 1.0, 0.75, 0.3, 1.0 );
uniform vec4 tip_color : source_color = vec4( 1.0, 0.03, 0.001, 1.0 );

uniform float fire_alpha : hint_range( 0.0, 1.0 ) = 1.0;
uniform vec2 fire_speed = vec2( 0.0, 1.0 );
uniform float fire_aperture : hint_range( 0.0, 3.0 ) = 0.22;

void fragment( )
{
	vec2 shifted_uv = UV + TIME * fire_speed;
	float fire_noise = texture( noise_tex, shifted_uv ).r;
	float noise = UV.y * ( ( ( UV.y + fire_aperture ) * fire_noise - fire_aperture ) * 75.0 );
	vec4 fire_color = mix( tip_color, root_color, noise * 0.05 );

	ALPHA = clamp( noise, 0.9, 1.0 ) * fire_alpha;
	ALBEDO = fire_color.rgb;
}