#import "GEcommon.h"

@interface GEJoint : NSObject
@property NSString* Name;
@property int ParentID;
@property GLKVector3 Position;
@property GLKQuaternion Orientation;
@end

@interface GEJointInfo : NSObject
@property NSString* Name;
@property int ParentID;
@property int Flags;
@property int StartIndex;
@end

@interface GEBound : NSObject
@property GLKVector3 MaxBound;
@property GLKVector3 MinBound;
@end

@interface GEAnimation : NSObject

@property unsigned int NumberOfFrames;
@property unsigned int FrameRate;

- (void)loadAnimationWithFileName:(NSString*)filename;

@end