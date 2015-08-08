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

- (id)init
{
    self = [super init];
    
    if(self)
    {
        LightType = GE_LIGHT_DIRECTIONAL;
        CutOff = 10.0f;
        DiffuseColor = GLKVector3Make(1.0f, 1.0f, 1.0f);
        AmbientColor = GLKVector3Make(0.2f, 0.2f, 0.2f);
        SpecularColor = GLKVector3Make(1.0f, 1.0f, 1.0f);
        Intensity = 1.0f;
    }
    
    return self;
}

@end