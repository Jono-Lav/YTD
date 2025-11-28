shader_type canvas_item;

// Uniforms to control the crosshair
uniform float pixel_width = 2.0;        // Thickness of the crosshair lines in pixels
uniform float arm_length_pixels = 20.0; // Length of each crosshair arm in pixels
uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
    // Compute half line widths for thickness (since abs() covers both sides from center)
    float half_line_width_x = (pixel_width / 2.0) * SCREEN_PIXEL_SIZE.x;
    float half_line_width_y = (pixel_width / 2.0) * SCREEN_PIXEL_SIZE.y;

    // Compute arm lengths in UV space
    float arm_length_uv_x = arm_length_pixels * SCREEN_PIXEL_SIZE.x;
    float arm_length_uv_y = arm_length_pixels * SCREEN_PIXEL_SIZE.y;

    // Define the screen center
    vec2 center = vec2(0.5, 0.5);

    // Condition for the horizontal line
    bool is_horizontal = abs(SCREEN_UV.y - center.y) < half_line_width_y &&
                         abs(SCREEN_UV.x - center.x) < arm_length_uv_x;

    // Condition for the vertical line
    bool is_vertical = abs(SCREEN_UV.x - center.x) < half_line_width_x &&
                       abs(SCREEN_UV.y - center.y) < arm_length_uv_y;

    // Combine to determine if the pixel is part of the crosshair
    bool is_crosshair = is_horizontal || is_vertical;

    // Apply color logic
    if (is_crosshair) {
        // Get the screen color at this pixel
        vec3 screen_color = texture(screen_texture, SCREEN_UV).rgb;
        // Invert the color for visibility
        vec3 inverted_color = vec3(1.0) - screen_color;
        COLOR = vec4(inverted_color, 1.0);
    } else {
        // Transparent outside the crosshair
        COLOR = vec4(0.0);
    }
}