shader_type spatial;
render_mode diffuse_lambert, specular_disabled;

// World-space 1 m grid over a cool deck base. World XZ keeps the cells square
// on every box regardless of its UVs, so one material serves deck + ledge.
uniform vec4 base_color : source_color = vec4(0.20, 0.25, 0.33, 1.0);
uniform vec4 line_color : source_color = vec4(0.04, 0.06, 0.10, 1.0);
uniform vec4 sheen_color : source_color = vec4(0.10, 0.35, 0.45, 1.0);
uniform float cell_meters = 1.0;
uniform float line_width = 0.025;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 g = abs(fract(world_pos.xz / cell_meters) - 0.5);
	float line = 1.0 - smoothstep(line_width, line_width * 2.0, min(g.x, g.y) * cell_meters);
	vec3 col = mix(base_color.rgb, line_color.rgb, line);
	EMISSION = sheen_color.rgb * line * 0.35;
	ALBEDO = col;
	ROUGHNESS = 0.9;
}
