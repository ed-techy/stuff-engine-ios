#import "GEcommon.h"
#import "GEfbo.h"

@interface GELight : NSObject

// -------------------------------------------- //
// ---------------- Properties ---------------- //
// -------------------------------------------- //
#pragma mark Properties
@property enum GE_LIGHT_TYPE LightType;
@property GLKVector3 Position;
@property GLKVector3 Direction;
@property float CutOff;
@property GLKVector3 DiffuseColor;
@property GLKVector3 AmbientColor;
@property GLKVector3 SpecularColor;
@property float Intensity;
@property float Ambient;
@property bool CastShadows;
@property GLKMatrix4 LightModelViewProjectionMatrix;
@property (readonly)GEFBO* ShadowMapFBO;
@property GLint ShadowMapSize;
@end