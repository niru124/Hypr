#version 300 es
precision highp float;

in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;
uniform vec2 resolution;

void main() {
    vec2 texel = 1.0 / resolution;
    vec3 result = vec3(0.0);

    for (int x = -1; x <= 1; ++x) {
        for (int y = -1; y <= 1; ++y) {
            vec2 offset = vec2(float(x), float(y)) * texel;
            result += texture(tex, v_texcoord + offset).rgb;
        }
    }

    result /= 9.0;
    fragColor = vec4(result, 1.0);
}
