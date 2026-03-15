//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying float v_local_x;

uniform float u_bar_x;

void main()
{
    vec4 pos = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1.0);

    v_vTexcoord = in_TextureCoord;
    v_vColour = in_Colour;

    v_local_x = in_Position.x - u_bar_x;

    gl_Position = pos;
}
