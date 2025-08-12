#version 300 es
precision highp float;

in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;

// Grayscale method constants
const int GRAYSCALE_LUMINOSITY = 0;
const int GRAYSCALE_LIGHTNESS  = 1;
const int GRAYSCALE_AVERAGE    = 2;

// Luma encoding types
const int LUMA_PAL  = 0;
const int LUMA_HDT  = 1;
const int LUMA_HDR  = 2;

// === CONFIGURATION ===
// You can change these two constants to select the behavior:
const int GRAYSCALE_TYPE = GRAYSCALE_LUMINOSITY; // Change to LIGHTNESS or AVERAGE
const int LUMINOSITY_TYPE = LUMA_HDT;            // Change to LUMA_PAL or LUMA_HDR

void main() {
    vec4 pixColor = texture(tex, v_texcoord);
    float gray;

    if (GRAYSCALE_TYPE == GRAYSCALE_LUMINOSITY) {
        if (LUMINOSITY_TYPE == LUMA_PAL) {
            gray = dot(pixColor.rgb, vec3(0.299, 0.587, 0.114));
        } else if (LUMINOSITY_TYPE == LUMA_HDT) {
            gray = dot(pixColor.rgb, vec3(0.2126, 0.7152, 0.0722));
        } else if (LUMINOSITY_TYPE == LUMA_HDR) {
            gray = dot(pixColor.rgb, vec3(0.2627, 0.6780, 0.0593));
        }
    } else if (GRAYSCALE_TYPE == GRAYSCALE_LIGHTNESS) {
        float maxC = max(pixColor.r, max(pixColor.g, pixColor.b));
        float minC = min(pixColor.r, min(pixColor.g, pixColor.b));
        gray = (maxC + minC) / 2.0;
    } else if (GRAYSCALE_TYPE == GRAYSCALE_AVERAGE) {
        gray = (pixColor.r + pixColor.g + pixColor.b) / 3.0;
    }

    fragColor = vec4(vec3(gray), pixColor.a);
}

