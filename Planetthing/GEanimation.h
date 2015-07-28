#import "GEframe.h"
#import "GEjoint.h"
#import "GEupdatecaller.h"

@protocol GEAnimationProtocol;

@interface GEAnimation : NSObject <GEUpdateProtocol>

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
@property (readonly)bool Playing;
@property float CurrentTime;
@property bool Reverse;
@property float PlaybackSpeed;

// -------------------------------------------- //
// ------------ Selector Management ----------- //
// -------------------------------------------- //
#pragma mark Selector Management

- (void)addSelector:(id<GEAnimationProtocol>)selector;
- (void)removeSelector:(id)selector;

// -------------------------------------------- //
// ---------- Load - Import - Export ---------- //
// -------------------------------------------- //
#pragma mark Load - Import - Export

- (void)loadAnimationWithFileName:(NSString*)filename;

// -------------------------------------------- //
// ------------------ Playback ---------------- //
// -------------------------------------------- //
#pragma mark Playback

- (void)Play;
- (void)Stop;
- (void)Pause;

@end

@protocol GEAnimationProtocol <NSObject>

@required
- (void)poseForFrameDidFinish:(GEFrame*)frame;

@end