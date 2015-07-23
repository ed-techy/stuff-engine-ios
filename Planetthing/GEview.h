#import "GEtexture.h"
#import "GEtextureshader.h"

@interface GEView : NSObject

// -------------------------------------------- //
// ---------------- Properties ---------------- //
// -------------------------------------------- //
#pragma mark Properties
@property GLKVector4 BackgroundColor;

// -------------------------------------------- //
// ------------------ Render ------------------ //
// -------------------------------------------- //
#pragma mark Render

- (void)render;

@end
