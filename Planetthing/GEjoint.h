#import "GEcommon.h"

@interface GEJoint : NSObject

// -------------------------------------------- //
// ---------------- Properties ---------------- //
// -------------------------------------------- //
#pragma mark Properties

@property NSString* Name;
@property GEJoint* Parent;
@property GLKVector3 Position;
@property GLKQuaternion Orientation;

@end
