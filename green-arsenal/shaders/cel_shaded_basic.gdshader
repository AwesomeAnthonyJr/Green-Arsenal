//shader by Anthony D. Salsbury; looks best without any ambient lighting!

shader_type spatial;
render_mode diffuse_lambert;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_nearest, repeat_enable;
uniform vec4 albedo_in_shadow : source_color;
uniform sampler2D texture_albedo_in_shadow : source_color, filter_nearest, repeat_enable;
uniform float shadow_threshold : hint_range(0.0, 1.0, 0.01) = 0.50;
uniform float specular_threshold : hint_range(0.0, 1.0, 0.01) = 0.80;
uniform float specular_strength : hint_range(0.0, 10.0, 0.1) = 1.0;

uniform vec2 uv1_scale;
uniform vec2 uv1_offset;

varying vec3 lit_color;
varying vec3 shadow_color;
varying vec3 light_result;

void vertex() {
	UV = UV * uv1_scale + uv1_offset;
}



void fragment() {
	lit_color = texture(texture_albedo, UV).rgb * albedo.rgb;
	shadow_color = texture(texture_albedo_in_shadow, UV).rgb * albedo_in_shadow.rgb;
}

void light() {
	float dot_prod = max(dot(NORMAL, LIGHT), 0.0);
	if (dot_prod <= shadow_threshold){
		if (DIFFUSE_LIGHT == lit_color) {
			DIFFUSE_LIGHT = lit_color;
		} else {
			DIFFUSE_LIGHT = shadow_color;
		}
	} else {
		DIFFUSE_LIGHT = lit_color;
	}
	//specular
	vec3 H = normalize(LIGHT + VIEW);
	float spec = pow(max(dot(NORMAL, H), 0.0), 8.0);
	spec = step(specular_threshold, spec);
	if (DIFFUSE_LIGHT == lit_color){
		if (SPECULAR_LIGHT == vec3(0.0, 0.0, 0.0)){ 
			SPECULAR_LIGHT = spec * lit_color * specular_strength;
		}
	}
}