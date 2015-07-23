#import "GEcommon.h"

@interface GEShader : NSObject

// -------------------------------------------- //
// ---------------- Properties ---------------- //
// -------------------------------------------- //
#pragma mark Properties
@property (readonly)GLuint ProgramID;

// -------------------------------------------- //
// -------------- Initialization -------------- //
// -------------------------------------------- //
#pragma mark Initialization
- (id)initWithFileName:(NSString*)filename BufferMode:(enum GE_BUFFER_MODE)buffermode;

@end
