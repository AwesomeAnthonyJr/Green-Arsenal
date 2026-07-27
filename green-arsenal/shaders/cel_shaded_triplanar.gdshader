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

uniform float texture_scale = 1.0;
uniform bool rotated = false;

varying vec3 lit_color;
varying vec3 shadow_color;
varying vec3 light_result;

varying vec3 world_position;
varying vec3 world_normal;

vec4 triplanar(sampler2D tex, vec3 world_pos, vec3 world_norm) {
	vec3 blending = abs(world_normal);
	blending = pow(blending, vec3(4.0));
	blending /= blending.x + blending.y + blending.z;
	
	vec2 uv_x = world_pos.yz / texture_scale;
	vec2 uv_y = world_pos.xz / texture_scale;
	vec2 uv_z = world_pos.xy / texture_scale;
	
	if (rotated){
		uv_x = vec2(uv_x.y, -uv_x.x);
	}
	
	vec4 x = texture(tex, uv_x);
	vec4 y = texture(tex, uv_y);
	vec4 z = texture(tex, uv_z);
	
	return x * blending.x + y * blending.y + z * blending.z;
}


//this function from godot shaders dot com
float fresnel(float amount, vec3 normal, vec3 view){
	return pow((1.0 - clamp(dot(normal, view), 0.0, 1.0 )), amount);
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	if (FRONT_FACING){
		lit_color = triplanar(texture_albedo, world_position, world_normal).rgb * albedo.rgb;
		shadow_color = triplanar(texture_albedo_in_shadow, world_position, world_normal).rgb * albedo_in_shadow.rgb;		
		//ALPHA = 1.0;
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
	bool in_shadow = false;
	if (dot_prod <= shadow_threshold){
		if (DIFFUSE_LIGHT == diffuse_calc(lit_color, fres2)) {
			DIFFUSE_LIGHT = diffuse_calc(lit_color, fres2);
		} else {
			DIFFUSE_LIGHT = diffuse_calc(shadow_color, fres2);
			in_shadow = true;
		}
	} else {
		DIFFUSE_LIGHT = diffuse_calc(lit_color, fres2);
	}
	//specular
	vec3 H = normalize(LIGHT + VIEW);
	float spec = pow(max(dot(NORMAL, H), 0.0), 8.0);
	spec = step(specular_threshold, spec);
	if (!in_shadow){
		if (SPECULAR_LIGHT == vec3(0.0, 0.0, 0.0)){ 
			SPECULAR_LIGHT = spec * lit_color * specular_strength;
		}
	}
}