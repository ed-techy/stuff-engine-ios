#import "GEupdatecaller.h"

@interface GEUpdateCaller()
{
    NSMutableArray* m_selectors;
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
        m_selectors = [NSMutableArray new];
    }
    
    return self;
}

// ------------------------------------------------------------------------------ //
// ----------------------------- Selector Management ---------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Selector Management

- (void)addSelector:(id<GEUpdateProtocol>)selector
{
    [m_selectors addObject:selector];
}

- (void)removeSelector:(id)selector
{
    [m_selectors removeObject:selector];
}

// ------------------------------------------------------------------------------ //
// ------------------------------------ Update ---------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Update

- (void)update:(float)time
{
    // Update each seector in the list
    for(id object in m_selectors)
    {
        if([object respondsToSelector:@selector(update:)])
            [object update:time];
    }
}

- (void)preUpdate
{
    
}

- (void)posUpdate
{
    
}
@end



