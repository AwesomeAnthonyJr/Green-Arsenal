//shader by Anthony D. Salsbury; looks best without any ambient lighting!
//loosely followed along a tutorial to make it water

shader_type spatial;
render_mode diffuse_lambert;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_nearest, repeat_enable;
uniform vec4 albedo_in_shadow : source_color;
uniform sampler2D texture_albedo_in_shadow : source_color, filter_nearest, repeat_enable;
uniform sampler2D depth_texture : hint_depth_texture;
uniform sampler2D screen_texture : hint_screen_texture;
uniform float shadow_threshold : hint_range(0.0, 1.0, 0.01) = 0.50;
uniform float specular_threshold : hint_range(0.0, 1.0, 0.01) = 0.80;
uniform float specular_strength : hint_range(0.0, 10.0, 0.1) = 1.0;
uniform float fresnel_amount : hint_range(0.0, 10.0, 0.1) = 2.0;
uniform float fresnel_strength : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform sampler2D wave;
uniform float noise_scale = 10.0;
uniform float height_scale = 0.15;
uniform float edge_scale = 0.1;
uniform float edge_near = 1.0;
uniform float edge_far = 100.0;

varying float height;
varying vec3 world_position;


uniform vec2 uv1_scale;
uniform vec2 uv1_offset;

varying vec3 lit_color;
varying vec3 shadow_color;
varying vec3 light_result;

void vertex() {
	UV = UV * uv1_scale + uv1_offset;
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	height = texture(wave, world_position.xz / noise_scale + TIME * 0.1).r;
	VERTEX.y += height * height_scale;
}

float edge(float depth){
	depth = 1.0 - 2.0 * depth;
	return edge_near * edge_far / (edge_far + depth * (edge_near - edge_far));
}

//this function from godot shaders dot com
float fresnel(float amount, vec3 normal, vec3 view){
	return pow((1.0 - clamp(dot(normal, view), 0.0, 1.0 )), amount);
}

void fragment() {
	lit_color = texture(texture_albedo, UV).rgb * albedo.rgb;
	shadow_color = texture(texture_albedo_in_shadow, UV).rgb * albedo_in_shadow.rgb;		
	ALBEDO = vec3(1.0);
	ALPHA = 0.7;
}

vec3 diffuse_calc(vec3 color, vec3 fresnel, float edge_amount) {
	return mix(vec3(1.0, 1.0, 1.0), color + fresnel, edge_amount);
}

void light() {
	// edge depth stuff
	float z_depth = edge(texture(depth_texture, SCREEN_UV).x);
	float z_pos = edge(FRAGCOORD.z);
	float z_dif = z_depth - z_pos;
	float edge_amount = step(edge_scale, z_dif);
	//fresnel
	float fres = fresnel(fresnel_amount, NORMAL, VIEW);
	fres = step(0.5, fres);
	vec3 fres2 = vec3(1.0, 1.0, 1.0) * fresnel_strength * fres;
	//cel
	//trying water depth stuff, not really working
	//vec3 mixed_color = mix(lit_color, texture(screen_texture, SCREEN_UV).rgb, texture(depth_texture, SCREEN_UV).x * 50.0);
	//vec3 mixed_color2 = mix(shadow_color, texture(screen_texture, SCREEN_UV).rgb, texture(depth_texture, SCREEN_UV).x * 50.0);
	float dot_prod = max(dot(NORMAL, LIGHT) * ATTENUATION * length(LIGHT_COLOR), 0.0);
	if (dot_prod <= shadow_threshold){
		if (DIFFUSE_LIGHT == diffuse_calc(lit_color, fres2, edge_amount)) {
			DIFFUSE_LIGHT = diffuse_calc(lit_color, fres2, edge_amount);
		} else {
			DIFFUSE_LIGHT = diffuse_calc(shadow_color, fres2, edge_amount);
		}
	} else {
		DIFFUSE_LIGHT = diffuse_calc(lit_color, fres2, edge_amount);
	}
	//specular
	vec3 H = normalize(LIGHT + VIEW);
	float spec = pow(max(dot(NORMAL, H), 0.0), 8.0);
	spec = step(specular_threshold, spec);
	if (DIFFUSE_LIGHT == diffuse_calc(lit_color, fres2, edge_amount)){
		if (SPECULAR_LIGHT == vec3(0.0, 0.0, 0.0)){ 
			SPECULAR_LIGHT = spec * vec3(1.0, 1.0, 1.0) * specular_strength;
		}
	}
}