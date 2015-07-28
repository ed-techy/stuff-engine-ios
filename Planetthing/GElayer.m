#import "GElayer.h"

@interface GELayer()
{
    NSMutableArray* m_objects;
}

@end

@implementation GELayer

@synthesize Visible;
@synthesize Name;
@synthesize NumberOfObjects;

// ------------------------------------------------------------------------------ //
// -------------------------------- Initialization ------------------------------ //
// ------------------------------------------------------------------------------ //
#pragma mark Initialization

- (id)init
{
    self = [super init];
    
    if(self)
    {
        // array of IDs.
        m_objects = [NSMutableArray new];
        
        // Render all by default.
        Visible = true;
    }
    
    return self;
}

// ------------------------------------------------------------------------------ //
// ------------------------------- Frame - Render ------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Frame - Render

- (void)frame:(float)time
{
    // Frame in every object of this layer.
    for(id object in m_objects)
    {
        if([object respondsToSelector:@selector(frame:)])
           [object frame:time];
    }
}

- (void)render
{
    // Render in every object of this layer.
    for(id object in m_objects)
    {
        if([object respondsToSelector:@selector(render)])
            [object render];
    }
}

// ------------------------------------------------------------------------------ //
// ---------------------------- Add - Remove objects ---------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Add - Remove objects

- (void)addObject:(id)object
{
    [m_objects addObject:object];
}

- (void)removeObject:(id)object
{
    [m_objects removeObject:object];
}

// ------------------------------------------------------------------------------ //
// ---------------------------- Getters - Setters ---------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Getters - Setters

- (unsigned int)NumberOfObjects
{
    return NumberOfObjects;
}

@end