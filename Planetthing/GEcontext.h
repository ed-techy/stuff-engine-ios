#import <GLKit/GLKit.h>
#import "GMglobals.h"

@interface GEContext : NSObject

// -------------------------------------------- //
// ---------------- Properties ---------------- //
// -------------------------------------------- //
#pragma mark Properties

@property GLKView* ContextView;
@property (readonly) GLint MaxTextureSize;

// -------------------------------------------- //
// ----------------- Singleton ---------------- //
// -------------------------------------------- //
#pragma mark Sngleton
+ (instancetype)sharedIntance;

// -------------------------------------------- //
// ------------- Public Functions ------------- //
// -------------------------------------------- //
#pragma mark Public Functions

- (void)setBackgroundColor:(GLKVector4)color;

@end