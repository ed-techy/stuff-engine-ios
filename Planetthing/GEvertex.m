#import "GEvertex.h"

@interface GEVertex()
{
    
}

@end

@implementation GEVertex

@synthesize Weights;

// ------------------------------------------------------------------------------ //
// ------------------------------- Initialization ------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Initialization

- (id)init
{
    self = [super init];
    
    if(self)
        Weights = [NSMutableArray new];
    
    return self;
}

@end

