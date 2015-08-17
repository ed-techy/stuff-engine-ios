#import "GEcolorshader.h"

@interface GEColorShader()
{
    GLint m_uniforms[GE_NUM_UNIFORMS];
}

- (void)setUpSahder;

@end

@implementation GEColorShader

@synthesize ModelViewProjectionMatrix;
@synthesize Material;

// ------------------------------------------------------------------------------ //
// ----------------------------------  Singleton -------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Singleton

+ (instancetype)sharedIntance
{
    static GEColorShader* sharedIntance;
    static dispatch_once_t onceToken;
    
    // Know if the shared instance was already allocated.
    dispatch_once(&onceToken, ^{
        CleanLog(GE_VERBOSE && SH_VERBOSE, @"Color Shader: Shared instance was allocated for the first time.");
        sharedIntance = [GEColorShader new];
    });
    
    return sharedIntance;
}

- (id)init
{
    self = [super initWithFileName:@"color_shader" BufferMode:GE_BUFFER_MODE_POSITION];
    
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
    m_uniforms[GE_UNIFORM_MATERIAL_DIFFUSE_COLOR] = glGetUniformLocation(m_programID, "colorComponent");
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
    
    // Material color and opasity.
    glUniform4fv(m_uniforms[GE_UNIFORM_MATERIAL_DIFFUSE_COLOR], 1, GLKVector4MakeWithVector3(Material.DiffuseColor, Material.Opasity).v);
    
    // No texture
    glActiveTexture(0);
}

@end
