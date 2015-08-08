#import "GEshader.h"

@interface GETextureShader : GEShader

// -------------------------------------------- //
// ---------------- Properties ---------------- //
// -------------------------------------------- //
#pragma mark Properties
@property GLKMatrix4* ModelViewProjectionMatrix;
@property GEMaterial* Material;

// -------------------------------------------- //
// ----------------- Singleton ---------------- //
// -------------------------------------------- //
#pragma mark Singleton
+ (instancetype)sharedIntance;

// -------------------------------------------- //
// ---------------- Use Program --------------- //
// -------------------------------------------- //
#pragma mark Use Program

- (void)useProgram;

@end
