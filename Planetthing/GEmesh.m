#import "GEmesh.h"

@interface GEMesh()
{
    float* m_vertexBuffer;
    unsigned int* m_indexBuffer;
    
    GLuint m_vertexArrayID;
    GLuint m_vertexBufferID;
    GLuint m_indexBufferID;
}

@end

@implementation GEMesh

@synthesize Material;
@synthesize Vertices;
@synthesize Triangles;
@synthesize Weights;

// ------------------------------------------------------------------------------ //
// ------------------------------- Initialization ------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Initialization

- (id)init
{
    self  = [super init];
    
    if(self)
    {
        Material = [GEMaterial new];
        Vertices = [NSMutableArray new];
        Triangles = [NSMutableArray new];
        Weights = [NSMutableArray new];
    }
    
    return self;
}

// ------------------------------------------------------------------------------ //
// ----------------------------------- Render ----------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Render

- (void)render:(GLenum)mode
{
    glBindVertexArrayOES(m_vertexArrayID);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_indexBufferID);
    glDrawElements(mode, (GLsizei)Triangles.count * 3, GL_UNSIGNED_INT, NULL);
}

// ------------------------------------------------------------------------------ //
// ------------------------- Generate - Compute Vertices ------------------------ //
// ------------------------------------------------------------------------------ //
#pragma mark Generate - Compute Vertices


- (void)matchMeshWithFrame:(GEFrame*)frame;
{
    int i = 0;
    for(GEVertex* vertex in Vertices)
    {
        GLKVector3 finalPosition = GLKVector3Make(0.0f, 0.0f, 0.0f);
        
        for(GEWight* weight in vertex.Weights)
        {
            GEJoint* joint = frame.Joints[weight.JointID];
            GLKVector3 rotPosition = GLKQuaternionRotateVector3(joint.Orientation, weight.Position);
            finalPosition = GLKVector3Add(finalPosition, GLKVector3MultiplyScalar(GLKVector3Add(joint.Position, rotPosition), weight.Bias));
        }
        
        vertex.Position = finalPosition;
        vertex.Normal = GLKVector3Make(0.0f, 0.0f, 0.0f);
        
        m_vertexBuffer[i * 8] = finalPosition.x;
        m_vertexBuffer[i * 8 + 1] = finalPosition.z;
        m_vertexBuffer[i * 8 + 2] = -finalPosition.y;
        m_vertexBuffer[i * 8 + 3] = vertex.TextureCoord.x;
        m_vertexBuffer[i * 8 + 4] = vertex.TextureCoord.y;
        
        i++;
    }

    for (GETriangle* triangle in Triangles)
    {
        GLKVector3 normal = GLKVector3CrossProduct(GLKVector3Subtract(triangle.Vertex3.Position, triangle.Vertex1.Position), GLKVector3Subtract(triangle.Vertex2.Position, triangle.Vertex1.Position));
        
        triangle.Vertex1.Normal = GLKVector3Add(triangle.Vertex1.Normal, normal);
        triangle.Vertex2.Normal = GLKVector3Add(triangle.Vertex2.Normal, normal);
        triangle.Vertex3.Normal = GLKVector3Add(triangle.Vertex3.Normal, normal);
    }
    
    i = 0;
    for(GEVertex* vertex in Vertices)
    {
        GLKVector3 normal = GLKVector3Normalize(vertex.Normal);
        
        m_vertexBuffer[i * 8 + 5] = normal.x;
        m_vertexBuffer[i * 8 + 6] = normal.z;
        m_vertexBuffer[i * 8 + 7] = -normal.y;
        
        i++;

        vertex.Normal = GLKVector3Make(0.0f, 0.0f, 0.0f);
        
        for(GEWight* weight in vertex.Weights)
        {
            GEJoint* joint = frame.Joints[weight.JointID];
            vertex.Normal = GLKVector3Add(vertex.Normal, GLKVector3MultiplyScalar(GLKQuaternionRotateVector3(GLKQuaternionInvert(joint.Orientation), normal) , weight.Bias));
        }
    }
    
    // Bind the vertex buffer and refill it with data.
    glBindBuffer(GL_ARRAY_BUFFER, m_vertexBufferID);
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(float) * Vertices.count * 8, m_vertexBuffer);
}

- (void)generateBuffers
{
    // Create the dynamic vertex data and the static index data.
    m_vertexBuffer = (float*)calloc(Vertices.count * 8, sizeof(float));
    m_indexBuffer = (unsigned int*)calloc(Triangles.count * 3, sizeof(unsigned int));
    
    // Fill the index information
    int i = 0;
    for (GETriangle* triangle in Triangles)
    {
        m_indexBuffer[i * 3] = triangle.Vertex1.Index;
        m_indexBuffer[i * 3 + 1] = triangle.Vertex2.Index;
        m_indexBuffer[i * 3 + 2] = triangle.Vertex3.Index;
        i++;
    }
    
    // Generate a vertex array id that keep both the vertex buffer and the indexbiffer.
    glGenVertexArraysOES(1, &m_vertexArrayID);
    glBindVertexArrayOES(m_vertexArrayID);
    
    // Genreate the vertex buffer and fill it with the dynamic data.
    glGenBuffers(1, &m_vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, m_vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(float) * Vertices.count * 8, m_vertexBuffer, GL_DYNAMIC_DRAW);
    
    // Set the offset in the dynamic data that represent the vertex information.
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 8, 0);
    
    // Set the offset tn the dynamic data that represent the texture coordinates information.
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 8, (unsigned char*)NULL + (3 * sizeof(float)));
    
    // Set the offset tn the dynamic data that represent the normal information.
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 8, (unsigned char*)NULL + (5 * sizeof(float)));
    
    // Generate the index buffer and fill it with the static data.
    glGenBuffers(1, &m_indexBufferID);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_indexBufferID);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(unsigned int) * Triangles.count * 3, m_indexBuffer, GL_STATIC_DRAW);
    
    // Unbind everything.
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindVertexArrayOES(0);
}

@end