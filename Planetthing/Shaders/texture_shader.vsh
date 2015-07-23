attribute vec4 positionCoord;
attribute vec2 textureCoord;

uniform mat4 modelViewProjectionMatrix;
uniform vec2 textureCompression;

varying vec2 finalTextureCoord;

void main()
{
    gl_Position = modelViewProjectionMatrix * positionCoord;
    finalTextureCoord = textureCoord * textureCompression;
}
