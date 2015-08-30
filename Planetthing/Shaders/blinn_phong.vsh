attribute vec3 positionCoord;
attribute vec2 textureCoord;
attribute vec3 normalCoord;

uniform mat4 modelViewProjectionMatrix;
uniform vec2 materialTextureCompression;

varying vec3 finalPositionCoord;
varying vec2 finalTextureCoord;
varying vec3 finalNormalCoord;

varying vec3 finalPositionLightSpaceCoord[8];

uniform mat4 lightModelViewProjectionMatrices[8];
uniform int numberOfLights;

void main()
{
    gl_Position = modelViewProjectionMatrix * vec4(positionCoord, 1.0);
    finalPositionCoord = positionCoord;
    finalTextureCoord = textureCoord * materialTextureCompression;
    finalNormalCoord = normalCoord;
    
    // Calculate the light space position of this vertex.
    for(int i = 0; i < numberOfLights; i++)
    {
        vec4 lightPosCoord = lightModelViewProjectionMatrices[i] * vec4(positionCoord, 1.0);
        
        // perform perspective divide.
        finalPositionLightSpaceCoord[i] = lightPosCoord.xyz / lightPosCoord.w;
        
        // Transform to [0,1] range.
        finalPositionLightSpaceCoord[i] = finalPositionLightSpaceCoord[i] * 0.5 + 0.5;
    }
    
}
