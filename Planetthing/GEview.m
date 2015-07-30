#import "GEview.h"

@interface GEView()
{
    GEContext* m_context;
    GEFBO* m_fbo;
    
    GEFullScreen* m_fullScreen;
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
        
        // Layers
        Layers = [NSMutableDictionary new];
        
        // Opaque background.
        Opasity = 1.0f;
        
        // FBO
        m_fbo = [GEFBO new];
        [m_fbo geberateForWidth:640 andHeight:960];
        
        // Full Screen
        m_fullScreen = [GEFullScreen new];
    }
    
    return self;
}

// ------------------------------------------------------------------------------ //
// ------------------------------------ Render ---------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Render

- (void)render
{
    glBindFramebuffer(GL_FRAMEBUFFER, m_fbo.FrameBufferID);
    
    [m_context setBackgroundColor:GLKVector4MakeWithVector3(BackgroundColor, Opasity)];
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    
    for(NSString* layer in Layers)
    {
        [Layers[layer] render];
    }
    
    
    [m_context.ContextView bindDrawable];
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    m_fullScreen.TextureID = m_fbo.TextureID;
    [m_fullScreen render];
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
    
    [Layers setObject:newLayer forKey:name];
    
    return newLayer;
}

- (void)addLayerWithLayer:(GELayer*)layer
{
    GELayer* currentLayer = [Layers objectForKey:layer.Name];
    if(currentLayer == nil)
        [Layers setObject:layer forKey:layer.Name];
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
