#import "GEview.h"

@interface GEView()
{
    GEContext* m_context;
    
    
}

@end

@implementation GEView

@synthesize BackgroundColor;
@synthesize Opasity;
@synthesize Layers;

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
// ----------------------------------- Layers ----------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Layers

- (GELayer*)addLayerWithName:(NSString*)name
{
    if([Layers objectForKey:name] != nil) return nil;
    
    GELayer* newLayer = [GELayer new];
    newLayer.Name = name;
    
    [Layers setObject:newLayer forKeyedSubscript:name];
    
    return newLayer;
}

- (void)addLayerWithLayer:(GELayer*)layer
{
    GELayer* currentLayer = [Layers objectForKey:layer.Name];
    if(currentLayer == nil)
        [Layers setObject:layer forKeyedSubscript:layer.Name];
}

- (GELayer*)getLayerWithName:(NSString*)name
{
    return [Layers objectForKey:name];
}

- (void)removeLayerWithName:(NSString*)name
{
    [Layers removeObjectForKey:name];
}

- (void)removeLayer:(GELayer*)layer
{
    [Layers removeObjectForKey:layer.Name];
}

// ------------------------------------------------------------------------------ //
// ------------------------------ Setters - Getters ----------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Setters - Getters


@end
