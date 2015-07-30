uniform sampler2D textureSampler;
uniform lowp float opasityComponent;

varying highp vec3 finalPositionCoord;
varying highp vec2 finalTextureCoord;
varying highp vec3 finalNormalCoord;

void main()
{
    highp vec3 color = texture2D(textureSampler, finalTextureCoord).rgb;
    // Ambient
    highp vec3 ambient = vec3(0.01, 0.01, 0.02) * color;
    // Diffuse
    highp vec3 lightDir = normalize(vec3(-30.0, -10.0, 60.0) - finalPositionCoord);
    highp vec3 normal = normalize(finalNormalCoord);
    highp float diff = max(dot(lightDir, normal), 0.0);
    highp vec3 diffuse = diff * color;
    // Specular
    highp vec3 viewDir = normalize(vec3(0.0, -120.0, 90.0) - finalPositionCoord);
    highp vec3 reflectDir = reflect(-lightDir, normal);
    highp float spec = 0.0;
    if(true)
    {
        highp vec3 halfwayDir = normalize(lightDir + viewDir);
        spec = pow(max(dot(normal, halfwayDir), 0.0), 32.0);
    }
    else
    {
        highp vec3 reflectDir = reflect(-lightDir, normal);
        spec = pow(max(dot(viewDir, reflectDir), 0.0), 8.0);
    }
    highp vec3 specular = vec3(0.5) * spec; // assuming bright white light color
    gl_FragColor = vec4(ambient + diffuse + specular, 1.0);
    
}
