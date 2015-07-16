#import "GMmain.h"

@interface GMmain()
{
}

@end

@implementation GMmain


// ------------------------------------------------------------------------------ //
// ---------------------------- Game Center singleton --------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark GameCenter Singleton

+ (instancetype)sharedIntance
{
    static GMmain* sharedIntance;
    static dispatch_once_t onceToken;
    
    // Know if the shared instance was already allocated.
    dispatch_once(&onceToken, ^{
        CleanLog(IH_VERBOSE, @"Main Class: Shared Main Class instance was allocated for the first time.");
        sharedIntance = [[GMmain alloc] init];
    });
    
    return sharedIntance;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){

        //});
    }
    
    return self;
}


// ------------------------------------------------------------------------------ //
// -------------------------- Frame - Render - Layout --------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Frame - Render - Layout

- (void)frame:(float)time
{
    
}

- (void)render
{
    
}

- (void)layoutForWidth:(NSNumber*)width andHeight:(NSNumber*)height
{
    
}

@end