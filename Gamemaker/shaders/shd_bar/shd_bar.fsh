//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying float v_local_x;

uniform vec3  u_col_bright;
uniform vec3  u_col_dark;
uniform float u_fill;
uniform float u_bar_width;

void main() {

    float frag_x = floor(v_local_x);

    if (frag_x >= ceil(u_bar_width * u_fill)) {
        gl_FragColor = vec4(0.0);
        return;
    }

    bool is_bright = mod(frag_x, 2.0) < 1.0;

    vec3 col = is_bright ? u_col_bright : u_col_dark;

    gl_FragColor = v_vColour * vec4(col, 1.0);
}
