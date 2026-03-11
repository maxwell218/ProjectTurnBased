//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec3  u_col_bright;
uniform vec3  u_col_dark;
uniform float u_fill;
uniform float u_bar_x;
uniform float u_bar_width;
uniform float u_scale;

void main() {

    // Convert display pixel → game pixel
    float game_x = floor((gl_FragCoord.x - floor(u_bar_x * u_scale)) / u_scale);

    // Discard based on game pixel position
	// We use ceil to make sure the fill is still visible if we have more than 0
    if (game_x >= ceil(u_bar_width * u_fill)) {
        gl_FragColor = vec4(0.0);
        return;
    }

    // Alternating pattern
    bool is_bright = mod(game_x, 2.0) < 1.0;
    vec3 col = is_bright ? u_col_bright : u_col_dark;
    gl_FragColor = v_vColour * vec4(col, 1.0);
}
