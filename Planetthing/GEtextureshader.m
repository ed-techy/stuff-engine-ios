#import "GEtextureshader.h"

@interface GETextureShader()
{
	GLint m_uniforms[GE_NUM_UNIFORMS];
}

- (void)setUpSahder;

@end

@implementation GETextureShader

@synthesize ModelViewProjectionMatrix;
@synthesize Material;

// ------------------------------------------------------------------------------ //
// ----------------------------------  Singleton -------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Singleton

+ (instancetype)sharedIntance
{
    static GETextureShader* sharedIntance;
    static dispatch_once_t onceToken;
    
    // Know if the shared instance was already allocated.
    dispatch_once(&onceToken, ^{
        CleanLog(GE_VERBOSE && SH_VERBOSE, @"Texture Shader: Shared instance was allocated for the first time.");
        sharedIntance = [GETextureShader new];
    });
    
    return sharedIntance;
}

- (id)init
{
    self = [super initWithFileName:@"texture_shader" BufferMode:GE_BUFFER_MODE_POSITION_TEXTURE];
	
	if(self)
    {
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
    m_uniforms[GE_UNIFORM_MATERIAL_DIFFUSE_MAP] = glGetUniformLocation(m_programID, "materialDifficeMapSampler");
}

// ------------------------------------------------------------------------------ //
// ---------------------------------- Use Program ------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Use Program

- (void)useProgram
{
	glUseProgram(m_programID);
	
	// Set the Projection View Model Matrix to the shader.
	glUniformMatrix4fv(m_uniforms[GE_UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, ModelViewProjectionMatrix->m);
	
	// Material texture compression.
	glUniform2fv(m_uniforms[GE_UNIFORM_MATERIAL_TEXTURE_COMPRESSION], 1, Material.TextureCompression.v);
	
	// Material diffuce texture.
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, Material.DiffuseMap.TextureID);
	glUniform1i(m_uniforms[GE_UNIFORM_MATERIAL_DIFFUSE_MAP], 0);
}

@end
