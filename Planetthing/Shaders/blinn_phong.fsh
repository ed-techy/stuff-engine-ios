varying highp vec3 finalPositionCoord;
varying highp vec2 finalTextureCoord;
varying highp vec3 finalNormalCoord;

uniform sampler2D materialDiffuceMapSampler;
uniform bool materialDiffuceMapEnabled;
uniform sampler2D materialSpecularMapSampler;
uniform bool materialSpecularMapEnabled;
uniform highp vec3 materialDiffuceColor;
uniform highp vec3 materialAmbientColor;
uniform highp vec3 materialSpecularColor;
uniform highp float materialShininess;
uniform highp float materialOpasity;

struct Light
{
    int type;
    highp vec3 position;
    highp vec3 direction;
    highp float cutOff;
    highp vec3 diffuseColor;
    highp vec3 ambientColor;
    highp vec3 specularColor;
    highp float intensity;
};

uniform Light lights[10];
uniform int numberOfLights;

highp vec3 pointLight(int lightIndex, highp vec3 surficeColor)
{
    // Light color.
    surficeColor *= lights[lightIndex].diffuseColor * lights[lightIndex].intensity;
    
    // Ambient color from surfice and material.
    highp vec3 ambient = materialAmbientColor * surficeColor * lights[lightIndex].ambientColor * lights[lightIndex].intensity;
    
    // Diffuse color base light position (how much the surfice is facing the light).
    highp vec3 lightDir = normalize(lights[lightIndex].position - finalPositionCoord);
    highp vec3 normal = normalize(finalNormalCoord);
    highp float diff = max(dot(lightDir, normal), 0.0);
    highp vec3 diffuse = diff * surficeColor;
    
    // Specular surface factor.
    highp vec3 surfaceSpecular;
    if(materialSpecularMapEnabled)
        surfaceSpecular = texture2D(materialSpecularMapSampler, finalTextureCoord).rgb;
    else
        surfaceSpecular = materialSpecularColor;
    
    // Specular color base camera and light positions.
    highp vec3 viewDir = normalize(vec3(0.0, 90.0, 120.0) - finalPositionCoord);
    highp float spec = 0.0;
    
    // Use blinn or just phong
    if(false)
    {
        highp vec3 halfwayDir = normalize(lightDir + viewDir);
        spec = pow(max(dot(normal, halfwayDir), 0.0), materialShininess);
    }
    else
    {
        highp vec3 reflectDir = reflect(-lightDir, normal);
        spec = pow(max(dot(viewDir, reflectDir), 0.0), materialShininess);
    }
    highp vec3 specular = lights[lightIndex].specularColor * surfaceSpecular * spec;
    
    // Attenuation
    highp float distanceToLight = length(lightDir);
    highp float attenuation = 1.0 / (1.0 + 0.35 * distanceToLight + 0.44 * (distanceToLight * distanceToLight));
    
    // return all components added.
    return (ambient + diffuse + specular) * attenuation;
}

void main()
{
    // Surfice color from sampling the diffuse texture or taking the diffuce color.
    highp vec3 surficeColor;
    if(materialDiffuceMapEnabled)
        surficeColor = texture2D(materialDiffuceMapSampler, finalTextureCoord).rgb;
    else
        surficeColor = materialDiffuceColor;

    highp vec3 finalColor = vec3(0.0);
    
    for(int i = 0; i < numberOfLights; i++)
    {
        if(lights[i].type == 1)
        {
            finalColor += pointLight(i, surficeColor);
        }
    }
    
    gl_FragColor = vec4(finalColor, 1.0);
}
