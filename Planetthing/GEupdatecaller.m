#import "GEupdatecaller.h"

@interface GEUpdateCaller()
{
    NSMutableArray* m_updateableSelectors;
    NSMutableArray* m_renderableSelectors;
}

@end

@implementation GEUpdateCaller

// ------------------------------------------------------------------------------ //
// ----------------------------------- Singleton -------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Singleton

+ (instancetype)sharedIntance
{
    static GEUpdateCaller* sharedIntance;
    static dispatch_once_t onceToken;
    
    // Know if the shared instance was already allocated.
    dispatch_once(&onceToken, ^{
        CleanLog(GE_VERBOSE && CT_VERBOSE, @"Update Caller: Shared instance was allocated for the first time.");
        sharedIntance = [GEUpdateCaller new];
    });
    
    return sharedIntance;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        m_updateableSelectors = [NSMutableArray new];
        m_renderableSelectors = [NSMutableArray new];
    }
    
    return self;
}

// ------------------------------------------------------------------------------ //
// ----------------------------- Selector Management ---------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Selector Management

- (void)addUpdateableSelector:(id<GEUpdateProtocol>)selector
{
    [m_updateableSelectors addObject:selector];
}

- (void)addRenderableSelector:(id<GERenderProtocol>)selector
{
    [m_renderableSelectors addObject:selector];
}

- (void)removeSelector:(id)selector
{
    [m_updateableSelectors removeObject:selector];
    [m_renderableSelectors removeObject:selector];
}

// ------------------------------------------------------------------------------ //
// ------------------------------------ Update ---------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Update

- (void)update:(float)time
{
    // Update each selector in the list.
    for(id object in m_updateableSelectors)
    {
        if([object respondsToSelector:@selector(update:)])
            [object update:time];
    }
}

- (void)preUpdate
{
    // Pre Update each selector in the list.
    for(id object in m_updateableSelectors)
    {
        if([object respondsToSelector:@selector(preUpdate)])
            [object preUpdate];
    }
}

- (void)posUpdate
{
    // Pos Update each selector in the list.
    for(id object in m_updateableSelectors)
    {
        if([object respondsToSelector:@selector(posUpdate)])
            [object posUpdate];
    }
}

// ------------------------------------------------------------------------------ //
// ------------------------------- Render - Layout ------------------------------ //
// ------------------------------------------------------------------------------ //
#pragma mark Render - Layout

- (void)render
{
    // Render each selector in the list.
    for(id object in m_renderableSelectors)
    {
        if([object respondsToSelector:@selector(render)])
            [object render];
    }
}

- (void)layoutForWidth:(float)width AndHeight:(float)height
{
    // Layout each selector in the list.
    for(id object in m_renderableSelectors)
    {
        if([object respondsToSelector:@selector(layoutForWidth:AndHeight:)])
            [object layoutForWidth:width AndHeight:height];
    }
}

@end
