#import "IHgamecenter.h"

@interface IHGameCenter()
{
    __weak UIViewController* authentificationView;
}

- (bool)isInternetAvailable;

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
        IHLog(IH_VERBOSE, @"GameCenter: Shared Game Center instance was allocated for the first time.");
    });
    
    return sharedIntance;
}

- (void)authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    IHLog(IH_VERBOSE, @"GameCenter: Authentificating player...");
    
    // iOS 6 requires an authentificat handler block.
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error)
    {
        if(viewController && !error) // The player is not authetificated because the credentials were not filled.
        {
            IHLog(IH_VERBOSE, @"GameCenter: The player is not anthentificated.");
    
            // Weak reference to know when it was dealocated.
            authentificationView = viewController;
            
            // Present the authentification Game Center view if the player was not aithentificated.
            if(MainView)
            {
                IHLog(IH_VERBOSE, @"GameCenter: Presenting authentification Game Center view.");
                [MainView presentViewController:viewController animated:YES completion:nil];
            }
            else
            {
                IHLog(IH_VERBOSE, @"GameCenter: A main view is not specified the authentification Game Center vew can't be presented.");
            }
            
        }
        else if(error)
        {
            Authenticated = false;
            
            if(![self isInternetAvailable])
            {
                IHLog(IH_VERBOSE, @"GameCenter: There is not internet connection.");
            }
            else if(error.code == 2)
            {
                IHLog(IH_VERBOSE, @"GameCenter: The user canceled the authentification operation.");
            }
        }
        else if([GKLocalPlayer localPlayer].isAuthenticated)
        {
            Authenticated = true;
            LocalPlayer = [GKLocalPlayer localPlayer];
            IHLog(IH_VERBOSE, @"GameCenter: Player \"%@\" was successfully authentificated.", LocalPlayer.alias);
        }
    };
}


- (bool)isInternetAvailable
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    if (internetStatus == NotReachable)
        return false;
    else
        return true;
}

@end