#version 300 es
precision highp float;

in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;

const float u_HueShift = 0.2; // Ranges 0.0 to 1.0

vec3 hueShift(vec3 color, float shift) {
    const mat3 toYIQ = mat3(0.299, 0.587, 0.114,
                            0.596, -0.275, -0.321,
                            0.212, -0.523, 0.311);
    const mat3 toRGB = mat3(1.0, 0.956, 0.621,
                            1.0, -0.272, -0.647,
                            1.0, -1.107, 1.705);
    vec3 yiq = toYIQ * color;
    float angle = shift * 6.2831853;
    float cosA = cos(angle);
    float sinA = sin(angle);
    mat3 rot = mat3(1.0, 0.0, 0.0,
                    0.0, cosA, -sinA,
                    0.0, sinA, cosA);
    yiq = rot * yiq;
    return clamp(toRGB * yiq, 0.0, 1.0);
}

void main() {
    vec4 color = texture(tex, v_texcoord);
    color.rgb = hueShift(color.rgb, u_HueShift);
    fragColor = color;
}
