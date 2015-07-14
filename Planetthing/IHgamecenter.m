#import "IHgamecenter.h"

@interface IHGameCenter()
{
    __weak UIViewController* authentificationView;
    
    NSMutableDictionary* m_localPlayers;
    NSString* m_lastPlayer;
    
    NSString* m_encryptionKey;
    NSData* m_encryptionKeyData;
    
    unsigned int m_syncThreads;
    bool m_upToDate;
}

- (bool)isGameCenterAvailable;
- (bool)isInternetAvailable;
- (void)setUpDataWithKey:(NSString*)key;
- (void)generateNewPlayerWithID:(NSString*)playerid andDisplayName:(NSString*)displayname;
- (void)genrateLocalData;
- (void)loadLocalPlayers;
- (void)saveLocalPlayers;
- (void)syncCurrentPlayer;

@end

@implementation IHGameCenter

@synthesize Available;
@synthesize Authenticated;
@synthesize LocalPlayer;
@synthesize LocalPlayerData;
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
            [self setUpDataWithKey:@"PlativolosMarinela"];
            
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
    // Know if the local GKLocalPlayer class exixst
    BOOL localPlayerClassAvailable = (NSClassFromString(@"GKLocalPlayer")) != nil;
    
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    // The current vesion is greater than 4.1
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (localPlayerClassAvailable && osVersionSupported);
}

- (void)authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    CleanLog(IH_VERBOSE, @"GameCenter: Authentificating player...");
    
    // Game center has to be available.
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
            
            // Kow the reason whay is not possible authentificate the user.
            if(![self isInternetAvailable])
            {
                CleanLog(IH_VERBOSE, @"GameCenter: There is not internet connection.");
            }
            else if(error.code == 2)
            {
                CleanLog(IH_VERBOSE, @"GameCenter: The user canceled the authentification operation.");
            }
            
            LocalPlayerData = m_localPlayers[m_lastPlayer];
            
            CleanLog(IH_VERBOSE, @"GameCenter: Last player -> %@.", LocalPlayerData[@"display_name"]);
        }
        else if([GKLocalPlayer localPlayer].isAuthenticated)
        {
            // The player was authenticated.
            Authenticated = true;
            
            // The the current player instance.
            LocalPlayer = [GKLocalPlayer localPlayer];
            CleanLog(IH_VERBOSE, @"GameCenter: Player \"%@\" was successfully authentificated.", LocalPlayer.alias);
            
            // Keep traking of the users and create a record for them.
            if(m_localPlayers[localPlayer.playerID] == nil)
            {
                CleanLog(IH_VERBOSE, @"GameCenter: New player creating record...");
                [self generateNewPlayerWithID:LocalPlayer.playerID andDisplayName:LocalPlayer.alias];
                
                LocalPlayerData = m_localPlayers[LocalPlayer.playerID];
                m_lastPlayer = LocalPlayerData[@"player_id"];
            }
            else
            {
                
                LocalPlayerData = m_localPlayers[LocalPlayer.playerID];
                m_lastPlayer = LocalPlayerData[@"player_id"];
                
            }
            
            [self saveLocalPlayers];
            [self syncCurrentPlayer];
        }
    };
}

