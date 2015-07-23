#import "GEcommon.h"
#import "GEfullscreenshader.h"

@interface GEFullScreen : NSObject

// -------------------------------------------- //
// ---------------- Properties ---------------- //
// -------------------------------------------- //
#pragma mark Properties

@property GLuint TextureID;

// -------------------------------------------- //
// ----------------- Singleton ---------------- //
// -------------------------------------------- //
#pragma mark Singleton

+ (instancetype)sharedIntance;


// -------------------------------------------- //
// ------------------ Render ------------------ //
// -------------------------------------------- //
#pragma mark Render

- (void)render;

@end