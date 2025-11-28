shader_type spatial;

uniform sampler2D texture_hatch_1 : filter_linear;

void vertex() {
    // No changes needed here
}

void fragment() {
    float rotation_speed = 1.0 + sin(TIME * 0.1) * 0.5; // Adds slight randomness

    vec4 h1 = texture(texture_hatch_1, vec2(
        cos(TIME * rotation_speed) + sin(VERTEX.x * 10.0),
        sin(TIME * rotation_speed) + cos(VERTEX.y * 10.0)
    ) * 0.5);

    h1 *= h1 * h1 * h1;

    vec3 xnm = NORMAL;
    vec3 col = vec3(xnm.x + xnm.y + xnm.z) / 3.0;
    col.rgb *= 2.1;
    col.rgb *= (floor(6.0 * col.rgb) * 4.0) / 9.0;

    ALBEDO.rgb = h1.rgb * col;
}

void light() {
    DIFFUSE_LIGHT = vec3(0.5);
    DIFFUSE_LIGHT = vec3(floor(6.f * DIFFUSE_LIGHT) * 4.f) / 9.f;
}
