#import "GEframe.h"
#import "GEjoint.h"

@interface GEAnimation : NSObject

@property unsigned int NumberOfFrames;
@property unsigned int FrameRate;

- (void)loadAnimationWithFileName:(NSString*)filename;

@end