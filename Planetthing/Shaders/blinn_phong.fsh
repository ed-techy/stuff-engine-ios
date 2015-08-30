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
    sampler2D shadowMapSampler;
    bool shadowsEnabled;
    highp float shadowMapTextelSize;
};

uniform Light lights[8];
uniform highp int numberOfLights;

varying highp vec3 finalPositionLightSpaceCoord[8];

void main()
{
    // Final color combining lights and shadows.
    lowp vec3 finalColor = vec3(0.0);
    lowp vec3 perLightColor;
    
    // Material properties.
    lowp vec3 surfaceColor;
    lowp float surfaceOpasity;
    lowp vec3 surfaceSpecular;
    
    // Light calculations.
    highp vec3 normal;
    highp vec3 viewDir;
    highp vec3 lightDir;
    highp float lightFace = 0.0;
    lowp vec3 diffuse = vec3(0.0);
    lowp vec3 ambient = vec3(0.0);
    lowp vec3 specular = vec3(0.0);
    highp float spec;
    highp vec3 halfwayDir;
    mediump float shadow;
    highp float normalDir;
    
    
    // Surfice color from sampling the diffuse texture or taking the diffuce color.
    if(materialDiffuceMapEnabled)
    {
        surfaceColor = texture2D(materialDiffuceMapSampler, finalTextureCoord).rgb;
        surfaceOpasity = texture2D(materialDiffuceMapSampler, finalTextureCoord).a;
    }
    else
        surfaceColor = materialDiffuceColor;
    
    // Specular surface factor.
    if(materialSpecularMapEnabled)
        surfaceSpecular = texture2D(materialSpecularMapSampler, finalTextureCoord).rgb;
    else
        surfaceSpecular = materialSpecularColor;
    
    // Normal vector for this fragment.
    normal = normalize(finalNormalCoord);
    
    // View vector for this fragment.
    viewDir = normalize(vec3(0.0, 90.0, 120.0) - finalPositionCoord);
    
    
    // Calculate the contribution of every light.
    for(int i = 0; i < numberOfLights; i++)
    {
        // Calculate the light to surfice direction.
        if(lights[i].type == 0) // Directional light.
            lightDir = normalize(lights[i].position);
        else
            lightDir = normalize(lights[i].position - finalPositionCoord);
        
        // Ambient contribution of this light.
        ambient += lights[i].ambientColor;
        
        // Normal light direction vector.
        normalDir = dot(normal, lightDir);
        
        shadow = 0.0;
        
        // Shadow calculations.
        if(lights[i].shadowsEnabled)
        {
            // Keep the shadow at 0.0 when outside the far_plane region of the light's frustum.
            if(finalPositionLightSpaceCoord[i].z > 1.0)
                shadow = 0.0;
            else
            {
                // Get depth of current fragment from light's perspective.
                lowp float currentDepth = finalPositionLightSpaceCoord[i].z;
                
                // Check whether current frag pos is in shadow.
                lowp float bias = max(0.05 * (1.0 - normalDir), 0.005);
                
                for(int x = -0; x <= 0; x++)
                {
                    for(int y = -0; y <= 0; y++)
                    {
                        lowp float pcfDepth = texture2D(lights[i].shadowMapSampler, finalPositionLightSpaceCoord[i].xy + vec2(x, y) * lights[i].shadowMapTextelSize).r;
                        shadow += currentDepth - bias > pcfDepth ? 1.0 : 0.0;
                    }
                }
                shadow /= 1.0;
            }
        }
        
        // How much the fragment is facing the light
        lightFace += max(normalDir, 0.0);
        
        // Spot Light.
        if(lights[i].type == 2)
        {
            highp float theta = dot(lightDir, normalize(lights[i].position));
            if(theta < lights[i].cutOff)
                continue;
        }
        
        // This light can be not calculated.
        if(lightFace == 0.0)
            continue;
        
        // Diffuce contribution base color light and facing.
        diffuse += lights[i].diffuseColor * lightFace * (1.0 - shadow);
        
        // Specular color base camera and light positions.
        halfwayDir = normalize(lightDir + viewDir);
        specular += lights[i].specularColor * pow(max(dot(normal, halfwayDir), 0.0), materialShininess);;
    }
    
    // Final ambient color.
    ambient *= materialAmbientColor * surfaceColor;
    
    // Final diffuce color.
    diffuse *= surfaceColor;
    
    // Final specular color.
    specular *= surfaceSpecular;
    
    gl_FragColor = vec4(ambient + diffuse + specular, surfaceOpasity);
}
