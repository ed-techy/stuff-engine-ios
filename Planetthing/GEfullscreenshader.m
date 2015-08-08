#import "GEfullscreenshader.h"

@interface GEFullScreenShader()
{
    GLint uniforms[GE_NUM_UNIFORMS];
}

- (void)setUpSahder;

@end

@implementation GEFullScreenShader

@synthesize TextureID;

// ------------------------------------------------------------------------------ //
// ----------------------------------  Singleton -------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Singleton

+ (instancetype)sharedIntance
{
    static GEFullScreenShader* sharedIntance;
    static dispatch_once_t onceToken;
    
    // Know if the shared instance was already allocated.
    dispatch_once(&onceToken, ^{
        CleanLog(GE_VERBOSE && SH_VERBOSE, @"Full Screen Shader: Shared instance was allocated for the first time.");
        sharedIntance = [GEFullScreenShader new];
    });
    
    return sharedIntance;
}

- (id)init
{
    self = [super initWithFileName:@"fullscreen_shader" BufferMode:GE_BUFFER_MODE_POSITION_TEXTURE];
    
    if(self)
        [self setUpSahder];
    
    return self;
    
}

- (void)useProgram
{
    glUseProgram(m_programID);
    
    // Set one texture to render and the current texture to render.
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, TextureID);
    glUniform1i(uniforms[GE_UNIFORM_MATERIAL_DIFFUSE_MAP], 0);
}

- (void)setUpSahder
{
    // Get uniform locations.
    uniforms[GE_UNIFORM_MATERIAL_DIFFUSE_MAP] = glGetUniformLocation(m_programID, "textureSampler");
}

@end
