#import "GEmaterial.h"

@interface GEMaterial()
{
    
}

@end

@implementation GEMaterial

@synthesize TextureCompression;
@synthesize DiffuseMap;
@synthesize SpecularMap;
@synthesize AmbientColor;
@synthesize DiffuseColor;
@synthesize SpecularColor;
@synthesize Shininess;
@synthesize Opasity;

- (id)init
{
    self = [super init];
    
    if(self)
    {
        TextureCompression = GLKVector2Make(1.0f, 1.0f);
        DiffuseColor = GLKVector3Make(0.92f, 0.97f, 1.0f);
        
        AmbientColor = GLKVector3Make(0.92f, 0.97f, 1.0f);
        SpecularColor = GLKVector3Make(0.01, 0.05f, 0.1f);
        Shininess = 8.0f;
        Opasity = 1.0f;
    }
    
    return self;
}

@end