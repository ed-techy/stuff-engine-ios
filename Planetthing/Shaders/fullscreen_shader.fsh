uniform sampler2D textureSampler;

varying lowp vec2 finalTextureCoord;

void main()
{
    gl_FragColor = vec4(1.0, 1.0, 1.0, texture2D(textureSampler, finalTextureCoord).a);
}