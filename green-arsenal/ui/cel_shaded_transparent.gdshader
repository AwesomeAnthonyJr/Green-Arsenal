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
uniform float fresnel_amount : hint_range(0.0, 10.0, 0.1) = 2.0;
uniform float fresnel_strength : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float transparency : hint_range(0.0, 1.0, 0.01) = 1.0;

uniform vec2 uv1_scale;
uniform vec2 uv1_offset;

varying vec3 lit_color;
varying vec3 shadow_color;
varying vec3 light_result;

void vertex() {
	UV = UV * uv1_scale + uv1_offset;
}


//this function from godot shaders dot com
float fresnel(float amount, vec3 normal, vec3 view){
	return pow((1.0 - clamp(dot(normal, view), 0.0, 1.0 )), amount);
}

void fragment() {
	if (FRONT_FACING){
		lit_color = texture(texture_albedo, UV).rgb * albedo.rgb;
		shadow_color = texture(texture_albedo_in_shadow, UV).rgb * albedo_in_shadow.rgb;		
		ALPHA = transparency;
		ALBEDO = vec3(1.0);
	}
}

vec3 diffuse_calc(vec3 color, vec3 fresnel) {
	return (color - fresnel);
}

void light() {
	//fresnel
	float fres = fresnel(fresnel_amount, NORMAL, VIEW);
	fres = step(0.5, fres);
	vec3 fres2 = vec3(1.0, 1.0, 1.0) * fresnel_strength * fres;
	//cel
	float dot_prod = max(dot(NORMAL, LIGHT) * ATTENUATION * length(LIGHT_COLOR), 0.0) ;
	if (dot_prod <= shadow_threshold){
		if (DIFFUSE_LIGHT == diffuse_calc(lit_color, fres2)) {
			DIFFUSE_LIGHT = diffuse_calc(lit_color, fres2);
		} else {
			DIFFUSE_LIGHT = diffuse_calc(shadow_color, fres2);
		}
	} else {
		DIFFUSE_LIGHT = diffuse_calc(lit_color, fres2);
	}
	//specular
	vec3 H = normalize(LIGHT + VIEW);
	float spec = pow(max(dot(NORMAL, H), 0.0), 8.0);
	spec = step(specular_threshold, spec);
	if (DIFFUSE_LIGHT == diffuse_calc(lit_color, fres2)){
		if (SPECULAR_LIGHT == vec3(0.0, 0.0, 0.0)){ 
			SPECULAR_LIGHT = spec * lit_color * specular_strength;
		}
	}
}