#import "GEblinnphongshader.h"

@interface GEBlinnPhongShader()
{
	GLint m_uniforms[GE_NUM_UNIFORMS];
    GLint m_lightUniforms[10][GE_NUM_LIGHT_UNIFORMS];
    
    unsigned int m_textureNum;
}

- (void)setUpSahder;

@end

@implementation GEBlinnPhongShader

@synthesize ModelViewProjectionMatrix;
@synthesize Lights;
@synthesize Material;
@synthesize DiffuceMapEnabled;
@synthesize SpecularMapEnabled;

// ------------------------------------------------------------------------------ //
// ----------------------------------  Singleton -------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Singleton

+ (instancetype)sharedIntance
{
    static GEBlinnPhongShader* sharedIntance;
    static dispatch_once_t onceToken;
    
    // Know if the shared instance was already allocated.
    dispatch_once(&onceToken, ^{
        CleanLog(GE_VERBOSE && SH_VERBOSE, @"Blinn Phong Shader: Shared instance was allocated for the first time.");
        sharedIntance = [GEBlinnPhongShader new];
    });
    
    return sharedIntance;
}

- (id)init
{
    self = [super initWithFileName:@"blinn_phong" BufferMode:GE_BUFFER_MODE_ALL];
	
	if(self)
    {
        // Settings
        DiffuceMapEnabled = true;
        SpecularMapEnabled = true;

        // Set up uniforms.
        [self setUpSahder];
    }
	
	return self;
}

