#import "GEcontext.h"

@interface GEFBO : NSObject

// -------------------------------------------- //
// ---------------- Properties ---------------- //
// -------------------------------------------- //
#pragma mark Properties

@property (readonly)GLuint FrameBufferID;
@property (readonly)GLuint TextureID;
@property (readonly)GLsizei Width;
@property (readonly)GLsizei Height;

- (void)geberateForWidth:(GLsizei)width andHeight:(GLuint)height;

@end
