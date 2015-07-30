attribute vec3 positionCoord;
attribute vec2 textureCoord;

varying vec2 finalTextureCoord;

void main()
{
    gl_Position = vec4(positionCoord, 1.0);
    finalTextureCoord = textureCoord;
}