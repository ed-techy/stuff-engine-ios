#import "GEframe.h"
#import "GEjoint.h"

@protocol GEAnimationProtocol;

@interface GEAnimation : NSObject

// -------------------------------------------- //
// ---------------- Properties ---------------- //
// -------------------------------------------- //
#pragma mark Properties

@property (readonly)NSString* FileName;
@property (readonly)unsigned int NumberOfFrames;
@property (readonly)unsigned int FrameRate;
@property (readonly)NSMutableArray* Frames;
@property (readonly)bool Ready;

@property (readonly)float Duration;
@property float CurrentTime;
@property bool Reverse;

// -------------------------------------------- //
// ------------ Selector Management ----------- //
// -------------------------------------------- //
#pragma mark Selector Management

- (void)addSelector:(id<GEAnimationProtocol>)moidel;
- (void)removeSelector:(id)moidel;

// -------------------------------------------- //
// ---------- Load - Import - Export ---------- //
// -------------------------------------------- //
#pragma mark Load - Import - Export

- (void)loadAnimationWithFileName:(NSString*)filename;

// -------------------------------------------- //
// -------------- Frame - Playback ------------ //
// -------------------------------------------- //
#pragma mark Load - Frame - Playback

- (void)frame:(float)time;

@end

@protocol GEAnimationProtocol <NSObject>

@required
- (void)poseForFrameDidFinish:(GEFrame*)frame;

@end