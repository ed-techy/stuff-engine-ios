#ifndef IOSHelper_gamecenter_h
#define IOSHelper_gamecenter_h

#import <GameKit/GameKit.h>
#import "Reachability.h"
#import "IHglobals.h"

@interface IHGameCenter : NSObject

// --------------- Properties ----------------- //
// View where the Game Center functionality will be displayed from.
@property (readonly)bool Authenticated;
@property (readonly)GKPlayer* LocalPlayer;

@property UIViewController<GKGameCenterControllerDelegate>* MainView;

// -------------------------------------------- //

// ---------- No intanced Functions ----------- //
// Share a unique instance all over the aplication.
+ (instancetype)sharedIntance;


// -------------------------------------------- //


// ------------ Public Functions -------------- //
// Try to auntentificate the local player.
- (void)authenticateLocalPlayer;

@end

#endif
