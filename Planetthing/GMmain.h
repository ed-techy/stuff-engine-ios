#import "IHgamecenter.h"

@interface GMmain : NSObject

// -------------------------------------------- //
// ---------------- Properties ---------------- //
// -------------------------------------------- //
#pragma mark Properties


// -------------------------------------------- //
// ----------------- Singleton ---------------- //
// -------------------------------------------- //
#pragma mark Sngleton
+ (instancetype)sharedIntance;

// -------------------------------------------- //
// --------- Frame - Render - Layout ---------- //
// -------------------------------------------- //
#pragma mark Frame - Render - Layout
- (void)frame:(float)time;
- (void)render;
- (void)layoutForWidth:(NSNumber*)width andHeight:(NSNumber*)height;

@end
