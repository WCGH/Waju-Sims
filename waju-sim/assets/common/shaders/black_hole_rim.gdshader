// Outer Sphere shader for Omen's Smoke Bomb
// Recreation by NekotoArts (CC0 license)

shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D smoke_texture;

uniform vec4 color : source_color = vec4( 1.0, 0.75, 0.3, 1.0 );
uniform float fade_size = 0.016;
uniform float fade_blend = 0.364;
uniform float smoke_sharpness = 0.869;
uniform float time_scale = 0.2;
uniform float height_fade = 3.4;
uniform float scissor = 0.457;

//const float PI = 3.1415;

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void fragment(){
	// Smoke Texture
	vec2 smoke_uv = UV - TIME * time_scale;
	vec4 smoke_color = texture(smoke_texture, smoke_uv);
	float smoke_buffer = smoothstep(0.0, smoke_sharpness, smoke_color.r);
	
	// Coloring
	ALBEDO = mix(vec3(0.0), color.rgb, smoke_buffer);
	
	// Fresnel Fade
	float fres = fresnel(2.0, NORMAL, VIEW);
	fres = smoothstep(fade_size, fade_size + fade_blend, fres);
	
	ALPHA = smoke_buffer;
	ALPHA *= clamp(sin(UV.y * PI) * height_fade - (height_fade / 2.0), 0.0, 1.0);
	ALPHA *= fres;
	//ALPHA_SCISSOR = scissor;
}
