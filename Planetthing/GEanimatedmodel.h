#import "GEtextureshader.h"
#import "GEmesh.h"
#import "GEanimation.h"

@interface GEAnimatedModel : NSObject <GEAnimationProtocol>

// -------------------------------------------- //
// ---------------- Properties ---------------- //
// -------------------------------------------- //
#pragma mark Properties
@property (readonly)NSString* FileName;
@property (readonly)bool Ready;

// -------------------------------------------- //
// ---------- Load - Import - Export ---------- //
// -------------------------------------------- //
#pragma mark Load - Import - Export

- (void)loadModelWithFileName:(NSString*)filename;

// -------------------------------------------- //
// ----------------- Animation ---------------- //
// -------------------------------------------- //
#pragma mark Animation

- (void)resetPose;

// -------------------------------------------- //
// ------------------ Render ------------------ //
// -------------------------------------------- //
#pragma mark Render
- (void)render;

@end
