#import "IHgamecenter.h"

@interface IHGameCenter()
{
    __weak UIViewController* authentificationView;
    UIBackgroundTaskIdentifier backgroundProcess;
    NSArray* m_leaderboards;
    NSArray* m_achievementDescriptions;
    
    NSMutableDictionary* localPlayers;
    
    NSString* m_encryptionKey;
    NSData* m_encryptionKeyData;
}

- (bool)isGameCenterAvailable;
- (bool)isInternetAvailable;
- (void)setUpData:(NSString*)encryptedKey;

@end

@implementation IHGameCenter

@synthesize Available;
@synthesize Authenticated;
@synthesize LocalPlayer;
@synthesize ViewDelegate;
@synthesize ControlDelegate;

// ------------------------------------------------------------------------------ //
// ---------------------------- Game Center singleton --------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark GameCenter Singleton

+ (instancetype)sharedIntance
{
    static IHGameCenter* sharedIntance;
    static dispatch_once_t onceToken;
    
    // Know if the shared instance was already allocated.
    dispatch_once(&onceToken, ^{
        CleanLog(IH_VERBOSE, @"GameCenter: Shared GameCenter instance was allocated for the first time.");
        sharedIntance = [[IHGameCenter alloc] init];
    });
    
    return sharedIntance;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        // GameCenter availability.
        Available = [self isGameCenterAvailable];
        
        // Setup.
        [self setUpData:@"PlativolosMarinela"];
        [self authenticateLocalPlayer];
    }
    
    return self;
}

// ------------------------------------------------------------------------------ //
// ------------------------------ Game Center setup ----------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark GameCenter setup

- (bool)isGameCenterAvailable
{
    BOOL localPlayerClassAvailable = (NSClassFromString(@"GKLocalPlayer")) != nil;
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (localPlayerClassAvailable && osVersionSupported);
}

- (void)authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    CleanLog(IH_VERBOSE, @"GameCenter: Authentificating player...");
    
    if(!Available)
    {
        CleanLog(IH_VERBOSE, @"GameCenter: The GameCenter is not available.");
        return;
    }
    
    // iOS 6 requires an authentificate handler block.
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error)
    {
        if(viewController && !error) // The player is not an authetificated player in the divice.
        {
            CleanLog(IH_VERBOSE, @"GameCenter: The player is not anthentificated.");
    
            // Weak reference to know when it was dealocated.
            authentificationView = viewController;
            
            // Present the authentification Game Center view if the player was not aithentificated.
            if([ViewDelegate respondsToSelector:@selector(presentGameCenterAuthentificationView:)])
            {
                CleanLog(IH_VERBOSE, @"GameCenter: Presenting authentification GameCenter view.");
                [ViewDelegate presentGameCenterAuthentificationView:viewController];
            }
            else
            {
                CleanLog(IH_VERBOSE, @"GameCenter: There is not a selector that can present the sign in GameCenter view.");
            }
            
        }
        else if(error)
        {
            Authenticated = false;
            
            if(![self isInternetAvailable])
            {
                CleanLog(IH_VERBOSE, @"GameCenter: There is not internet connection.");
            }
            else if(error.code == 2)
            {
                CleanLog(IH_VERBOSE, @"GameCenter: The user canceled the authentification operation.");
            }
        }
        else if([GKLocalPlayer localPlayer].isAuthenticated)
        {
            Authenticated = true;
            LocalPlayer = [GKLocalPlayer localPlayer];
            CleanLog(IH_VERBOSE, @"GameCenter: Player \"%@\" was successfully authentificated.", LocalPlayer.alias);
        }
    };
}

- (void)setUpData:(NSString*)encryptionKey
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        m_encryptionKey = encryptionKey;
        m_encryptionKeyData = [encryptionKey dataUsingEncoding:NSUTF8StringEncoding];
        
        CleanLog(IH_VERBOSE, @"GameCenter: Encryption Key Data created %@.", m_encryptionKeyData);
    });
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

// ------------------------------------------------------------------------------ //
// ---------------------------- Player Synchronization -------------------------- //
// ------------------------------------------------------------------------------ //




// ------------------------------------------------------------------------------ //
// ---------------------------------- Presenting -------------------------------- //
// ------------------------------------------------------------------------------ //

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

@end