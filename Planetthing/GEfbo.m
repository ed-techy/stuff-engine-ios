#import "GEfbo.h"

@interface GEFBO()
{

}

@end

@implementation GEFBO

@synthesize FrameBufferID;
@synthesize Width;
@synthesize Height;
@synthesize TextureID;
@synthesize DepthTextureID;

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
    
    // Depth texture.
    glGenTextures(1, &DepthTextureID);
    glBindTexture(GL_TEXTURE_2D, DepthTextureID);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT,  Width, Height, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_INT, NULL);
    
    // Generate the frame buffer.
    glGenFramebuffers(1, &FrameBufferID);
    
    // Bind that frame buffer.
    glBindFramebuffer(GL_FRAMEBUFFER, FrameBufferID);
    
    //Attach 2D texture to this FBO
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, DepthTextureID, 0);
    
    // Check for completness.
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if(status != GL_FRAMEBUFFER_COMPLETE)
        NSLog(@"The Framebuffer was not completed.");
}


@end
