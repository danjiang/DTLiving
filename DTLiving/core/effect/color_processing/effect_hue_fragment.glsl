varying highp vec2 v_texcoord;

uniform sampler2D u_texture;
uniform mediump float u_hueAdjust;

const highp vec4 kRGBToYPrime = vec4(0.299, 0.587, 0.114, 0.0);
const highp vec4 kRGBToI = vec4(0.595716, -0.274453, -0.321263, 0.0);
const highp vec4 kRGBToQ = vec4(0.211456, -0.522591, 0.31135, 0.0);

const highp vec4 kYIQToR = vec4(1.0, 0.9563, 0.6210, 0.0);
const highp vec4 kYIQToG = vec4(1.0, -0.2721, -0.6474, 0.0);
const highp vec4 kYIQToB = vec4(1.0, -1.1070, 1.7046, 0.0);

void main() {
    highp vec4 color = texture2D(u_texture, v_texcoord);
    
    highp float YPrime = dot(color, kRGBToYPrime);
    highp float I = dot(color, kRGBToI);
    highp float Q = dot(color, kRGBToQ);

    highp float hue = atan(Q, I);
    highp float chroma = sqrt(I * I + Q * Q);

    hue += (-u_hueAdjust);

    Q = chroma * sin(hue);
    I = chroma * cos(hue);
    
    highp vec4 yIQ = vec4(YPrime, I, Q, 0.0);
    color.r = dot(yIQ, kYIQToR);
    color.g = dot(yIQ, kYIQToG);
    color.b = dot(yIQ, kYIQToB);

    gl_FragColor = color;
}
