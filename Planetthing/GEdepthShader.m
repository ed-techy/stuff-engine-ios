#import "GEdepthShader.h"

@interface GEDepthShader()
{
    GLint m_uniforms[GE_NUM_UNIFORMS];
}

- (void)setUpSahder;

@end

@implementation GEDepthShader

@synthesize ModelViewProjectionMatrix;

// ------------------------------------------------------------------------------ //
// ----------------------------------  Singleton -------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Singleton

+ (instancetype)sharedIntance
{
    static GEDepthShader* sharedIntance;
    static dispatch_once_t onceToken;
    
    // Know if the shared instance was already allocated.
    dispatch_once(&onceToken, ^{
        CleanLog(GE_VERBOSE && SH_VERBOSE, @"Depth Shader: Shared instance was allocated for the first time.");
        sharedIntance = [GEDepthShader new];
    });
    
    return sharedIntance;
}

- (id)init
{
    self = [super initWithFileName:@"depth_shader" BufferMode:GE_BUFFER_MODE_POSITION];
    
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
    
    // No texture
    glActiveTexture(0);
}

@end
