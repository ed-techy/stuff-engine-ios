// -------------------------------------------- //
// ------------- VERBOSE SECTIONS ------------- //
// -------------------------------------------- //

// Game verbose
#define GAME_VERBOSE true // Global verbose
#define GM_VERBOSE true // Game Main verbose

// Game Engine verbose
#define GE_VERBOSE true // Global verbose
#define IH_VERBOSE true // iOS Helper verbose
#define RB_VERBOSE true // Render Box verbose
#define CT_VERBOSE true // Context verbose
#define TX_VERBOSE true // Texture verbose
#define SH_VERBOSE true // Shader verbose
#define FS_VERBOSE true // Full screen verbose
#define AM_VERBOSE true // Animated model verbose
#define AT_VERBOSE true // Animation verbose
#define FN_VERBOSE true // Font verbose

// -------------------------------------------- //
// ----------------- CLEAN LOG ---------------- //
// -------------------------------------------- //

#define CleanLog(CONTEXT, FORMAT, ...) if(CONTEXT)printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);


// -------------------------------------------- //
// ---------- Game Center Info (Game) --------- //
// -------------------------------------------- //

#define GameCenterLeaderBoards @[ @[@"planetthing_test_leaderboard_1", @0, @"greater"], @[@"planetthing_test_leaderboard_2", @0, @"least"], @[@"planetthing_test_leaderboard_3", @0, @"greater"] ]
#define GameCenterAchievements @[ @[@"planettin_achievement_test1", @0, @0], @[@"planettin_achievement_test2", @0, @10], @[@"planettin_achievement_test3", @0, @100] ]
