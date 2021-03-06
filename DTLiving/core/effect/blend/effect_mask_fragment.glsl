varying highp vec2 v_texcoord;
varying highp vec2 v_texcoord2;

uniform sampler2D u_texture;
uniform sampler2D u_texture2;

uniform lowp vec4 u_color;

void main() {
    lowp vec4 base = texture2D(u_texture, v_texcoord);
    lowp vec4 overlay = texture2D(u_texture2, v_texcoord2);
    
    if (overlay.a < 1.0) {
        gl_FragColor = u_color;
    } else {
        gl_FragColor = base;
    }
}
