#import "IHgamecenter.h"

@interface IHGameCenter()
{
    __weak UIViewController* authentificationView;
}

@end

@implementation IHGameCenter

@synthesize MainView;
@synthesize Authenticated;
@synthesize LocalPlayer;

+ (instancetype)sharedIntance
{
    static IHGameCenter* sharedIntance;
    static dispatch_once_t onceToken;
    
    // Know if the shared instance was already allocated.
    dispatch_once(&onceToken, ^{
        sharedIntance = [[IHGameCenter alloc] init];
#if defined(IH_VERBOSE)
        NSLog(@"GameCenter: Shared Game Center instance was allocated for the first time.");
#endif
    });
    
    return sharedIntance;
}

- (void)authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
#if defined(IH_VERBOSE)
    NSLog(@"GameCenter: Authentificating player...");
#endif
    
    // iOS 6 requires an authentificat handler block.
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error)
    {
        if(viewController && !error) // The player is not authetificated because the credentials were not filled.
        {
#if defined(IH_VERBOSE)
            NSLog(@"GameCenter: The player is not anthentificated.");
#endif
            // Weak reference to know when it was dealocated.
            authentificationView = viewController;
            
            // Present the authentification Game Center view if the player was not aithentificated.
            if(MainView)
            {
#if defined(IH_VERBOSE)
                NSLog(@"GameCenter: Presenting authentification Game Center view.");
#endif
                [MainView presentViewController:viewController animated:YES completion:nil];
            }
            else
            {
#if defined(IH_VERBOSE)
                NSLog(@"GameCenter: A main view is not specified the authentification Game Center vew can't be presented.");
#endif
            }
            
        }
        else if([GKLocalPlayer localPlayer].isAuthenticated)
        {
            Authenticated = true;
            LocalPlayer = [GKLocalPlayer localPlayer];
            
#if defined(IH_VERBOSE)
            NSLog(@"GameCenter: Player \"%@\" was successfully authentificated.", LocalPlayer.alias);
#endif
        }
        else
        {
#if defined(IH_VERBOSE)
            NSLog(@"GameCenter: The player was already authentificated.");
#endif
            Authenticated = true;
        }
    };
}

@end