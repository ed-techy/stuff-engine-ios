#import "GEcommon.h"

@interface GEShader : NSObject
{
    GLuint m_programID;
}

// -------------------------------------------- //
// -------------- Initialization -------------- //
// -------------------------------------------- //
#pragma mark Initialization
- (id)initWithFileName:(NSString*)filename BufferMode:(enum GE_BUFFER_MODE)buffermode;

@end
