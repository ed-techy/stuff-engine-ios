#import "GEcommon.h"

@protocol GEUpdateProtocol;

@interface GEUpdateCaller : NSObject

// -------------------------------------------- //
// ---------------- Properties ---------------- //
// -------------------------------------------- //
#pragma mark Properties

// -------------------------------------------- //
// ----------------- Singleton ---------------- //
// -------------------------------------------- //
#pragma mark Singleton

+ (instancetype)sharedIntance;

// -------------------------------------------- //
// ------------ Selector Management ----------- //
// -------------------------------------------- //
#pragma mark Selector Management

- (void)addSelector:(id<GEUpdateProtocol>)selector;
- (void)removeSelector:(id)selector;

// -------------------------------------------- //
// ------------------ Update ------------------ //
// -------------------------------------------- //
#pragma mark Update

- (void)update:(float)time;
- (void)preUpdate;
- (void)posUpdate;

@end


@protocol GEUpdateProtocol <NSObject>

@required
- (void)update:(float)time;

@optional
- (void)preUpdate;
- (void)posUpdate;

@end