#import "GEframe.h"
#import "GEjoint.h"

@interface GEAnimation : NSObject

@property unsigned int NumberOfFrames;
@property unsigned int FrameRate;
@property (readonly)NSMutableArray* Frames;

- (void)loadAnimationWithFileName:(NSString*)filename;

@end