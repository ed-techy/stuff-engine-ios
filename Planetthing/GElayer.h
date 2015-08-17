#import "GEcommon.h"

@interface GELayer : NSObject

// -------------------------------------------- //
// ---------------- Properties ---------------- //
// -------------------------------------------- //
#pragma mark Properties

@property bool Visible;
@property NSString* Name;
@property (readonly)unsigned int NumberOfObjects;

// -------------------------------------------- //
// ------------------ Render ------------------ //
// -------------------------------------------- //
#pragma mark Render

- (void)render;
- (void)renderDepth;

// -------------------------------------------- //
// ----------- Add - Remove objects ----------- //
// -------------------------------------------- //
#pragma mark Add - Remove objects

- (void)addObject:(id)object;
- (void)removeObject:(id)object;

@end