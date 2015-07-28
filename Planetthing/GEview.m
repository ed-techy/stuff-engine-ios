#import "GEview.h"

@interface GEView()
{
    GEContext* m_context;
    
    
}

@end

@implementation GEView

@synthesize BackgroundColor;
@synthesize Opasity;

// ------------------------------------------------------------------------------ //
// -------------------------- Initialization and Set up ------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Initialization and Set up

- (id)init
{
    self = [super init];
    
    if(self)
    {
        // Get the context
        m_context = [GEContext sharedIntance];
        
        // Opaque background.
        Opasity = 1.0f;
    }
    
    return self;
}

// ------------------------------------------------------------------------------ //
// ------------------------------------ Render ---------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Render

- (void)render
{
    [m_context setBackgroundColor:GLKVector4MakeWithVector3(BackgroundColor, Opasity)];
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

// ------------------------------------------------------------------------------ //
// ------------------------------ Setters - Getters ----------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Setters - Getters


@end
