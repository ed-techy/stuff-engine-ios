uniform sampler2D textureSampler;

varying lowp vec2 finalTextureCoord;

void main()
{
    highp float depthValue = texture2D(textureSampler, finalTextureCoord).r;
    gl_FragColor = vec4(vec3(depthValue), 1.0);
}