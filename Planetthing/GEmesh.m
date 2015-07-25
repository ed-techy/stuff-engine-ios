#import "GEmesh.h"

@implementation GEVertex
- (id)init { self = [super init]; if(self) self.Weights = [[NSMutableArray alloc] init]; return self; }
@end

@implementation GETriangle
@end

@implementation GEWight
@end

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


- (id)init
{
    self  = [super init];
    
    if(self)
    {
        Material = [[GEMaterial alloc] init];
        Vertices = [[NSMutableArray alloc] init];
        Triangles = [[NSMutableArray alloc] init];
        Weights = [[NSMutableArray alloc] init];
    }
    
    return self;
}


- (void)prepareMesh
{
    m_vertexBuffer = (float*)calloc(Vertices.count * 8, sizeof(float));
    
    int i = 0;
    for(GEVertex* vertex in Vertices)
    {
        GLKVector3 finalPosition = GLKVector3Make(0.0f, 0.0f, 0.0f);
        
        for(GEWight* weight in vertex.Weights)
        {
            GLKVector3 rotPosition = GLKQuaternionRotateVector3(weight.Joint.Orientation, weight.Position);
            finalPosition = GLKVector3Add(finalPosition, GLKVector3MultiplyScalar(GLKVector3Add(weight.Joint.Position, rotPosition), weight.Bias));
        }
        
        vertex.Position = finalPosition;
        vertex.Normal = GLKVector3Make(0.0f, 0.0f, 0.0f);
        
        m_vertexBuffer[i * 8] = finalPosition.x;
        m_vertexBuffer[i * 8 + 1] = finalPosition.y;
        m_vertexBuffer[i * 8 + 2] = finalPosition.z;
        m_vertexBuffer[i * 8 + 3] = vertex.TextureCoord.x;
        m_vertexBuffer[i * 8 + 4] = vertex.TextureCoord.y;
        
        i++;
    }

    
    i = 0;
    m_indexBuffer = (unsigned int*)calloc(Triangles.count * 3, sizeof(unsigned int));
    for (GETriangle* triangle in Triangles)
    {
        GLKVector3 normal = GLKVector3CrossProduct(GLKVector3Subtract(triangle.Vertex3.Position, triangle.Vertex1.Position), GLKVector3Subtract(triangle.Vertex2.Position, triangle.Vertex1.Position));
        
        triangle.Vertex1.Normal = GLKVector3Add(triangle.Vertex1.Normal, normal);
        triangle.Vertex2.Normal = GLKVector3Add(triangle.Vertex2.Normal, normal);
        triangle.Vertex3.Normal = GLKVector3Add(triangle.Vertex3.Normal, normal);
        
        m_indexBuffer[i * 3] = triangle.Vertex1.Index;
        m_indexBuffer[i * 3 + 1] = triangle.Vertex2.Index;
        m_indexBuffer[i * 3 + 2] = triangle.Vertex3.Index;
        
        i++;
    }
    
    i = 0;
    for(GEVertex* vertex in Vertices)
    {
        GLKVector3 normal = GLKVector3Normalize(vertex.Normal);

        vertex.Normal = GLKVector3Make(0.0f, 0.0f, 0.0f);
        
        for(GEWight* weight in vertex.Weights)
        {
            vertex.Normal = GLKVector3Add(vertex.Normal, GLKVector3MultiplyScalar(GLKQuaternionRotateVector3(GLKQuaternionInvert(weight.Joint.Orientation), normal) , weight.Bias));
        }
        
        m_vertexBuffer[i * 8 + 5] = vertex.Normal.x;
        m_vertexBuffer[i * 8 + 6] = vertex.Normal.y;
        m_vertexBuffer[i * 8 + 7] = vertex.Normal.z;
    }
    
    glGenVertexArraysOES(1, &m_vertexArrayID);
    glBindVertexArrayOES(m_vertexArrayID);
    
    glGenBuffers(1, &m_vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, m_vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(float) * Vertices.count * 8, m_vertexBuffer, GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 8, 0);
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 8, (unsigned char*)NULL + (3 * sizeof(float)));
    
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 8, (unsigned char*)NULL + (5 * sizeof(float)));
    
    glGenBuffers(1, &m_indexBufferID);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_indexBufferID);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(unsigned int) * Triangles.count * 3, m_indexBuffer, GL_STATIC_DRAW);
    
}

- (void)render
{
    glBindVertexArrayOES(m_vertexArrayID);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glDisableVertexAttribArray(GLKVertexAttribNormal);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_indexBufferID);
    glDrawElements(GL_TRIANGLES, (GLsizei)Triangles.count * 3, GL_UNSIGNED_INT, NULL);
}

@end