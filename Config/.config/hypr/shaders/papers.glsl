#version 300 es
precision highp float;

in vec2 v_texcoord;
out vec4 fragColor;

uniform sampler2D tex;

// === Configurable Parameters ===
// You can either modify these values directly,
// or turn them into uniforms for dynamic control.
const float u_Grayscale  = 1.0;  // 0.0 = none, 1.0 = full grayscale
const float u_Contrast   = 1.1;  // Contrast multiplier
const float u_Brightness = 0.0;  // Brightness offset
const float u_Sepia      = 0.0;  // 0.0 = no sepia, 1.0 = full sepia
const float u_Grain      = 0.7;  // Strength of paper grain

// === Grain noise function ===
// Cheap pseudo-random grain using UV hashing
float paper_grain(vec2 uv) {
    float grain = fract(sin(dot(uv * 800.0, vec2(12.9898, 78.233))) * 43758.5453);
    return grain * 0.12 - 0.06; // Range: [-0.06, +0.06]
}

// === Convert RGB to sepia tone ===
vec3 to_sepia(vec3 color) {
    float r = dot(color, vec3(0.393, 0.769, 0.189));
    float g = dot(color, vec3(0.349, 0.686, 0.168));
    float b = dot(color, vec3(0.272, 0.534, 0.131));
    return vec3(r, g, b);
}

void main() {
    vec4 pixColor = texture(tex, v_texcoord);

    // Grayscale conversion (luminance method)
    float gray = dot(pixColor.rgb, vec3(0.299, 0.587, 0.114));
    vec3 colorResult;

    // Vibrance or grayscale blending
    if (u_Grayscale < 0.0) {
        float vibrance = -u_Grayscale;
        float avg = (pixColor.r + pixColor.g + pixColor.b) / 3.0;
        colorResult = pixColor.rgb + (pixColor.rgb - vec3(avg)) * vibrance;
        colorResult = clamp(colorResult, 0.0, 1.0);
    } else {
        colorResult = mix(pixColor.rgb, vec3(gray), u_Grayscale);
    }

    // Contrast and brightness
    colorResult = colorResult * u_Contrast + u_Brightness;
    colorResult = clamp(colorResult, 0.0, 1.0);

    // Sepia tone blending
    colorResult = mix(colorResult, to_sepia(colorResult), u_Sepia);

    // Add paper grain
    float grain = paper_grain(v_texcoord);
    colorResult = clamp(colorResult + grain * u_Grain, 0.0, 1.0);

    // Optional highlight clipping (to soften whites)
    colorResult = min(colorResult, vec3(0.88));

    fragColor = vec4(colorResult, pixColor.a);
}
