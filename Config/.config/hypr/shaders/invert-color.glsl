#version 300 es
precision highp float;

in vec2 v_texcoord;
out vec4 fragColor;

uniform sampler2D tex;

// === Configurable Parameters ===
// Change this value to control how much the colors are inverted.
// 0.0 = No effect, 1.0 = Full inversion.
const float u_InvertIntensity = 1.0;

void main() {
    vec4 pixColor = texture(tex, v_texcoord);

    // Mix between original and inverted color based on intensity
    vec3 invertedColor = mix(pixColor.rgb, 1.0 - pixColor.rgb, u_InvertIntensity);

    fragColor = vec4(invertedColor, pixColor.a);
}
