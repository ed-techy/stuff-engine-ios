#import "GEview.h"

@interface GEView()
{
    GEContext* m_context;

    GEBlinnPhongShader* m_blinnPhongShader;
    GETextureShader* m_textureShader;
    GEDepthShader* m_depthShader;
    GEColorShader* m_colorShader;
    
    GEFullScreen* m_fullScreen;
    
    NSMutableArray* m_lights;
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
        
        // Get the shaders.
        m_blinnPhongShader = [GEBlinnPhongShader sharedIntance];
        m_textureShader = [GETextureShader sharedIntance];
        m_colorShader = [GEColorShader sharedIntance];
        m_depthShader = [GEDepthShader sharedIntance];
        
        // Layers
        Layers = [NSMutableDictionary new];
        
        // Opaque background.
        Opasity = 1.0f;
        
        // Lights.
        m_lights = [NSMutableArray new];
        
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
    [m_context setBackgroundColor:GLKVector4MakeWithVector3(BackgroundColor, Opasity)];
    
    [m_lights enumerateObjectsUsingBlock:^(GELight* light, NSUInteger index, BOOL *stop)
     {
         glBindFramebuffer(GL_FRAMEBUFFER, light.ShadowMapFBO.FrameBufferID);
         glViewport(0, 0, light.ShadowMapFBO.Width, light.ShadowMapFBO.Height);
         glClear(GL_DEPTH_BUFFER_BIT);
         
         GLKVector3 position = light.Position;
         
         //GLKMatrix4 matrix = GLKMatrix4Multiply(GLKMatrix4MakeOrtho(-50.0f, 50.0f, -50.0f, 50.0f, 1.0f, 50.0f), GLKMatrix4MakeLookAt(position.x, position.y, position.z, 0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f));
         
         GLKMatrix4 matrix = GLKMatrix4Multiply(GLKMatrix4MakeOrtho(-60.0f, 60.0f, -60.0f, 60.0f, 1.0f, 200.0f), GLKMatrix4MakeLookAt(position.x, position.y, position.z, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f));
         
         m_depthShader.ModelViewProjectionMatrix = &matrix;
         
         light.LightModelViewProjectionMatrix = matrix;
         
         // Draw back faces.
         glCullFace(GL_FRONT);
         
         // Render depth of object.
         for(NSString* layer in Layers)
         {
             [Layers[layer] renderDepth];
         }
     }];
    
    // To screen render.
    [m_context.ContextView bindDrawable];
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    GLKMatrix4 matrix = GLKMatrix4Multiply(GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0f), 320.0f/480.0f, 0.1f, 1000.0f), GLKMatrix4MakeLookAt(0.0f, 90.0f, 120.0f, 0.0f, 30.0f, 0.0f, 0.0f, 1.0f, 0.0f));
    
    m_blinnPhongShader.ModelViewProjectionMatrix = &matrix;
    m_blinnPhongShader.Lights = m_lights;
    m_colorShader.ModelViewProjectionMatrix = &matrix;
    
    glCullFace(GL_BACK);
    
    // Render normal objects;
    for(NSString* layer in Layers)
    {
        [Layers[layer] render];
    }
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
// ----------------------------------- Lights ----------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Lights
- (void)addLight:(GELight*)light
{
    [m_lights addObject:light];
}

- (void)removeLight:(GELight*)light
{
    [m_lights removeObject:light];
}

- (void)cleanLights
{
    [m_lights removeAllObjects];
}

// ------------------------------------------------------------------------------ //
// ------------------------------ Setters - Getters ----------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Setters - Getters


@end