- (void)setUpSahder
{
    // Get uniform locations.
    m_uniforms[GE_UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(m_programID, "modelViewProjectionMatrix");
    m_uniforms[GE_UNIFORM_MATERIAL_TEXTURE_COMPRESSION] = glGetUniformLocation(m_programID, "materialTextureCompression");
    m_uniforms[GE_UNIFORM_MATERIAL_DIFFUSE_MAP] = glGetUniformLocation(m_programID, "materialDiffuceMapSampler");
    m_uniforms[GE_UNIFORM_MATERIAL_DIFFUSE_MAP_ENABLED] = glGetUniformLocation(m_programID, "materialDiffuceMapEnabled");
    m_uniforms[GE_UNIFORM_MATERIAL_SPECULAR_MAP] = glGetUniformLocation(m_programID, "materialSpecularMapSampler");
    m_uniforms[GE_UNIFORM_MATERIAL_SPECULAR_MAP_ENABLED] = glGetUniformLocation(m_programID, "materialSpecularMapEnabled");
    m_uniforms[GE_UNIFORM_MATERIAL_DIFFUSE_COLOR] = glGetUniformLocation(m_programID, "materialDiffuceColor");
    m_uniforms[GE_UNIFORM_MATERIAL_AMBIENT_COLOR] = glGetUniformLocation(m_programID, "materialAmbientColor");
    m_uniforms[GE_UNIFORM_MATERIAL_SPECULAR_COLOR] = glGetUniformLocation(m_programID, "materialSpecularColor");
    m_uniforms[GE_UNIFORM_MATERIAL_SHININESS] = glGetUniformLocation(m_programID, "materialShininess");
    m_uniforms[GE_UNIFORM_MATERIAL_OPASITY] = glGetUniformLocation(m_programID, "materialOpasity");
    
    // Uniform locations for all possible 10 lights.
    m_uniforms[GE_UNIFORM_NUMBER_OF_VERTEX_LIGHTS] = glGetUniformLocation(m_programID, "numberOfVertexLights");
    m_uniforms[GE_UNIFORM_NUMBER_OF_FRAGMENT_LIGHTS] = glGetUniformLocation(m_programID, "numberOfFragmentLights");
    for(int i = 0; i < 10; i++)
    {
        m_lightUniforms[i][GE_UNIFORM_LIGHT_TYPE] = glGetUniformLocation(m_programID, [[NSString stringWithFormat:@"%@%@%@", @"lights[", [@(i) stringValue], @"].type"] UTF8String]);
        m_lightUniforms[i][GE_UNIFORM_LIGHT_POSITION] = glGetUniformLocation(m_programID, [[NSString stringWithFormat:@"%@%@%@", @"lights[", [@(i) stringValue], @"].position"] UTF8String]);
        m_lightUniforms[i][GE_UNIFORM_LIGHT_DIRECTION] = glGetUniformLocation(m_programID, [[NSString stringWithFormat:@"%@%@%@", @"lights[", [@(i) stringValue], @"].direction"] UTF8String]);
        m_lightUniforms[i][GE_UNIFORM_LIGHT_CUTOFF] = glGetUniformLocation(m_programID, [[NSString stringWithFormat:@"%@%@%@", @"lights[", [@(i) stringValue], @"].cutOff"] UTF8String]);
        m_lightUniforms[i][GE_UNIFORM_LIGHT_DIFFUSE_COLOR] = glGetUniformLocation(m_programID, [[NSString stringWithFormat:@"%@%@%@", @"lights[", [@(i) stringValue], @"].diffuseColor"] UTF8String]);
        m_lightUniforms[i][GE_UNIFORM_LIGHT_AMBIENT_COLOR] = glGetUniformLocation(m_programID, [[NSString stringWithFormat:@"%@%@%@", @"lights[", [@(i) stringValue], @"].ambientColor"] UTF8String]);
        m_lightUniforms[i][GE_UNIFORM_LIGHT_SPECULAR_COLOR] = glGetUniformLocation(m_programID, [[NSString stringWithFormat:@"%@%@%@", @"lights[", [@(i) stringValue], @"].specularColor"] UTF8String]);
        m_lightUniforms[i][GE_UNIFORM_LIGHT_SHADOW_MAP] = glGetUniformLocation(m_programID, [[NSString stringWithFormat:@"%@%@%@", @"lights[", [@(i) stringValue], @"].shadowMapSampler"] UTF8String]);
        m_lightUniforms[i][GE_UNIFORM_LIGHT_SHADOWS_ENABLED] = glGetUniformLocation(m_programID, [[NSString stringWithFormat:@"%@%@%@", @"lights[", [@(i) stringValue], @"].shadowsEnabled"] UTF8String]);
        m_lightUniforms[i][GE_UNIFORM_LIGHT_SHADOW_MAP_TEXTEL_SIZE] = glGetUniformLocation(m_programID, [[NSString stringWithFormat:@"%@%@%@", @"lights[", [@(i) stringValue], @"].shadowMapTextelSize"] UTF8String]);
        m_lightUniforms[i][GE_UNIFORM_LIGHT_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(m_programID, [[NSString stringWithFormat:@"%@%@%@", @"lightModelViewProjectionMatrices[", [@(i) stringValue], @"]"] UTF8String]);
    }
}

// ------------------------------------------------------------------------------ //
// ---------------------------------- Use Program ------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Use Program

- (void)useProgram
{
	glUseProgram(m_programID);
    
    // In case there is not textures.
    glActiveTexture(0);
	
    // Number of textures;
    m_textureNum = 0;
    
	// Set the Projection View Model Matrix to the shader.
	glUniformMatrix4fv(m_uniforms[GE_UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, ModelViewProjectionMatrix->m);
	
	// Material texture compression.
    glUniform2fv(m_uniforms[GE_UNIFORM_MATERIAL_TEXTURE_COMPRESSION], 1, Material.TextureCompression.v);
    
    // Material ambient color.
    glUniform3fv(m_uniforms[GE_UNIFORM_MATERIAL_AMBIENT_COLOR], 1, Material.AmbientColor.v);
    
    // Materialshininess.
    glUniform1f(m_uniforms[GE_UNIFORM_MATERIAL_SHININESS], Material.Shininess);
	
    // Material diffuce based of existance of a texture.
    bool diffuceEnabled = Material.DiffuseMap != nil && DiffuceMapEnabled;
    glUniform1i(m_uniforms[GE_UNIFORM_MATERIAL_DIFFUSE_MAP_ENABLED], diffuceEnabled);
    if(diffuceEnabled)
    {
        // Material diffuce texture.
        glActiveTexture(GL_TEXTURE0 + m_textureNum);
        glBindTexture(GL_TEXTURE_2D, Material.DiffuseMap.TextureID);
        glUniform1i(m_uniforms[GE_UNIFORM_MATERIAL_DIFFUSE_MAP], m_textureNum++);
    }
    else
    {
        // Material diffuce color.
        glUniform3fv(m_uniforms[GE_UNIFORM_MATERIAL_DIFFUSE_COLOR], 1, Material.DiffuseColor.v);
    }
    
    // Material specular based of existence of a texture.
    bool specularEnabled = Material.SpecularMap != nil && SpecularMapEnabled;
    glUniform1i(m_uniforms[GE_UNIFORM_MATERIAL_SPECULAR_MAP_ENABLED], specularEnabled);
    if(specularEnabled)
    {
        // Material specular texture.
        glActiveTexture(GL_TEXTURE0 + m_textureNum);
        glBindTexture(GL_TEXTURE_2D, Material.SpecularMap.TextureID);
        glUniform1i(m_uniforms[GE_UNIFORM_MATERIAL_SPECULAR_MAP], m_textureNum++);
    }
    else
    {
        // Material specular color.
        glUniform3fv(m_uniforms[GE_UNIFORM_MATERIAL_SPECULAR_COLOR], 1, Material.SpecularColor.v);
    }
    
    // Lights.
    glUniform1i(m_uniforms[GE_UNIFORM_NUMBER_OF_VERTEX_LIGHTS], (GLint)Lights.count);
    glUniform1i(m_uniforms[GE_UNIFORM_NUMBER_OF_FRAGMENT_LIGHTS], (GLint)Lights.count);
    [Lights enumerateObjectsUsingBlock:^(GELight* light, NSUInteger index, BOOL *stop)
     {
         glUniform1i(m_lightUniforms[index][GE_UNIFORM_LIGHT_TYPE], light.LightType);
         glUniform3fv(m_lightUniforms[index][GE_UNIFORM_LIGHT_POSITION], 1, light.Position.v);
         glUniform3fv(m_lightUniforms[index][GE_UNIFORM_LIGHT_DIRECTION], 1, GLKVector3Subtract(light.Position, light.Direction).v);
         glUniform1f(m_lightUniforms[index][GE_UNIFORM_LIGHT_CUTOFF], light.CutOff);
         glUniform3fv(m_lightUniforms[index][GE_UNIFORM_LIGHT_DIFFUSE_COLOR], 1, GLKVector3MultiplyScalar(light.DiffuseColor, light.Intensity).v);
         glUniform3fv(m_lightUniforms[index][GE_UNIFORM_LIGHT_AMBIENT_COLOR], 1, GLKVector3MultiplyScalar(light.AmbientColor, light.Ambient).v);
         glUniform3fv(m_lightUniforms[index][GE_UNIFORM_LIGHT_SPECULAR_COLOR], 1, light.SpecularColor.v);
         glUniform1i(m_lightUniforms[index][GE_UNIFORM_LIGHT_SHADOWS_ENABLED], light.CastShadows);
         glUniform1f(m_lightUniforms[index][GE_UNIFORM_LIGHT_SHADOW_MAP_TEXTEL_SIZE], 1.0f / (float)light.ShadowMapSize);
         
         glUniformMatrix4fv(m_lightUniforms[index][GE_UNIFORM_LIGHT_MODELVIEWPROJECTION_MATRIX], 1, 0, light.LightModelViewProjectionMatrix.m);
         
         // Shadow map for this light.
         glActiveTexture(GL_TEXTURE0 + m_textureNum);
         glBindTexture(GL_TEXTURE_2D, light.ShadowMapFBO.DepthTextureID);
         glUniform1i(m_lightUniforms[index][GE_UNIFORM_LIGHT_SHADOW_MAP], m_textureNum++);
     }];
	
}

@end
