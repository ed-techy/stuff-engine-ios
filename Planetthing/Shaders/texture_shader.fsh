uniform sampler2D textureSampler;
uniform lowp float opasityCompound;

varying lowp vec2 finalTextureCoord;

void main()
{
    gl_FragColor = texture2D(textureSampler, finalTextureCoord);
    gl_FragColor.a *= opasityCompound;
}
