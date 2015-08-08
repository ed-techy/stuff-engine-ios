#import "GEfullscreen.h"
#import "GEanimatedmodel.h"
#import "GElayer.h"
#import "GEfbo.h"
#import "GEfont.h"

@interface GEView : NSObject

// -------------------------------------------- //
// ---------------- Properties ---------------- //
// -------------------------------------------- //
#pragma mark Properties
@property GLKVector3 BackgroundColor;
@property float Opasity;
@property (readonly)NSMutableDictionary* Layers;

// -------------------------------------------- //
// ------------------ Layers ------------------ //
// -------------------------------------------- //
#pragma mark Layers

- (GELayer*)addLayerWithName:(NSString*)name;
- (void)addLayerWithLayer:(GELayer*)layer;
- (GELayer*)getLayerWithName:(NSString*)name;
- (void)removeLayerWithName:(NSString*)name;
- (void)removeLayer:(GELayer*)layer;

// -------------------------------------------- //
// ------------------ Lights ------------------ //
// -------------------------------------------- //
#pragma mark Lights
- (void)addLight:(GELight*)light;
- (void)removeLight:(GELight*)light;
- (void)cleanLights;

// -------------------------------------------- //
// ------------------ Render ------------------ //
// -------------------------------------------- //
#pragma mark Render

- (void)render;

@end
