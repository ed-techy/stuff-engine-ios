#import "GameViewController.h"

@interface GameViewController()
{
    GEUpdateCaller* m_updateCaller;
}
@property (strong, nonatomic) EAGLContext *context;

@end

@implementation GameViewController

// ------------------------------------------------------------------------------ //
// ------------------------------ View Load - Unload ---------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark View Load - Unload

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context)
        NSLog(@"Failed to create ES context");
    
    // Basic draw properties
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [EAGLContext setCurrentContext:self.context];
    
    // Initialize Context Mannager
    [GEContext sharedIntance].ContextView = view;
    
    // Initialize the updater
    m_updateCaller = [GEUpdateCaller sharedIntance];
    
    // Game Center delegate
    //[IHGameCenter sharedIntance].ViewDelegate = self;
    
    // Initalize the Game
    [GMmain sharedIntance];
}

- (void)dealloc
{
    if ([EAGLContext currentContext] == self.context)
        [EAGLContext setCurrentContext:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil))
    {
        self.view = nil;
        
        if ([EAGLContext currentContext] == self.context)
            [EAGLContext setCurrentContext:nil];

        self.context = nil;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

// ------------------------------------------------------------------------------ //
// -------------------------- Update - Render - Layout -------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Update - Render - Layout

- (void)update
{
    [m_updateCaller preUpdate];
    
    [m_updateCaller update:self.timeSinceLastUpdate];
    
    [m_updateCaller posUpdate];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glFrontFace(GL_CW);
    glEnable(GL_CULL_FACE);
    
    [m_updateCaller render];
}

- (void)viewDidLayoutSubviews
{
    [m_updateCaller layoutForWidth:self.view.bounds.size.width * 2.0f AndHeight:self.view.bounds.size.height * 2.0f];
}

// ------------------------------------------------------------------------------ //
// ------------------------------ View Presentation ----------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark View Presentation

- (void)presentGameCenterAuthentificationView:(UIViewController *)gameCenterLoginController
{
    [self presentViewController:gameCenterLoginController animated:YES completion:nil];
}

@end
