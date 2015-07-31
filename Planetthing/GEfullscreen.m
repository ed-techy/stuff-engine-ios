#import "GEfullscreen.h"

@interface GEFullScreen()
{
    GEFullScreenShader* m_fullScreenShader;
    
    GLuint m_fullScreenVertexBufferId;
    GLuint m_fullScreenVertexArrayId;
}

- (void)createFullScreenVO;

@end

@implementation GEFullScreen

@synthesize TextureID;

// ------------------------------------------------------------------------------ //
// -----------------------------  Singleton - Set up ---------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Singleton - Set up

+ (instancetype)sharedIntance
{
    static GEFullScreen* sharedIntance;
    static dispatch_once_t onceToken;
    
    // Know if the shared instance was already allocated.
    dispatch_once(&onceToken, ^{
        CleanLog(GE_VERBOSE && FS_VERBOSE, @"Full Screen: Shared instance was allocated for the first time.");
        sharedIntance = [GEFullScreen sharedIntance];
    });
    
    return sharedIntance;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        // Create the rectangle that cover coordinates from - 1 to 1 up and down.
        [self createFullScreenVO];
        
        // Get the full screen shader
        m_fullScreenShader = [GEFullScreenShader sharedIntance];
    }
    
    return self;
}

- (void)createFullScreenVO
{
    GLfloat vertices[30] =
    {
        -1.0f, -1.0f, 0.0f,		0.0f, 0.0f,
        -1.0f,  1.0f, 0.0f,		0.0f, 1.0f,
         1.0f, -1.0f, 0.0f,		1.0f, 0.0f,
        -1.0f,  1.0f, 0.0f,		0.0f, 1.0f,
         1.0f,  1.0f, 0.0f,		1.0f, 1.0f,
         1.0f, -1.0f, 0.0f,		1.0f, 0.0f
    };

    glGenVertexArraysOES(1, &m_fullScreenVertexArrayId);
    glBindVertexArrayOES(m_fullScreenVertexArrayId);
    
    glGenBuffers(1, &m_fullScreenVertexBufferId);
    glBindBuffer(GL_ARRAY_BUFFER, m_fullScreenVertexBufferId);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 5, 0);
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 5, (unsigned char*)NULL + (3 * sizeof(float)));
    
    glBindVertexArrayOES(0);
}

// ------------------------------------------------------------------------------ //
// -----------------------------------  Render ---------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Render

- (void)render
{
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glBlendEquation(GL_FUNC_ADD);
    glDisable(GL_DEPTH_TEST);
    
    // Full screen parameters.
    m_fullScreenShader.TextureID = TextureID;
    [m_fullScreenShader useProgram];
    
    // Bind the vertex array object that stored all the information about the vertex and index buffers.
    glBindVertexArrayOES(m_fullScreenVertexArrayId);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glDisableVertexAttribArray(GLKVertexAttribNormal);
    
    // Draw call.
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

@end