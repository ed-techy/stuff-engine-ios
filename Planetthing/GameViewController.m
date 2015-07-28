#import "GameViewController.h"

@interface GameViewController()
{
    GEUpdateCaller* m_updateCaller;
    GMmain* m_GMMain;
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
    
    // Initialize Game Center features.
    //[IHGameCenter sharedIntance].ViewDelegate = self;
    
    m_GMMain = [GMmain sharedIntance];
    m_updateCaller = [GEUpdateCaller sharedIntance];
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
    [m_GMMain render];
}

- (void)viewDidLayoutSubviews
{
    [m_GMMain layoutForWidth:@(self.view.bounds.size.width * 2) andHeight:@(self.view.bounds.size.height * 2)];
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
