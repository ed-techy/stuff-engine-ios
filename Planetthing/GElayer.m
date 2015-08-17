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
// ------------------------------------ Render ---------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Render

- (void)render
{
    // Render every object of this layer.
    for(id object in m_objects)
    {
        if([object respondsToSelector:@selector(render)])
            [object render];
    }
}

- (void)renderDepth
{
    // Render every depth object of this layer.
    for(id object in m_objects)
    {
        if([object respondsToSelector:@selector(renderDepth)])
            [object renderDepth];
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