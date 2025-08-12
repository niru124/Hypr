#version 300 es
precision highp float;

in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;

const float u_FadeAmount = 0.5; // 0.0 = full fade (black), 1.0 = full image

void main() {
    vec4 color = texture(tex, v_texcoord);
    color.rgb *= u_FadeAmount;
    fragColor = color;
}
