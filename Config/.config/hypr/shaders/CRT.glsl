#version 300 es
precision highp float;

in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;

void main() {
    vec4 color = texture(tex, v_texcoord);

    // Horizontal scanlines
    float scanline = sin(v_texcoord.y * 600.0) * 0.04;
    color.rgb -= scanline;

    fragColor = color;
}
