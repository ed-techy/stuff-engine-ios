#import "GEanimatedmodel.h"

@interface GEAnimatedModel()
{
    GEFrame* m_bindPose;
    NSMutableArray* m_meshes;
    
    GETextureShader* m_textureShader;
}

- (bool)loadMD5WithFileName:(NSString*)filename;

- (NSArray*)getWordsFromString:(NSString*)string;
- (NSString*)stringWithOutQuotes:(NSString*)string;
- (float)computeWComponentOfQuaternion:(GLKQuaternion*)quaternion;

@end

@implementation GEAnimatedModel

@synthesize FileName;
@synthesize Ready;


// ------------------------------------------------------------------------------ //
// ------------------------------- Initialization ------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Initialization

- (id)init
{
    self = [super init];
    
    if(self)
    {
        m_textureShader = [GETextureShader sharedIntance];
    }
    
    return self;
}

// ------------------------------------------------------------------------------ //
// ---------------------------------- Animation --------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Animation

- (void)resetPose
{
    for(GEMesh* mesh in m_meshes)
        [mesh matchMeshWithFrame:m_bindPose];
}

- (void)poseByFrame:(GEFrame*)frame
{
    for(GEMesh* mesh in m_meshes)
        [mesh matchMeshWithFrame:frame];
}

// ------------------------------------------------------------------------------ //
// ------------------------------------ Render ---------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Render

- (void)render
{
    GLKMatrix4 matrix = GLKMatrix4Multiply(GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0f), 320.0f/480.0f, 0.1f, 1000.0f), GLKMatrix4MakeLookAt(0.0f, -150.0f, 90.0f, 0.0f, 0.0f, 30.0f, 0.0f, 0.0f, 1.0f));
    
    m_textureShader.ModelViewProjectionMatrix = &matrix;
    
    for(GEMesh* mesh in m_meshes)
    {
        m_textureShader.TextureID = mesh.Material.DiffuseTexture.TextureID;
        
        [m_textureShader useProgram];
        [mesh render];
    }
}

// ------------------------------------------------------------------------------ //
// --------------------------- Load - Import - Export --------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Load - Import - Export

- (void)loadModelWithFileName:(NSString*)filename
{
    NSString* fileType = [filename pathExtension];
    NSString* filePath = [filename stringByDeletingPathExtension];
    
    FileName = filename;
    
    // Decide what load method to use.
    if([fileType isEqualToString:@"md5mesh"])
        Ready = [self loadMD5WithFileName:filePath];
    
    // If the file was loaded duccessfully prepare all the meshes buffers.
    if(Ready)
    {
        CleanLog(GE_VERBOSE && AM_VERBOSE, @"Animated Model: Model \"%@\" loaded successfully.", filename);
        
        for(GEMesh* mesh in m_meshes)
            [mesh generateBuffers];
        
        [self resetPose];
    }
}

