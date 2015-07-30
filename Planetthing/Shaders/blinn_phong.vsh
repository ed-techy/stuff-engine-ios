attribute vec3 positionCoord;
attribute vec2 textureCoord;
attribute vec3 normalCoord;

uniform mat4 modelViewProjectionMatrix;
uniform vec2 textureCompression;

varying vec3 finalPositionCoord;
varying vec2 finalTextureCoord;
varying vec3 finalNormalCoord;

void main()
{
    gl_Position = modelViewProjectionMatrix * vec4(positionCoord, 1.0);
    finalPositionCoord = positionCoord;
    finalTextureCoord = textureCoord * textureCompression;
    finalNormalCoord = normalCoord;
}
