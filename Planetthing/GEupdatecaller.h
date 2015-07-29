#import "GEcommon.h"

@protocol GEUpdateProtocol;
@protocol GERenderProtocol;

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

- (void)addUpdateableSelector:(id<GEUpdateProtocol>)selector;
- (void)addRenderableSelector:(id<GERenderProtocol>)selector;
- (void)removeSelector:(id)selector;

// -------------------------------------------- //
// ------------------ Update ------------------ //
// -------------------------------------------- //
#pragma mark Update

- (void)update:(float)time;
- (void)preUpdate;
- (void)posUpdate;

// -------------------------------------------- //
// ------------- Render - Layout -------------- //
// -------------------------------------------- //
#pragma mark Render - Layout
- (void)render;
- (void)layoutForWidth:(float)width AndHeight:(float)height;

@end


@protocol GEUpdateProtocol <NSObject>

@optional
- (void)update:(float)time;
- (void)preUpdate;
- (void)posUpdate;

@end

@protocol GERenderProtocol <NSObject>

@optional
- (void)render;
- (void)layoutForWidth:(float)width AndHeight:(float)height;

@end