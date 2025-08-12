#version 300 es
precision highp float;

in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;

void main() {
    vec4 color = texture(tex, v_texcoord);
    float dist = distance(v_texcoord, vec2(0.5));
    float vignette = smoothstep(0.6, 0.9, dist);
    color.rgb *= 1.0 - vignette * 0.5;
    fragColor = color;
}
