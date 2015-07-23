#import "GEtextureshader.h"

@interface GETextureShader()
{
	GLint m_uniforms[GE_NUM_UNIFORMS];
}

- (void)setUpSahder;

@end

@implementation GETextureShader

@synthesize ModelViewProjectionMatrix;
@synthesize TextureID;
@synthesize TextureCompression;
@synthesize ColorComponent;
@synthesize OpasityComponent;

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
        sharedIntance = [[GETextureShader alloc] init];
    });
    
    return sharedIntance;
}

- (id)init
{
    self = [super initWithFileName:@"texture_shader" BufferMode:GE_BUFFER_MODE_POSITION_TEXTURE];
	
	if(self)
	   [self setUpSahder];
	
	return self;
	
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
	
	// The color what we want to tint the image and the opasity.
	//glUniform4fv(m_uniforms[GE_UNIFORM_COLOR], 1, GLKVector4Make(color.r, color.g, color.b, 1.0f).v);
	glUniform1f(m_uniforms[GE_UNIFORM_OPASITY], OpasityComponent);
	
	// Texture compression
	glUniform2f(m_uniforms[GE_UNIFORM_TEXTURE_COMPRESSION], TextureCompression.x, TextureCompression.y);
	
	// Set one texture to render and the current texture to render.
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, TextureID);
	glUniform1i(m_uniforms[GE_UNIFORM_TEXTURE], 0);
}

- (void)setUpSahder
{
	// Get uniform locations.
	m_uniforms[GE_UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(m_programID, "modelViewProjectionMatrix");
	m_uniforms[GE_UNIFORM_TEXTURE] = glGetUniformLocation(m_programID, "textureSampler");
	//m_uniforms[GE_UNIFORM_COLOR] = glGetUniformLocation(m_programID, "ColorOut");
	m_uniforms[GE_UNIFORM_TEXTURE_COMPRESSION] = glGetUniformLocation(m_programID, "textureCompression");
	m_uniforms[GE_UNIFORM_OPASITY] = glGetUniformLocation(m_programID, "opasityCompound");
}

@end
