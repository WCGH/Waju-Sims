shader_type sky;



uniform float time_scale : hint_range(0.0, 2.0) = 0.5;

uniform vec3 base_color : source_color = vec3(0.05, 0.05, 0.08);

uniform vec3 slime_color : source_color = vec3(0.15, 0.15, 0.2);

uniform vec3 highlight_color : source_color = vec3(0.3, 0.35, 0.4);

uniform float tendril_density : hint_range(0.0, 10.0) = 4.0;

uniform float tendril_thickness : hint_range(0.0, 1.0) = 0.3;

uniform float animation_speed : hint_range(0.0, 5.0) = 1.0;

uniform float slime_wetness : hint_range(0.0, 5.0) = 0.7;



// Noise function for organic movement

float noise(vec3 p) {

    vec3 i = floor(p);

    vec3 f = fract(p);

    f = f * f * (3.0 - 2.0 * f);



    float n = i.x + i.y * 57.0 + i.z * 113.0;

    return mix(

        mix(mix(fract(sin(n) * 43758.5453),

                fract(sin(n + 1.0) * 43758.5453), f.x),

            mix(fract(sin(n + 57.0) * 43758.5453),

                fract(sin(n + 58.0) * 43758.5453), f.x), f.y),

        mix(mix(fract(sin(n + 113.0) * 43758.5453),

                fract(sin(n + 114.0) * 43758.5453), f.x),

            mix(fract(sin(n + 170.0) * 43758.5453),

                fract(sin(n + 171.0) * 43758.5453), f.x), f.y), f.z);

}



// Fractal Brownian Motion for complex patterns

float fbm(vec3 p) {

    float value = 0.0;

    float amplitude = 0.5;

    float frequency = 1.0;



    for (int i = 0; i < 5; i++) {

        value += amplitude * noise(p * frequency);

        frequency *= 2.0;

        amplitude *= 0.5;

    }

    return value;

}




float tendrils(vec3 dir, float time) {

    vec3 p = dir * tendril_density;

    p += vec3(time * animation_speed * 0.2, time * animation_speed * 0.15, time * animation_speed * 0.1);



    float pattern = fbm(p);

    pattern += fbm(p * 2.0 + vec3(time * animation_speed * 0.3)) * 0.5;

    pattern += fbm(p * 4.0 - vec3(time * animation_speed * 0.2)) * 0.25;



    // Create sharp tendril edges

    float tendrils = smoothstep(0.4 - tendril_thickness, 0.4, pattern);

    tendrils *= smoothstep(0.4 + tendril_thickness * 2.0, 0.4 + tendril_thickness, pattern);



    return tendrils;

}




float slime_highlight(vec3 dir, float time) {

    vec3 p = dir * 3.0;

    p += vec3(sin(time * animation_speed * 0.5) * 0.5,

              cos(time * animation_speed * 0.3) * 0.5,

              sin(time * animation_speed * 0.4) * 0.5);



    float highlight = noise(p * 2.0);

    highlight = pow(highlight, 3.0);

    return highlight * slime_wetness;

}




float veins(vec3 dir, float time) {

    vec3 p = dir * 8.0;

    float pulse = sin(time * animation_speed * 2.0) * 0.5 + 0.5;



    float v = abs(sin(p.x * 3.0 + time * animation_speed) *

                  sin(p.y * 3.0 - time * animation_speed * 0.7) *

                  sin(p.z * 3.0 + time * animation_speed * 0.5));

    v = smoothstep(0.8, 0.9, v) * pulse;



    return v;

}



void sky() {

    vec3 dir = normalize(EYEDIR);

    float time = TIME * time_scale;



    // Base slimy black color

    vec3 color = base_color;



    // Add tendril patterns

    float tendril_pattern = tendrils(dir, time);

    color = mix(color, slime_color, tendril_pattern);



    // Add glossy slime highlights

    float highlight = slime_highlight(dir, time);

    color = mix(color, highlight_color, highlight);



    // Add some depth variation based on view angle

    float edge_darkness = pow(1.0 - abs(dir.y), 2.0);

    color *= 1.0 + edge_darkness * 0.3;



    // Add subtle animated distortion at edges

    float edge_distortion = fbm(dir * 5.0 + vec3(time * animation_speed * 0.1));

    edge_distortion *= edge_darkness;

    color += edge_distortion * 0.05;



    COLOR = color;

}