#import "GEshader.h"

@interface GEBlinnPhongShader : GEShader

// -------------------------------------------- //
// ---------------- Properties ---------------- //
// -------------------------------------------- //
#pragma mark Properties
@property GLKMatrix4* ModelViewProjectionMatrix;
@property NSMutableArray* Lights;
@property GEMaterial* Material;
@property bool DiffuceMapEnabled;
@property bool SpecularMapEnabled;

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