- (void)setUpDataWithKey:(NSString*)key
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        m_encryptionKey = key;
        m_encryptionKeyData = [key dataUsingEncoding:NSUTF8StringEncoding];
        
        CleanLog(IH_VERBOSE, @"GameCenter: Encryption Key Data created %@.", m_encryptionKeyData);
        
        /// Standar file mannger try to know if the player data is already in the disk.
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:GameCenterDataPath])
        {
            CleanLog(IH_VERBOSE, @"GameCenter: Players data not found creating save file.");
            [self genrateLocalData];
            [self saveLocalPlayers];
            return;
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
    localPlayer[@"player_id"] = playerid;
    localPlayer[@"scores"] = [NSMutableDictionary dictionary];
    localPlayer[@"achievements"] = [NSMutableDictionary dictionary];
    
    
    NSMutableDictionary* scores = localPlayer[@"scores"];
    NSMutableDictionary* achievements = localPlayer[@"achievements"];
    
    for(NSArray* leaderboard in GameCenterLeaderBoards)
    {
        scores[leaderboard[0]] = [NSMutableDictionary dictionary];
        NSMutableDictionary* scoreD = scores[leaderboard[0]];
        scoreD[@"value"] = leaderboard[1];
        scoreD[@"date"] = [[NSDate alloc] initWithTimeIntervalSince1970:0];
    }
    
    
    for(NSArray* achivement in GameCenterAchievements)
    {
        achievements[achivement[0]] = [NSMutableDictionary dictionary];
        NSMutableDictionary* achivementD = achievements[achivement[0]];
        achivementD[@"unlocked"] = @"no";
        achivementD[@"percentage"] = @0;
        achivementD[@"progress"] = achivement[1];
        achivementD[@"progress_goal"] = achivement[2];
        achivementD[@"date"] = [[NSDate alloc] initWithTimeIntervalSince1970:0];
    }
}

- (void)genrateLocalData
{
    m_localPlayers = [NSMutableDictionary dictionary];
    m_lastPlayer = @"local_player";
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
#pragma mark Player Synchronization

- (void)syncCurrentPlayer
{
    NSMutableDictionary* scores = LocalPlayerData[@"scores"];
    
    CleanLog(IH_VERBOSE, @"GameCenter: Sycing player with GameCenter.");
    
    m_syncThreads = scores.count + 1;
    m_upToDate = true;
    
    for(NSString* score in scores)
    {
        GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] initWithPlayers:@[LocalPlayer]];
        
        if (leaderboardRequest != nil)
        {
            leaderboardRequest.identifier = score;
            
            // make the request for the score for the current player.
            [leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error)
             {
                 GKScore* score = scores[0];
                 NSMutableDictionary* scoreL = LocalPlayerData[@"scores"][score.leaderboardIdentifier];
                 
                 CleanLog(IH_VERBOSE, @"            Leaderboard %@:", score.leaderboardIdentifier);
                 
                 if([score.date compare:scoreL[@"date"]] == NSOrderedDescending)
                 {
                     CleanLog(IH_VERBOSE, @"                Local      %@ -> %@.", scoreL[@"value"], scoreL[@"date"]);
                     CleanLog(IH_VERBOSE, @"                GameCenter %lldi -> %@. (getting)", score.value, score.date);
                     
                     m_upToDate = false;
                     
                     scoreL[@"value"] = [[NSNumber alloc] initWithUnsignedInt:(unsigned int)score.value];
                     scoreL[@"date"] = score.date;
                 }
                 else if([score.date compare:scoreL[@"date"]] == NSOrderedAscending)
                 {
                     CleanLog(IH_VERBOSE, @"                Local      %@ -> %@. (keeping and submiting)", scoreL[@"value"], scoreL[@"date"]);
                     CleanLog(IH_VERBOSE, @"                GameCenter %lldi -> %@.", score.value, score.date);
                     
                 }
                 else
                 {
                     CleanLog(IH_VERBOSE, @"                Local      %@ -> %@. (keeping)", scoreL[@"value"], scoreL[@"date"]);
                     CleanLog(IH_VERBOSE, @"                GameCenter %lldi -> %@.", score.value, score.date);
                 }
                 
                 m_syncThreads--;
                 
                 if(!m_syncThreads )
                 {
                     CleanLog(IH_VERBOSE, @"GameCenter: Synchronization complete.");
                     
                     if(!m_upToDate)
                         [self saveLocalPlayers];
                     else
                     {
                         CleanLog(IH_VERBOSE, @"GameCenter: Up to date.");
                     }
                     
                     // Rise event.
                     if([ControlDelegate respondsToSelector:@selector(didPlayerDataSync)])
                         [ControlDelegate didPlayerDataSync];
                 }
                     
             }];
        }
    }
    
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        
        NSMutableDictionary* achievementsL = LocalPlayerData[@"achievements"];
        
        if(achievements != nil)
        {
            for(GKAchievement* achievement in achievements)
            {
                NSMutableDictionary* achievementC = achievementsL[achievement.identifier];
                
                CleanLog(IH_VERBOSE, @"            Achievement %@:", achievement.identifier);
                
                if(achievement.percentComplete == [achievementC[@"percentage"] floatValue])
                {
                    CleanLog(IH_VERBOSE, @"                Local      %@ -> %@. (keeping)", achievementC[@"percentage"], achievementC[@"date"]);
                    CleanLog(IH_VERBOSE, @"                GameCenter %fi -> %@.", achievement.percentComplete, achievement.lastReportedDate);
                    
                }
                else if(achievement.percentComplete > [achievementC[@"percentage"] floatValue])
                {
                    CleanLog(IH_VERBOSE, @"                Local      %@ -> %@.", achievementC[@"percentage"], achievementC[@"date"]);
                    CleanLog(IH_VERBOSE, @"                GameCenter %fi -> %@. (getting)", achievement.percentComplete, achievement.lastReportedDate);
                    
                    m_upToDate = false;
                    
                    if(achievement.percentComplete == 100) achievementC[@"unlocked"] = @"yes";
                    achievementC[@"percentage"] = [[NSNumber alloc] initWithFloat:achievement.percentComplete];
                    achievementC[@"date"] = achievement.lastReportedDate;
                }
                else
                {
                    CleanLog(IH_VERBOSE, @"                Local      %@ -> %@. (keeping and submiting)", achievementC[@"percentage"], achievementC[@"date"]);
                    CleanLog(IH_VERBOSE, @"                GameCenter %fi -> %@.", achievement.percentComplete, achievement.lastReportedDate);
                }
            }
        }
        
        m_syncThreads--;
        
        if(!m_syncThreads )
        {
            CleanLog(IH_VERBOSE, @"GameCenter: Synchronization complete.");
            
            if(!m_upToDate)
                [self saveLocalPlayers];
            else
            {
                CleanLog(IH_VERBOSE, @"GameCenter: Up to date.");
            }
            
            // Rise event.
            if([ControlDelegate respondsToSelector:@selector(didPlayerDataSync)])
                [ControlDelegate didPlayerDataSync];
        }
    }];
    
}

