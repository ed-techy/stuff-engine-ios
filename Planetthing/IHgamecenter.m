#import "IHgamecenter.h"

@interface IHGameCenter()
{
    __weak UIViewController* authentificationView;
    
    NSMutableDictionary* m_localPlayers;
    NSString* m_lastPlayer;
    
    NSString* m_encryptionKey;
    NSData* m_encryptionKeyData;
    
    int m_syncThreads;
    bool m_upToDate;
    bool m_initialSync;
}

- (bool)isGameCenterAvailable;
- (bool)isInternetAvailable;

- (void)authenticateLocalPlayer;
- (void)loadLocalPlayers;
- (void)syncCurrentPlayer;
- (void)loadFriedsData;
- (void)saveLocalPlayers;

- (void)setUpDataWithKey:(NSString*)key;
- (void)generateNewPlayerWithID:(NSString*)playerid andDisplayName:(NSString*)displayname;
- (void)genrateLocalData;

@end

@implementation IHGameCenter

@synthesize Available;
@synthesize Authenticated;
@synthesize LocalPlayer;
@synthesize LocalPlayerData;
@synthesize ViewDelegate;
@synthesize ControlDelegate;
@synthesize LocalPlayerFriends;

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
        CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: Shared instance was allocated for the first time.");
        sharedIntance = [IHGameCenter new];
    });
    
    return sharedIntance;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        // Do all the game center setup in the background.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            
            m_initialSync = true;
            
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
    
    CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: Authentificating player...");
    
    // Game center has to be available.
    if(!Available)
    {
        CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: The GameCenter is not available.");
        return;
    }
    
    // iOS 6 requires an authentificate handler block.
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error)
    {
        if(viewController && !error) // The player is not an authetificated player in the divice.
        {
            CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: The player is not anthentificated.");
    
            // Weak reference to know when it was dealocated.
            authentificationView = viewController;
            
            // Present the authentification Game Center view if the player was not aithentificated.
            if([ViewDelegate respondsToSelector:@selector(presentGameCenterAuthentificationView:)])
            {
                CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: Presenting authentification GameCenter view.");
                [ViewDelegate presentGameCenterAuthentificationView:viewController];
            }
            else
            {
                CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: There is not a selector that can present the sign in GameCenter view.");
            }
            
        }
        else if(error)
        {
            Authenticated = false;
            
            // Know the reason whay is not possible authentificate the user.
            if(![self isInternetAvailable])
            {
                CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: There is not internet connection.");
            }
            else if(error.code == 2)
            {
                CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: The user canceled the authentification operation.");
            }
            
            LocalPlayerData = m_localPlayers[m_lastPlayer];
            
            m_initialSync = false;
            
            CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: Last player -> %@.", LocalPlayerData[@"display_name"]);
        }
        else if([GKLocalPlayer localPlayer].isAuthenticated)
        {
            // The player was authenticated.
            Authenticated = true;
            
            // The the current player instance.
            LocalPlayer = [GKLocalPlayer localPlayer];
            CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: Player \"%@\" was successfully authentificated.", LocalPlayer.alias);
            
            // Keep traking of the users and create a record for them.
            if(m_localPlayers[localPlayer.playerID] == nil)
            {
                CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: New player creating record...");
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
        
        CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: Encryption Key Data created %@.", m_encryptionKeyData);
        
        /// Standar file mannger try to know if the player data is already in the disk.
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:GameCenterDataPath])
        {
            CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: Players data not found creating save file.");
            [self genrateLocalData];
            [self saveLocalPlayers];
            return;
        }
        
        NSData *testdata = [[NSData dataWithContentsOfFile:GameCenterDataPath] decryptedWithKey:m_encryptionKeyData];
        
        // Check if the data is not corrupted.
        if (testdata == nil)
        {
            CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: Players data corrupted creating new save file.");
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
        scoreD[@"context"] = @0;
        scoreD[@"date"] = [[NSDate alloc] initWithTimeIntervalSince1970:0];
        scoreD[@"order"] = leaderboard[2];
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
    
    CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: Sycing player with GameCenter.");
    
    m_syncThreads = (int)scores.count + 1;
    m_upToDate = true;
    
    // Friends
    [self loadFriedsData];
    
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
                 
                 CleanLog(GE_VERBOSE && IH_VERBOSE, @"            Leaderboard %@:", score.leaderboardIdentifier);
                 
                 NSString* order = scoreL[@"order"];
                 
                 if([order isEqual:@"greater"])
                 {
                     if([scoreL[@"value"] floatValue] < (double)score.value)
                     {
                         CleanLog(GE_VERBOSE && IH_VERBOSE, @"                Local      %@ -> %@.", scoreL[@"value"], scoreL[@"date"]);
                         CleanLog(GE_VERBOSE && IH_VERBOSE, @"                GameCenter %lldi -> %@. (getting)", score.value, score.date);
                         
                         m_upToDate = false;
                         
                         scoreL[@"value"] = @((double)score.value);
                         scoreL[@"date"] = score.date;
                     }
                     else if ([scoreL[@"value"] doubleValue] > (double)score.value)
                     {
                         CleanLog(GE_VERBOSE && IH_VERBOSE, @"                Local      %@ -> %@. (keeping and submiting)", scoreL[@"value"], scoreL[@"date"]);
                         CleanLog(GE_VERBOSE && IH_VERBOSE, @"                GameCenter %lldi -> %@.", score.value, score.date);
                         
                     }
                     else
                     {
                         CleanLog(GE_VERBOSE && IH_VERBOSE, @"                Local      %@ -> %@. (keeping)", scoreL[@"value"], scoreL[@"date"]);
                         CleanLog(GE_VERBOSE && IH_VERBOSE, @"                GameCenter %lldi -> %@.", score.value, score.date);
                     }
                 }
                 else
                 {
                     if([scoreL[@"value"] doubleValue] > (double)score.value)
                     {
                         CleanLog(GE_VERBOSE && IH_VERBOSE, @"                Local      %@ -> %@.", scoreL[@"value"], scoreL[@"date"]);
                         CleanLog(GE_VERBOSE && IH_VERBOSE, @"                GameCenter %lldi -> %@. (getting)", score.value, score.date);
                         
                         m_upToDate = false;
                         
                         scoreL[@"value"] = @((double)score.value);
                         scoreL[@"date"] = score.date;
                     }
                     else if ([scoreL[@"value"] floatValue] < (double)score.value)
                     {
                         CleanLog(GE_VERBOSE && IH_VERBOSE, @"                Local      %@ -> %@. (keeping and submiting)", scoreL[@"value"], scoreL[@"date"]);
                         CleanLog(GE_VERBOSE && IH_VERBOSE, @"                GameCenter %lldi -> %@.", score.value, score.date);
                         
                     }
                     else
                     {
                         CleanLog(GE_VERBOSE && IH_VERBOSE, @"                Local      %@ -> %@. (keeping)", scoreL[@"value"], scoreL[@"date"]);
                         CleanLog(GE_VERBOSE && IH_VERBOSE, @"                GameCenter %lldi -> %@.", score.value, score.date);
                     }
                 }
                 
                 m_syncThreads--;
                 
                 if(!m_syncThreads )
                 {
                     CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: Synchronization complete.");
                     
                     m_initialSync = false;
                     
                     if(!m_upToDate)
                         [self saveLocalPlayers];
                     else
                     {
                         CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: Up to date.");
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
                
                CleanLog(GE_VERBOSE && IH_VERBOSE, @"            Achievement %@:", achievement.identifier);
                
                if(achievement.percentComplete == [achievementC[@"percentage"] doubleValue])
                {
                    CleanLog(GE_VERBOSE && IH_VERBOSE, @"                Local      %@ -> %@. (keeping)", achievementC[@"percentage"], achievementC[@"date"]);
                    CleanLog(GE_VERBOSE && IH_VERBOSE, @"                GameCenter %fi -> %@.", achievement.percentComplete, achievement.lastReportedDate);
                    
                }
                else if(achievement.percentComplete > [achievementC[@"percentage"] doubleValue])
                {
                    CleanLog(GE_VERBOSE && IH_VERBOSE, @"                Local      %@ -> %@.", achievementC[@"percentage"], achievementC[@"date"]);
                    CleanLog(GE_VERBOSE && IH_VERBOSE, @"                GameCenter %fi -> %@. (getting)", achievement.percentComplete, achievement.lastReportedDate);
                    
                    m_upToDate = false;
                    
                    if(achievement.completed) achievementC[@"unlocked"] = @"yes";
                    achievementC[@"percentage"] = [[NSNumber alloc] initWithFloat:achievement.percentComplete];
                    achievementC[@"date"] = achievement.lastReportedDate;
                }
                else
                {
                    CleanLog(GE_VERBOSE && IH_VERBOSE, @"                Local      %@ -> %@. (keeping and submiting)", achievementC[@"percentage"], achievementC[@"date"]);
                    CleanLog(GE_VERBOSE && IH_VERBOSE, @"                GameCenter %fi -> %@.", achievement.percentComplete, achievement.lastReportedDate);
                    
                }
            }
        }
        
        m_syncThreads--;
        
        if(!m_syncThreads )
        {
            CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: Synchronization complete.");
            
            m_initialSync = false;
            
            if(!m_upToDate)
                [self saveLocalPlayers];
            else
            {
                CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: Up to date.");
            }
            
            // Rise event.
            if([ControlDelegate respondsToSelector:@selector(didPlayerDataSync)])
                [ControlDelegate didPlayerDataSync];
        }
    }];
    
}

