#import "GEmesh.h"

@implementation GEJoint
@end

@implementation GEVertex
- (id)init { self = [super init]; if(self) self.Weights = [[NSMutableArray alloc] init]; return self; }
@end

@implementation GETriangle
@end

@implementation GEWight
@end

@interface GEMesh()
{
    
}

@end

@implementation GEMesh

@synthesize Material;
@synthesize Vertices;
@synthesize Triangles;
@synthesize Weights;


- (id)init
{
    self  = [super init];
    
    if(self)
    {
        Material = [[GEMaterial alloc] init];
        Vertices = [[NSMutableArray alloc] init];
        Triangles = [[NSMutableArray alloc] init];
        Weights = [[NSMutableArray alloc] init];
    }
    
    return self;
}

@end