#import "GErenderbox.h"

@interface GERenderBox()
{

}

@end

@implementation GERenderBox

@synthesize MainView;

// ------------------------------------------------------------------------------ //
// ----------------------------------  Singleton -------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Singleton

+ (instancetype)sharedIntance
{
    static GERenderBox* sharedIntance;
    static dispatch_once_t onceToken;
    
    // Know if the shared instance was already allocated.
    dispatch_once(&onceToken, ^{
        CleanLog(GE_VERBOSE && RB_VERBOSE, @"Render Box: Shared instance was allocated for the first time.");
        sharedIntance = [[GERenderBox alloc] init];
    });
    
    return sharedIntance;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        MainView = [[GEView alloc] init];
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
    // Render to screen
    [MainView render];
}

- (void)layoutForWidth:(NSNumber*)width andHeight:(NSNumber*)height
{
    
}

// ------------------------------------------------------------------------------ //
// ------------------------------ Setters - Getters ----------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Setters - Getters


@end