- (bool)loadMD5WithFileName:(NSString*)filename
{
    NSString *fileContents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"md5mesh"] encoding:NSUTF8StringEncoding error:NULL];
    
    // All the lines in the file
    NSArray* lines = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    lines = [lines filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
    int lineIndex = 0;
    
    // MD5 file counters
    int numberOfJoints = 0;
    int numberOfMeshes = 0;
    
    // Get path
    NSString* filePath = [filename stringByDeletingLastPathComponent];
    
    // Create the arrays for each object type.
    m_bindPose = [GEFrame new];
    m_meshes = [NSMutableArray new];
    
    // Do work until reach all the content
    do
    {
        // Words in the line, eliminating the empty ones
        NSArray* words = [self getWordsFromString:lines[lineIndex]];
        
        if([words[0] isEqual:@"numJoints"]) // Line with the number of joints to read,
        {
            numberOfJoints = [words[1] unsignedIntValue];
            lineIndex++;
            continue;
        }
        else if([words[0] isEqual:@"numMeshes"])// Line with the number of meshes to read,
        {
            numberOfMeshes = [words[1] unsignedIntValue];
            lineIndex++;
            continue;
        }
        else if([words[0] isEqual:@"joints"])
        {
            // Temporal Position/Orientation.
            GLKVector3 position;
            GLKQuaternion orientation;
            
            // Make a joint object for each joint line.
            for(int i = 0; i < numberOfJoints; i++)
            {
                // Joint line.
                lineIndex++;
                words = [self getWordsFromString:lines[lineIndex]];
                
                // New joint.
                GEJoint* currentJoint = [GEJoint new];
                
                // Extract the name
                NSString* name = words[0];
                unsigned int offsetName = 0;
                do
                {
                    if([name characterAtIndex:name.length - 1] == 34)
                        break;
                    offsetName++;
                    name = [NSString stringWithFormat:@"%@ %@", name, words[offsetName]];
                }
                while(true);
                currentJoint.Name = [self stringWithOutQuotes:name];
                
                // Parent
                currentJoint.Parent = [words[1 + offsetName] isEqualToString:@"-1"] ? nil : m_bindPose.Joints[[words[1] intValue]];
                
                // Position data.
                position.x = [words[3 + offsetName] floatValue];
                position.y = [words[4 + offsetName] floatValue];
                position.z = [words[5 + offsetName] floatValue];
                
                // Orientation data.
                orientation.x = [words[8 + offsetName] floatValue];
                orientation.y = [words[9 + offsetName] floatValue];
                orientation.z = [words[10 + offsetName] floatValue];
                orientation.w = [self computeWComponentOfQuaternion:&orientation];
                
                currentJoint.Position = position;
                currentJoint.Orientation = orientation;
                
                // Add new joint.
                [m_bindPose.Joints addObject:currentJoint];
            }
        }
        else if([words[0] isEqual:@"mesh"])
        {
            // New Mesh.
            GEMesh* currentMesh = [GEMesh new];
            [m_meshes addObject:currentMesh];
            
            // Shader line.
            lineIndex++;
            words = [self getWordsFromString:lines[lineIndex]];
            
            // New texture for this mesh material.
            currentMesh.Material.DiffuseTexture = [[GETexture alloc] initFromFilename:[NSString stringWithFormat:@"%@/%@", filePath, [self stringWithOutQuotes:words[1]]]];
            
            // Number of vertices.
            lineIndex++;
            words = [self getWordsFromString:lines[lineIndex]];
            unsigned int numberOfVertices = [words[1] unsignedIntValue];
            
            // Temporal texture coord.
            GLKVector2 textureCoord;
            
            // Temporal Wight Information
            struct weightInf
            {
                unsigned int startWight;
                unsigned int weightCount;
            };
            
            struct weightInf* verticesWightInf = (struct weightInf*)calloc(numberOfVertices, sizeof(struct weightInf));
            
            // Make a new vertex object for each vertex line.
            for(int i = 0; i < numberOfVertices; i++)
            {
                // Vertex line.
                lineIndex++;
                words = [self getWordsFromString:lines[lineIndex]];
                
                // New vertex.
                GEVertex* currentVertex = [GEVertex new];
                [currentMesh.Vertices addObject:currentVertex];
                
                // Verrtex index;
                currentVertex.Index = i;
                
                // Texture coord data.
                textureCoord.x = [words[3] floatValue];
                textureCoord.y = [words[4] floatValue];
                currentVertex.TextureCoord = textureCoord;
                
                // Wights data.
                verticesWightInf[i].startWight = [words[6] unsignedIntValue];
                verticesWightInf[i].weightCount = [words[7] unsignedIntValue];
            }
            
            // Number of trianlges.
            lineIndex++;
            words = [self getWordsFromString:lines[lineIndex]];
            unsigned int numberOfTriangles = [words[1] unsignedIntValue];
            
            // Make a new trianlge object for each triangle line.
            for(int i = 0; i < numberOfTriangles; i++)
            {
                // Triangle line.
                lineIndex++;
                words = [self getWordsFromString:lines[lineIndex]];
                
                // New triangle.
                GETriangle* currentTrangle = [GETriangle new];
                [currentMesh.Triangles addObject:currentTrangle];
                
                // Vertices data.
                currentTrangle.Vertex1 = currentMesh.Vertices[[words[2] unsignedIntValue]];
                currentTrangle.Vertex2 = currentMesh.Vertices[[words[3] unsignedIntValue]];
                currentTrangle.Vertex3 = currentMesh.Vertices[[words[4] unsignedIntValue]];
            }
            
            // Number of weights.
            lineIndex++;
            words = [self getWordsFromString:lines[lineIndex]];
            unsigned int numberOfWeights = [words[1] unsignedIntValue];
            
            // Temporal weight position.
            GLKVector3 weightPosition;
            
            // Make a new weight object for each weight line.
            for(int i = 0; i < numberOfWeights; i++)
            {
                // Wight line.
                lineIndex++;
                words = [self getWordsFromString:lines[lineIndex]];
                
                // New weight.
                GEWight* currentWeight = [GEWight new];
                [currentMesh.Weights addObject:currentWeight];
                
                // Weight position data.
                weightPosition.x = [words[5] floatValue];
                weightPosition.y = [words[6] floatValue];
                weightPosition.z = [words[7] floatValue];
                currentWeight.Position = weightPosition;
                
                // Joint inf.
                currentWeight.JointID = [words[2] unsignedIntValue];
                
                // Bias info.
                currentWeight.Bias = [words[3] floatValue];
            }
            
            // Wight references for vertices base the weight inf we've got previously.
            for(int i = 0; i < numberOfVertices; i++)
            {
                GEVertex* currentVertex = currentMesh.Vertices[i];
                for(int j = 0; j < verticesWightInf[i].weightCount; j++)
                {
                    [currentVertex.Weights addObject:currentMesh.Weights[verticesWightInf[i].startWight + j]];
                }
            }
        }
        
        lineIndex++;
        if(lineIndex >= lines.count) break;
    }
    while (true);
    
    return true;
}

- (NSArray*)getWordsFromString:(NSString*)string
{
    NSArray *words = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    return [words filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
}

- (NSString*)stringWithOutQuotes:(NSString*)string
{
    return [string substringWithRange:NSMakeRange(1, string.length - 2)];
}

- (float)computeWComponentOfQuaternion:(GLKQuaternion*)quaternion
{
    float t = 1.0f - ( quaternion->x * quaternion->x ) - ( quaternion->y * quaternion->y ) - ( quaternion->z * quaternion->z );
    return t < 0.0f ? 0.0f : -sqrtf(t);
}

@end