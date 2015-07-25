#import "GEweight.h"

@interface GEVertex : NSObject

// -------------------------------------------- //
// ---------------- Properties ---------------- //
// -------------------------------------------- //
#pragma mark Properties

@property unsigned int Index;
@property GLKVector3 Position;
@property GLKVector3 Normal;
@property GLKVector2 TextureCoord;
@property NSMutableArray* Weights;

@end
