#import "GEmaterial.h"
#import "GEtriangle.h"
#import "GEjoint.h"
#import "GEframe.h"

@interface GEMesh : NSObject

// -------------------------------------------- //
// ---------------- Properties ---------------- //
// -------------------------------------------- //
#pragma mark Properties

@property GEMaterial* Material;
@property NSMutableArray* Vertices;
@property NSMutableArray* Triangles;
@property NSMutableArray* Weights;

// -------------------------------------------- //
// -------- Generate - Compute Vertices ------- //
// -------------------------------------------- //
#pragma mark Generate - Compute Vertices

- (void)generateBuffers;
- (void)matchMeshWithFrame:(GEFrame*)frame;

// -------------------------------------------- //
// ------------------ Render ------------------ //
// -------------------------------------------- //
#pragma mark Render

- (void)render;

@end