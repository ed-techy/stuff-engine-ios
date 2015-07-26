#import "GEtextureshader.h"
#import "GEmesh.h"
#import "GEanimation.h"

@interface GEAnimatedModel : NSObject

// -------------------------------------------- //
// ---------------- Properties ---------------- //
// -------------------------------------------- //
#pragma mark Properties
@property NSString* FileName;
@property bool Ready;

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
- (void)poseByFrame:(GEFrame*)frame;

// -------------------------------------------- //
// ------------------ Render ------------------ //
// -------------------------------------------- //
#pragma mark Render
- (void)render;

@end