- (void)loadFriedsData
{
    LocalPlayerFriends = [NSMutableDictionary new];
    
    // Get User fiends
    [LocalPlayer loadFriendsWithCompletionHandler:^(NSArray *friendIDs, NSError *error) {
        if(error)
        {
            CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: There was an error trying to load player's friends ids.");
        }
        else
        {
            [GKPlayer loadPlayersForIdentifiers:friendIDs withCompletionHandler:^(NSArray *players, NSError *error) {
                if (error)
                {
                    CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: There was an error trying to load player's friends data.");
                }
                else
                {
                    CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: The player has %lu friends.", (unsigned long)players.count);

                    for(GKPlayer* player in players)
                    {
                        LocalPlayerFriends[player.playerID] = [NSMutableDictionary new];
                        LocalPlayerFriends[player.playerID][@"player_id"] = player.playerID;
                        LocalPlayerFriends[player.playerID][@"display_name"] = player.alias;
                        LocalPlayerFriends[player.playerID][@"scores"] = [NSMutableDictionary new];
                    }
                    
                    m_syncThreads += GameCenterLeaderBoards.count;
                    
                    for(NSArray* leaderboard in GameCenterLeaderBoards)
                    {
                        GKLeaderboard* gkLeaderboard = [[GKLeaderboard alloc] initWithPlayers:players];
                        gkLeaderboard.identifier = leaderboard[0];
                        [gkLeaderboard loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
                            if(error)
                            {
                                CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: There was an error trying to load player's friends ids.");
                            }
                            else
                            {
                                for(GKScore* score in scores)
                                {
                                    LocalPlayerFriends[score.playerID][@"scores"][score.leaderboardIdentifier] = @((float)score.value);
                                }
                            }
                            m_syncThreads--;
                            
                            if(!m_syncThreads )
                            {
                                CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: Synchronization complete.");
                                
                                m_initialSync = false;
                                
                                if(!m_upToDate)
                                    [self saveLocalPlayers];
                                else
                                {
                                    CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: Up to date.");
                                }
                                
                                // Rise event.
                                if([ControlDelegate respondsToSelector:@selector(didPlayerDataSync)])
                                    [ControlDelegate didPlayerDataSync];
                            }
                        }];
                    }
                }
            }];
        }
    }];
}

