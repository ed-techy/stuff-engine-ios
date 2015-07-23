uniform sampler2D textureSampler;

varying lowp vec2 finalTextureCoord;

void main()
{
    gl_FragColor = texture2D(textureSampler, finalTextureCoord);
}