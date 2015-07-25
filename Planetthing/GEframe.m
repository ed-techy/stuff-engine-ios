#import "GEframe.h"

@interface GEFrame()
{
    
}

@end

@implementation GEFrame

@synthesize Joints;
@synthesize Bound;

// ------------------------------------------------------------------------------ //
// ------------------------------- Initialization ------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Initialization

- (id)init
{
    self = [super init];
    
    if(self)
    {
        Joints = [NSMutableArray new];
        Bound = [GEBound new];
    }
    
    return self;
}

@end
