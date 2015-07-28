#import "GEcolorshader.h"

@interface GEColorShader()
{
    GLint m_uniforms[GE_NUM_UNIFORMS];
}

- (void)setUpSahder;

@end

@implementation GEColorShader

@synthesize ModelViewProjectionMatrix;
@synthesize ColorComponent;
@synthesize OpasityComponent;

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
        // Default values
        ColorComponent = GLKVector3Make(1.0f, 1.0f, 1.0f);
        OpasityComponent = 1.0f;
        
        // Set up uniforms.
        [self setUpSahder];
    }
    
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
    
    // The color and opasity.
    glUniform4fv(m_uniforms[GE_UNIFORM_COLOR], 1, GLKVector4Make(ColorComponent.r, ColorComponent.g, ColorComponent.b, OpasityComponent).v);
    
    // Set one texture to render and the current texture to render.
    glActiveTexture(0);
    glUniform1i(m_uniforms[GE_UNIFORM_TEXTURE], 0);
}

- (void)setUpSahder
{
    // Get uniform locations.
    m_uniforms[GE_UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(m_programID, "modelViewProjectionMatrix");
    m_uniforms[GE_UNIFORM_COLOR] = glGetUniformLocation(m_programID, "colorComponent");
}

@end
