#import "GElight.h"

@interface GELight()
{

}

@end

@implementation GELight

@synthesize LightType;
@synthesize Position;
@synthesize Direction;
@synthesize CutOff;
@synthesize DiffuseColor;
@synthesize AmbientColor;
@synthesize SpecularColor;
@synthesize Intensity;
@synthesize Ambient;
@synthesize ShadowMapFBO;
@synthesize ShadowMapSize;

// ------------------------------------------------------------------------------ //
// ------------------------------- Initialization ------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Initialization

- (id)init
{
    self = [super init];
    
    if(self)
    {
        LightType = GE_LIGHT_DIRECTIONAL;
        CutOff = cosf(GLKMathDegreesToRadians(25.0f));
        DiffuseColor = GLKVector3Make(1.0f, 1.0f, 1.0f);
        AmbientColor = GLKVector3Make(1.0f, 1.0f, 1.0f);
        SpecularColor = GLKVector3Make(1.0f, 1.0f, 1.0f);
        Ambient = 0.05f;
        ShadowMapSize = 1024;
        
        ShadowMapFBO = [GEFBO new];
        [ShadowMapFBO geberateForWidth:ShadowMapSize andHeight:ShadowMapSize];
        
        Intensity = 1.0f;
    }
    
    return self;
}

@end