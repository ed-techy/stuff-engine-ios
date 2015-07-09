#import <GameKit/GameKit.h>
#import "Reachability.h"
#import "NSDataAES256.h"
#import "IHglobals.h"

#define LIBRARY_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Library"]
#define GameCenterDataFile @"game_center.plist"
#define GameCenterDataPath [LIBRARY_FOLDER stringByAppendingPathComponent:GameCenterDataFile]

@class IHGameCenter;
@protocol IHGameCenterViewDelegate;
@protocol IHGameCenterControlDelegate;

@interface IHGameCenter : NSObject<GKGameCenterControllerDelegate>

// -------------------------------------------- //
// ---------------- Properties ---------------- //
// -------------------------------------------- //
@property (readonly)bool Available;
@property (readonly)bool Authenticated;
@property (readonly)GKPlayer* LocalPlayer;
@property id<IHGameCenterViewDelegate> ViewDelegate;
@property id<IHGameCenterControlDelegate> ControlDelegate;


// -------------------------------------------- //
// ------------- Singleton / SetUp ------------ //
// -------------------------------------------- //
+ (instancetype)sharedIntance;

// -------------------------------------------- //
// ------------- Public Functions ------------- //
// -------------------------------------------- //
- (void)authenticateLocalPlayer;
- (void)syncPlayer;


@end

// iOS Helper GameCenter Delegate. Know when the stuff is done.
@protocol IHGameCenterViewDelegate <NSObject>

@required
- (void)presentGameCenterAuthentificationView:(UIViewController *)gameCenterLoginController;

@end

@protocol IHGameCenterControlDelegate <NSObject>



@optional

@end