- (void)loadLocalPlayers
{
    CleanLog(IH_VERBOSE, @"GameCenter: Loading players data...");
    
    // Decrypt and create a new dictionary of users.
    NSData *playersData = [[NSData dataWithContentsOfFile:GameCenterDataPath] decryptedWithKey:m_encryptionKeyData];
    NSMutableDictionary* dataDic = [NSKeyedUnarchiver unarchiveObjectWithData:playersData];
    
    m_localPlayers = dataDic[@"players"];
    m_lastPlayer = dataDic[@"last_player"];
    
    CleanLog(IH_VERBOSE, @"GameCenter: %d local players.", m_localPlayers.count);
    for(NSString* player in  m_localPlayers)
    {
        CleanLog(IH_VERBOSE, @"            Player: %@", m_localPlayers[player][@"display_name"]);
    }
}

- (void)saveLocalPlayers
{
    CleanLog(IH_VERBOSE, @"GameCenter: Saving players data...");
    
    NSData *playersData = [[NSKeyedArchiver archivedDataWithRootObject:@{@"players" : m_localPlayers, @"last_player" : m_lastPlayer}] encryptedWithKey:m_encryptionKeyData];
    [playersData writeToFile:GameCenterDataPath atomically:YES];
}


// ------------------------------------------------------------------------------ //
// ---------------------------------- Presenting -------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Presenting

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

@end