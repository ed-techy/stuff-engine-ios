#import "GEview.h"

@interface GEView()
{
    GEContext* m_context;
}

@end

@implementation GEView

@synthesize BackgroundColor;

// ------------------------------------------------------------------------------ //
// -------------------------- Initialization and Set up ------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Render Box Singleton

- (id)init
{
    self = [super init];
    
    if(self)
    {
        // Get the context
        m_context = [GEContext sharedIntance];
    }
    
    return self;
}

// ------------------------------------------------------------------------------ //
// ------------------------------------ Render ---------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Render

- (void)render
{
    [m_context setBackgroundColor:BackgroundColor];
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

// ------------------------------------------------------------------------------ //
// ------------------------------ Setters - Getters ----------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Setters - Getters


@end
