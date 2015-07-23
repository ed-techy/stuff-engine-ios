#import "GEshader.h"

@interface GEFullScreenShader : GEShader

// -------------------------------------------- //
// ---------------- Properties ---------------- //
// -------------------------------------------- //
#pragma mark Properties
@property GLuint TextureID;

// -------------------------------------------- //
// ----------------- Singleton ---------------- //
// -------------------------------------------- //
+ (instancetype)sharedIntance;

// -------------------------------------------- //
// ---------------- Use Program --------------- //
// -------------------------------------------- //
#pragma mark Use Program
- (void)useProgram;

@end
