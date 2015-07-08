#import "GameViewController.h"
#import <OpenGLES/ES2/glext.h>

@interface GameViewController()
{

}
@property (strong, nonatomic) EAGLContext *context;

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context)
        NSLog(@"Failed to create ES context");
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [IHGameCenter sharedIntance].MainView = self;
    [[IHGameCenter sharedIntance] authenticateLocalPlayer];
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

- (void)update
{

}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{

}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    
}

@end
