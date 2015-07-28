#import "GEboundingbox.h"

@interface GEBoundingbox()
{
    GLuint m_vertexArrayID;
    GLuint m_vertexBufferID;
    GLuint m_indexBufferID;
}

- (void)generateBoundingLines;
- (void)updateBoundingLines;

@end

@implementation GEBoundingbox

@synthesize Bound;

// ------------------------------------------------------------------------------ //
// ----------------------------------  Singleton -------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Singleton

+ (instancetype)sharedIntance
{
    static GEBoundingbox* sharedIntance;
    static dispatch_once_t onceToken;
    
    // Know if the shared instance was already allocated.
    dispatch_once(&onceToken, ^{
        CleanLog(GE_VERBOSE && SH_VERBOSE, @"Bounding Box: Shared instance was allocated for the first time.");
        sharedIntance = [GEBoundingbox new];
    });
    
    return sharedIntance;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        // Genereat the initial box.
        [self generateBoundingLines];
    }
    
    return self;
}

// ------------------------------------------------------------------------------ //
// ----------------------------------- Render ----------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Render

- (void)render
{
    glBindVertexArrayOES(m_vertexArrayID);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
    glDisableVertexAttribArray(GLKVertexAttribNormal);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_indexBufferID);
    glDrawElements(GL_LINES, 24, GL_UNSIGNED_INT, NULL);
}

// ------------------------------------------------------------------------------ //
// -------------------------- Generate - Update Lines --------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Generate - Update Lines

- (void)generateBoundingLines
{
    // Create the dynamic vertex data and the static index data.
    float vertexBuffer[24] = {
         1.0f,  1.0f, 1.0f, // Right, Top, Back
        -1.0f,  1.0f, 1.0f, // Left, Top, Back
         1.0f, -1.0f, 1.0f, // Right, Bottom, Back
        -1.0f, -1.0f, 1.0f, // Left, Bottom, Back
        
         1.0f,  1.0f, -1.0f, // Right, Top, Front
        -1.0f,  1.0f, -1.0f, // Left, Top, Front
         1.0f, -1.0f, -1.0f, // Right, Bottom, Front
        -1.0f, -1.0f, -1.0f // Left, Bottom, Front
    };
    
    unsigned int indexbuffer[24] = {
        0, 1,
        1, 3,
        3, 2,
        2, 0,
        
        4, 5,
        5, 7,
        7, 6,
        6, 4,
        
        0, 4,
        1, 5,
        2, 6,
        3, 7
    };
    
    
    // Generate a vertex array id that keep both the vertex buffer and the indexbiffer.
    glGenVertexArraysOES(1, &m_vertexArrayID);
    glBindVertexArrayOES(m_vertexArrayID);
    
    // Genreate the vertex buffer and fill it with the dynamic data.
    glGenBuffers(1, &m_vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, m_vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexBuffer), vertexBuffer, GL_DYNAMIC_DRAW);
    
    // Set the offset in the dynamic data that represent the vertex information.
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 3, 0);
    
    // Generate the index buffer and fill it with the static data.
    glGenBuffers(1, &m_indexBufferID);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_indexBufferID);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indexbuffer), indexbuffer, GL_STATIC_DRAW);
    
    // Unbind everything.
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindVertexArrayOES(0);
}

- (void)updateBoundingLines
{
    // Create the dynamic vertex data from bound.
    float vertexBuffer[24] = {
        Bound.MaxBound.x, Bound.MaxBound.y, Bound.MaxBound.z, // Right, Top, Back
        Bound.MinBound.x, Bound.MaxBound.y, Bound.MaxBound.z, // Left, Top, Back
        Bound.MaxBound.x, Bound.MinBound.y, Bound.MaxBound.z, // Right, Bottom, Back
        Bound.MinBound.x, Bound.MinBound.y, Bound.MaxBound.z, // Left, Bottom, Back
        
        Bound.MaxBound.x, Bound.MaxBound.y, Bound.MinBound.z, // Right, Top, Front
        Bound.MinBound.x, Bound.MaxBound.y, Bound.MinBound.z, // Left, Top, Front
        Bound.MaxBound.x, Bound.MinBound.y, Bound.MinBound.z, // Right, Bottom, Front
        Bound.MinBound.x, Bound.MinBound.y, Bound.MinBound.z  // Left, Bottom, Front
    };
    
    // Bind the vertex buffer and refill it with data.
    glBindBuffer(GL_ARRAY_BUFFER, m_vertexBufferID);
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(vertexBuffer), vertexBuffer);
}

// ------------------------------------------------------------------------------ //
// ------------------------------ Getter - Setters ------------------------------ //
// ------------------------------------------------------------------------------ //
#pragma mark Getter - Setters

- (void)setBound:(GEBound *)bound
{
    Bound = bound;
    [self updateBoundingLines];
}

- (GEBound*)Bound
{
    return Bound;
}

@end