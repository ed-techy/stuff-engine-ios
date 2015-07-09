#import "IHgamecenter.h"

@interface IHGameCenter()
{
    __weak UIViewController* authentificationView;
    UIBackgroundTaskIdentifier backgroundProcess;
    NSArray* m_leaderboards;
    NSArray* m_achievementDescriptions;
    
    NSString* m_encryptionKey;
    NSData* m_encryptionKeyData;
}

- (bool)isGameCenterAvailable;
- (bool)isInternetAvailable;
- (void)setUpData:(NSString*)encryptedKey;


- (void)loadLeaderboards;
- (void)loadAchievementDescriptions;

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
            [self syncPlayer];
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

- (void)syncPlayer
{
    CleanLog(IH_VERBOSE, @"GameCenter: Syncing player data at the background...");
    
    if(!Available)
    {
        CleanLog(IH_VERBOSE, @"GameCenter: The GameCenter is not available.");
        return;
    }
    
    if(!Authenticated)
    {
        CleanLog(IH_VERBOSE, @"GameCenter: The player is not aunthenticated.");
        return;
    }
    
    // Ensure the task isn't interrupted even if the user exits the app
    backgroundProcess = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:backgroundProcess];
        backgroundProcess = UIBackgroundTaskInvalid;
    }];
    
    // Move the process to the background thread to avoid clogging up the UI
    dispatch_queue_t syncGameCenterOnBackgroundThread = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(syncGameCenterOnBackgroundThread, ^{
        
        [self loadLeaderboards];
        [self loadAchievementDescriptions];
        
    });
    
    // End the Background Process
    [[UIApplication sharedApplication] endBackgroundTask:backgroundProcess];
    backgroundProcess = UIBackgroundTaskInvalid;
}

- (void)loadLeaderboards
{
    CleanLog(IH_VERBOSE, @"GameCenter: Fetching leaderboards...");
    
    if(!Available)
    {
        CleanLog(IH_VERBOSE, @"GameCenter: The GameCenter is not available.");
        return;
    }
    
    if(!Authenticated)
    {
        CleanLog(IH_VERBOSE, @"GameCenter: The player is not aunthenticated.");
        return;
    }
    
    // Game Center leaderboards registered with the application.
    if (m_leaderboards == nil)
    {
        [GKLeaderboard loadLeaderboardsWithCompletionHandler:^(NSArray *leaderboards, NSError *error){
            if (leaderboards)
            {
                m_leaderboards = leaderboards;
                CleanLog(IH_VERBOSE, @"GameCenter: %d leaderboards.", leaderboards.count);
                for (GKLeaderboard* leaderboard in m_leaderboards)
                    CleanLog(IH_VERBOSE, @"            %@.", leaderboard.title);
            }
            else
            {
                CleanLog(IH_VERBOSE, @"GameCenter: %@", error.description);
            }
        }];
        return;
    }
    else
    {
        CleanLog(IH_VERBOSE, @"GameCenter: Leaderboards already loaded.");
    }
}

- (void)loadAchievementDescriptions
{
    CleanLog(IH_VERBOSE, @"GameCenter: Fetching achievements...");
    
    if(!Available)
    {
        CleanLog(IH_VERBOSE, @"GameCenter: The GameCenter is not available.");
        return;
    }
    
    if(!Authenticated)
    {
        CleanLog(IH_VERBOSE, @"GameCenter: The player is not aunthenticated.");
        return;
    }
    
    // Game Center achievements registered with the application.
    [GKAchievementDescription loadAchievementDescriptionsWithCompletionHandler:^(NSArray *descriptions, NSError *error) {
        if (descriptions)
        {
            m_achievementDescriptions = descriptions;
            CleanLog(IH_VERBOSE, @"GameCenter: %d achievements.", descriptions.count);
            for (GKAchievementDescription* description in m_achievementDescriptions)
                CleanLog(IH_VERBOSE, @"            %@.", description.title);
        }
        else
        {
            CleanLog(IH_VERBOSE, @"GameCenter: %@", error.description);
        }
    }];
}

// ------------------------------------------------------------------------------ //
// ---------------------------------- Presenting -------------------------------- //
// ------------------------------------------------------------------------------ //

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

@end