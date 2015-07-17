#import "GMmain.h"

@interface GMmain()
{
    GERenderBox* m_renderBox;
}

@end

@implementation GMmain


// ------------------------------------------------------------------------------ //
// ---------------------------- Game Main singleton --------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Game Main Singleton

+ (instancetype)sharedIntance
{
    static GMmain* sharedIntance;
    static dispatch_once_t onceToken;
    
    // Know if the shared instance was already allocated.
    dispatch_once(&onceToken, ^{
        CleanLog(GM_VERBOSE, @"Game Main: Shared instance was allocated for the first time.");
        sharedIntance = [[GMmain alloc] init];
    });
    
    return sharedIntance;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        m_renderBox = [GERenderBox sharedIntance];
        m_renderBox.MainView.BackgroundColor = color_banana;
    }
    
    return self;
}


// ------------------------------------------------------------------------------ //
// -------------------------- Frame - Render - Layout --------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Frame - Render - Layout

- (void)frame:(float)time
{
    [m_renderBox frame:time];
}

- (void)render
{
    [m_renderBox render];
    
}

- (void)layoutForWidth:(NSNumber*)width andHeight:(NSNumber*)height
{
    [m_renderBox layoutForWidth:width andHeight:height];
}

@end