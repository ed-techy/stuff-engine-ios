#import "GMmain.h"

@interface GMmain()
{
    GEView* m_testView;
    GELayer* m_testLayer;
    IHGameCenter* m_gameCenter;
}

- (void)setUp;

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
        sharedIntance = [GMmain new];
    });
    
    return sharedIntance;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        // Resgister as updatable and renderable.
        [[GEUpdateCaller sharedIntance] addUpdateableSelector:self];
        [[GEUpdateCaller sharedIntance] addRenderableSelector:self];
        
        // Game Center
        // m_gameCenter = [IHGameCenter sharedIntance];
        
        // Initial setup.
        [self setUp];
    }
    
    return self;
}

// ------------------------------------------------------------------------------ //
// ------------------------------------ Setup ----------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Setup

- (void)setUp
{
    m_testView = [GEView new];
    m_testView.BackgroundColor = color_banana;
    
    m_testLayer = [m_testView addLayerWithName:@"TestLayer"];
    
    GEAnimatedModel* model = [GEAnimatedModel new];
    [model loadModelWithFileName:@"Bob Lamp/bob_lamp.md5mesh"];
    model.RenderBoundingBox = true;
    GEAnimation* animation = [GEAnimation new];
    [animation loadAnimationWithFileName:@"Bob Lamp/bob_lamp.md5anim"];
    [animation addSelector:model];
    
    [animation Play];
    
    [m_testLayer addObject:model];
}


// ------------------------------------------------------------------------------ //
// ------------------------------------ Update ---------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Update

- (void)preUpdate
{
    
}

- (void)update:(float)time
{
    
}

- (void)posUpdate
{
    
}

// ------------------------------------------------------------------------------ //
// ------------------------------- Render - Layout ------------------------------ //
// ------------------------------------------------------------------------------ //
#pragma mark Render - Layout

- (void)render
{
    [m_testView render];
}

- (void)layoutForWidth:(float)width AndHeight:(float)height
{
    
}

@end