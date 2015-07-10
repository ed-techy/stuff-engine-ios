#import "IHgamecenter.h"

@interface IHGameCenter()
{
    __weak UIViewController* authentificationView;
    
    NSMutableDictionary* m_localPlayers;
    
    NSString* m_encryptionKey;
    NSData* m_encryptionKeyData;
}

- (bool)isGameCenterAvailable;
- (bool)isInternetAvailable;
- (void)setUpData:(NSString*)encryptedKey;
- (void)generateNewPlayerWithID:(NSString*)playerid andDisplayName:(NSString*)displayname;
- (void)genrateLocalData;
- (void)loadLocalPlayers;
- (void)saveLocalPlayers;

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
        // Do all the game center setup in the background.
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            // GameCenter availability.
            Available = [self isGameCenterAvailable];
            
            // Setup.
            [self setUpData:@"PlativolosMarinela"];
            
            // Local
            [self loadLocalPlayers];
            
            // Aunthentification
            [self authenticateLocalPlayer];
        });
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
            
            if(m_localPlayers[localPlayer.playerID] == nil)
            {
                CleanLog(IH_VERBOSE, @"GameCenter: New player creating record...");
                [self generateNewPlayerWithID:LocalPlayer.playerID andDisplayName:LocalPlayer.alias];
                [self saveLocalPlayers];
            }
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
        
        /// Standar file mannger try to know if the player data is already in the disk.
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:GameCenterDataPath])
        {
            CleanLog(IH_VERBOSE, @"GameCenter: Players data not found creating save file.");
            [self genrateLocalData];
            [self saveLocalPlayers];
        }
        
        
        NSData *testdata = [[NSData dataWithContentsOfFile:GameCenterDataPath] decryptedWithKey:m_encryptionKeyData];
        
        // Check if the data is not corrupted.
        if (testdata == nil)
        {
            CleanLog(IH_VERBOSE, @"GameCenter: Players data corrupted creating new save file.");
            [self genrateLocalData];
            [self saveLocalPlayers];
        }
    });
}

- (void)generateNewPlayerWithID:(NSString*)playerid andDisplayName:(NSString*)displayname
{
    m_localPlayers[playerid] = [NSMutableDictionary dictionary];
    
    NSMutableDictionary* localPlayer = m_localPlayers[playerid];
    localPlayer[@"display_name"] = displayname;
    localPlayer[@"scores"] = [NSMutableDictionary dictionary];
    localPlayer[@"achievements"] = [NSMutableDictionary dictionary];
    
    
    NSMutableDictionary* scores = localPlayer[@"scores"];
    NSMutableDictionary* achievements = localPlayer[@"achievements"];
    
    for(NSArray* leaderboard in GameCenterLeaderBoards)
        scores[leaderboard[0]] = leaderboard[1];
    
    for(NSArray* achivement in GameCenterAchievements)
    {
        achievements[achivement[0]] = [NSMutableDictionary dictionary];
        NSMutableDictionary* achivementD = achievements[achivement[0]];
        achivementD[@"unlocked"] = @"no";
        achivementD[@"progress"] = achivement[1];
        achivementD[@"progress_goal"] = achivement[2];
    }
}

- (void)genrateLocalData
{
    m_localPlayers = [NSMutableDictionary dictionary];
    [self generateNewPlayerWithID:@"local_player" andDisplayName:@"Local Player"];
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

- (void)loadLocalPlayers
{
    CleanLog(IH_VERBOSE, @"GameCenter: Loading players data...");
    
    // Decrypt and create a new dictionary of users.
    NSData *playersData = [[NSData dataWithContentsOfFile:GameCenterDataPath] decryptedWithKey:m_encryptionKeyData];
    m_localPlayers = [NSKeyedUnarchiver unarchiveObjectWithData:playersData];
    
    CleanLog(IH_VERBOSE, @"GameCenter: %d local players.", m_localPlayers.count);
    for(NSString* player in  m_localPlayers)
    {
        CleanLog(IH_VERBOSE, @"            Player: %@", m_localPlayers[player][@"display_name"]);
    }
}

- (void)saveLocalPlayers
{
    CleanLog(IH_VERBOSE, @"GameCenter: Saving players data...");
    
    NSData *playersData = [[NSKeyedArchiver archivedDataWithRootObject:m_localPlayers] encryptedWithKey:m_encryptionKeyData];
    [playersData writeToFile:GameCenterDataPath atomically:YES];
}


// ------------------------------------------------------------------------------ //
// ---------------------------------- Presenting -------------------------------- //
// ------------------------------------------------------------------------------ //

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

@end