- (void)loadLocalPlayers
{
    CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: Loading players data...");
    
    // Decrypt and create a new dictionary of users.
    NSData *playersData = [[NSData dataWithContentsOfFile:GameCenterDataPath] decryptedWithKey:m_encryptionKeyData];
    NSMutableDictionary* dataDic = [NSKeyedUnarchiver unarchiveObjectWithData:playersData];
    
    m_localPlayers = dataDic[@"players"];
    m_lastPlayer = dataDic[@"last_player"];
    
    CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: %lu local players.", (unsigned long)m_localPlayers.count);
    for(NSString* player in  m_localPlayers)
    {
        CleanLog(GE_VERBOSE && IH_VERBOSE, @"            Player: %@", m_localPlayers[player][@"display_name"]);
    }
}

- (void)saveLocalPlayers
{
    CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: Saving players data...");
    
    NSData *playersData = [[NSKeyedArchiver archivedDataWithRootObject:@{@"players" : m_localPlayers, @"last_player" : m_lastPlayer}] encryptedWithKey:m_encryptionKeyData];
    [playersData writeToFile:GameCenterDataPath atomically:YES];
    
    m_upToDate = true;
}

// ------------------------------------------------------------------------------ //
// ----------------------------------- Setters ---------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Setters

- (void)setScore:(NSNumber*)scoreValue andContext:(NSNumber*)context forIdentifier:(NSString*)identifier
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        // Wait for the initial sync
        while(m_initialSync)
            sleep(1);
        
        NSMutableDictionary* score = LocalPlayerData[@"scores"][identifier];
        
        NSString* order = score[@"order"];
        
        CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: Seting %@ for value %@.", identifier, scoreValue);
        
        bool submit = false;
        
        // Id the new score wortnhh it? save and submit
        if([order isEqual:@"greater"])
        {
            if([score[@"value"] doubleValue] < [scoreValue doubleValue])
            {
                m_upToDate = false;
                submit = true;
                
                score[@"value"] = scoreValue;
                score[@"context"] = context;
                score[@"date"] = [NSDate new];
            }
            else
            {
                CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: The new value is not worth.");
            }
        }
        else
        {
            if([score[@"value"] doubleValue] > [scoreValue doubleValue])
            {
                m_upToDate = false;
                submit = true;
                
                score[@"value"] = scoreValue;
                score[@"context"] = context;
                score[@"date"] = [NSDate new];
            }
            else
            {
                CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: The new value is not worth.");
            }
        }
        
        // If worth it submit
        if(submit && Authenticated)
        {
            GKScore *gkScore = [[GKScore alloc] initWithLeaderboardIdentifier:identifier player:LocalPlayer];
            gkScore.value = [scoreValue doubleValue];
            gkScore.context = [context doubleValue];
            
            CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: Submiting...");
            
            m_syncThreads++;
            
            [gkScore reportScoreWithCompletionHandler:^(NSError *error) {
                if(error)
                {
                    CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: There was an error trying to submit the score.");
                }
                
                m_syncThreads--;
                if(!m_syncThreads)
                {
                    CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: Synchronization complete.");
                    
                    if(!m_upToDate)
                        [self saveLocalPlayers];
                    
                    // Rise event.
                    if([ControlDelegate respondsToSelector:@selector(didPlayerDataSync)])
                        [ControlDelegate didPlayerDataSync];
                }
            }];
        }
        
    });
}

