#import "GameViewController.h"

@interface GameViewController()
{
    GMmain* m_GMMain;
    GETexture* texture;
    GEFullScreen* fullScreen;
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
    
    texture = [GETexture textureFromFileName:@"hotwasser_512_512.png"];
    fullScreen = [GEFullScreen sharedIntance];
    fullScreen.TextureID = texture.TextureID;
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
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glBlendEquation(GL_FUNC_ADD);
    [fullScreen render];
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
