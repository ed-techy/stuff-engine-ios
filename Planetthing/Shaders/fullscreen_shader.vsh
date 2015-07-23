attribute vec4 positionCoord;
attribute vec2 textureCoord;

varying vec2 finalTextureCoord;

void main()
{
    gl_Position = positionCoord;
    finalTextureCoord = textureCoord;
}