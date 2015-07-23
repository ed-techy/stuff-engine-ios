#import "GEshader.h"

@interface GETextureShader : GEShader

// -------------------------------------------- //
// ---------------- Properties ---------------- //
// -------------------------------------------- //
#pragma mark Properties
@property GLKMatrix4* ModelViewProjectionMatrix;
@property GLuint TextureID;
@property GLKVector3 TextureCompression;
@property GLKVector3 ColorComponent;
@property float OpasityComponent;

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
