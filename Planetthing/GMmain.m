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
        m_gameCenter = [IHGameCenter sharedIntance];
        
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
    
    GELight* light = [GELight new];
    //light.LightType = GE_LIGHT_SPOT;
    light.Position = GLKVector3Make(-100.0f, 60.0f, 10.0f);
    //light.Direction = GLKVector3Make(0.0f, 30.0f, 0.0f);
    light.Intensity = 0.5f;
    light.CastShadows = true;
    
    GELight* light2 = [GELight new];
    //light2.LightType = GE_LIGHT_POINT;
    light2.Position = GLKVector3Make(0.0f, 100.0f, -20.0f);
    //light2.DiffuseColor = GLKVector3Make(0.0f, 0.0f, 1.0f);
    light2.Intensity = 1.0f;
    light2.CastShadows = true;
    
    [m_testView addLight:light];
    [m_testView addLight:light2];
    
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