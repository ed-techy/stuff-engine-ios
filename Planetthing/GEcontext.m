#import "GEcontext.h"

@interface GEContext()
{
    GLKVector4 m_lastColor;
}

@end

@implementation GEContext

@synthesize ContextView;
@synthesize MaxTextureSize;

// ------------------------------------------------------------------------------ //
// ------------------------------ Context singleton ----------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Render Box Singleton

+ (instancetype)sharedIntance
{
    static GEContext* sharedIntance;
    static dispatch_once_t onceToken;
    
    // Know if the shared instance was already allocated.
    dispatch_once(&onceToken, ^{
        CleanLog(RB_VERBOSE, @"Context: Shared instance was allocated for the first time.");
        sharedIntance = [[GEContext alloc] init];
    });
    
    return sharedIntance;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        // Get the maximun size that the GPU support.
        glGetIntegerv(GL_MAX_TEXTURE_SIZE, &MaxTextureSize);
        
        // Set for the initial clear color.
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    }
    
    return self;
}

// ------------------------------------------------------------------------------ //
// ------------------------------- Public Functions ----------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Public Functions

- (void)setBackgroundColor:(GLKVector4)color
{
    if(GLKVector4AllEqualToVector4(m_lastColor, color)) return;
    
    // If it is not using the new color set  it in OpenGL and keep it fore reference.
    glClearColor(color.r, color.g, color.b, color.a);
    m_lastColor = color;
}

@end