- (void)setAchievementProgress:(NSNumber*)progess forIdentifier:(NSString*)identifier
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        // Wait for the initial sync;
        while(m_initialSync)
            sleep(1000);
        
        NSMutableDictionary* achievement = LocalPlayerData[@"achievements"][identifier];
        
        CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: Seting %@ for progress %@.", identifier, progess);
        
        // Percenteg calculation base progress and goal
        achievement[@"progress"] = progess;
        if([achievement[@"progress"] integerValue] == [achievement[@"progress_goal"] integerValue])
            achievement[@"precenteage"] = @100.0f;
        else
            achievement[@"precenteage"] = @([achievement[@"progress_goal"] floatValue] / [progess floatValue]);
        
        // Submit if is a player authentificated.
        if(Authenticated)
        {
            GKAchievement *gkAchievement = [[GKAchievement alloc] initWithIdentifier:identifier player:LocalPlayer];
            gkAchievement.percentComplete = [achievement[@"precenteage"] doubleValue];
            
            if([achievement[@"precentage"] doubleValue] == 100.0)
                gkAchievement.showsCompletionBanner = YES;
            
            m_syncThreads++;
            
            CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: Submiting...");
            
            [gkAchievement reportAchievementWithCompletionHandler:^(NSError *error) {
                if(error)
                {
                    CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: There was an error trying to submit the achievement.");
                }
                
                m_syncThreads--;
                if(!m_syncThreads)
                {
                    CleanLog(GE_VERBOSE && IH_VERBOSE, @"GameCenter: Synchronization complete.");
                    
                    if(!m_upToDate)
                        [self saveLocalPlayers];
                    
                    // Rise event.
                    if([ControlDelegate respondsToSelector:@selector(didPlayerDataSync)])
                        [ControlDelegate didPlayerDataSync];
                }
            }];
        }
    });
}

// ------------------------------------------------------------------------------ //
// ----------------------------------- Getters --------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Getters

- (NSMutableDictionary*)getScoreForIdentifier:(NSString*)identifier
{
    return LocalPlayerData[@"scores"][identifier];
}

- (NSMutableDictionary*)getAchievementForIdentifier:(NSString*)identifier
{
    return LocalPlayerData[@"achievements"][identifier];
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