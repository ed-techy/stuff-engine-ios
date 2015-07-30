#import "GEfbo.h"

@interface GEFBO()
{
    GLuint m_renderBufferForDepth;
}

@end

@implementation GEFBO

@synthesize FrameBufferID;
@synthesize Width;
@synthesize Height;
@synthesize TextureID;
@synthesize Texture2ID;
@synthesize Texture3ID;

- (id)init
{
    self = [super init];
    
    if(self)
    {
        
    }
    
    return self;
}


- (void)geberateForWidth:(GLsizei)width andHeight:(GLuint)height;
{
    Width = width;
    Height = height;
    
    // Generate the depth render buffer.
    glGenRenderbuffers(1, &m_renderBufferForDepth);
    
    // Bind that render buffer.
    glBindRenderbuffer(GL_RENDERBUFFER, m_renderBufferForDepth);
    
    // Allocate the data for depth storage.
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, Width, Height);
    
    // Generate the frame buffer.
    glGenFramebuffers(1, &FrameBufferID);
    
    // Bind that frame buffer.
    glBindFramebuffer(GL_FRAMEBUFFER, FrameBufferID);
    
    // Generate an ID for the texture.
    glGenTextures(1, &TextureID);
    
    // Bind the texture as a 2D texture.
    glBindTexture(GL_TEXTURE_2D, TextureID);
    
    // Use linear filetring
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    // Clamp
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,  Width, Height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    
    //Attach 2D texture to this FBO
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, TextureID, 0);
    
    // Generate an ID for the texture.
    glGenTextures(1, &Texture2ID);
    
    // Bind the texture as a 2D texture.
    glBindTexture(GL_TEXTURE_2D, Texture2ID);
    
    // Use linear filetring
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    // Clamp
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,  Width, Height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    
    //Attach 2D texture to this FBO
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0+ 1, GL_TEXTURE_2D, Texture2ID, 0);
    
    // Generate an ID for the texture.
    glGenTextures(1, &Texture3ID);
    
    // Bind the texture as a 2D texture.
    glBindTexture(GL_TEXTURE_2D, Texture3ID);
    
    // Use linear filetring
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    // Clamp
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,  Width, Height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    
    //Attach 2D texture to this FBO
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + 2, GL_TEXTURE_2D, Texture3ID, 0);
    
    // Attach depth buffer to FBO
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, m_renderBufferForDepth);
}


@end
