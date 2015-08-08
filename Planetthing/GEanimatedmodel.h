#import "GEtextureshader.h"
#import "GEblinnphongshader.h"
#import "GEcolorshader.h"
#import "GEmesh.h"
#import "GEanimation.h"
#import "GEboundingbox.h"

@interface GEAnimatedModel : NSObject <GEAnimationProtocol>

// -------------------------------------------- //
// ---------------- Properties ---------------- //
// -------------------------------------------- //
#pragma mark Properties
@property (readonly)NSString* FileName;
@property (readonly)bool Ready;
@property bool RenderBoundingBox;
@property bool Visible;
@property bool Enabled;

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
