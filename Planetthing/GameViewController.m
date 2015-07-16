#import "GameViewController.h"

@interface GameViewController()
{
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
    
    // Initialize Context Mannager
    [GEContext sharedIntance].ContextView = view;
    
    // Initialize Game Center features.
    [IHGameCenter sharedIntance].ViewDelegate = self;
    
    m_GMMain = [GMmain sharedIntance];
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
// --------------------------- Frame - Render - Layout -------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Frame - Render - Layout

- (void)update
{
    [m_GMMain frame:self.timeSinceLastUpdate];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [m_GMMain render];
}

- (void)viewDidLayoutSubviews
{
    [m_GMMain layoutForWidth:@(self.view.bounds.size.width) andHeight:@(self.view.bounds.size.height)];
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
