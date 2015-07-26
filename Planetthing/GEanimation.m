#import "GEanimation.h"

@interface GEAnimation()
{
    float m_frameDuration;
    NSMutableArray* m_selectors;
}

- (bool)loadMD5WithFileName:(NSString*)filename;

- (NSArray*)getWordsFromString:(NSString*)string;
- (NSString*)stringWithOutQuotes:(NSString*)string;
- (float)computeWComponentOfQuaternion:(GLKQuaternion*)quaternion;

@end

@implementation GEAnimation

@synthesize FileName;
@synthesize NumberOfFrames;
@synthesize FrameRate;
@synthesize Frames;
@synthesize Ready;
@synthesize Duration = _Duration;
@synthesize CurrentTime;
@synthesize Reverse;

// ------------------------------------------------------------------------------ //
// ------------------------------- Initialization ------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Initialization

- (id)init
{
    self = [super init];
    
    if(self)
    {
        m_selectors = [NSMutableArray new];
    }
    
    return self;
}

// ------------------------------------------------------------------------------ //
// ------------------------------ Frame - Playback ------------------------------ //
// ------------------------------------------------------------------------------ //
#pragma mark Frame - Playback

- (void)frame:(float)time
{
    
}

#pragma mark Selector Management

- (void)addModelToAnimate:(GEAnimatedModel<GEAnimationProtocol>*)model
{
    [m_selectors addObject:model];
}

- (void)removeModel:(GEAnimatedModel*)model
{
    [m_selectors removeObject:model];
}

// ------------------------------------------------------------------------------ //
// --------------------------- Load - Import - Export --------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Load - Import - Export

- (void)loadAnimationWithFileName:(NSString *)filename
{
    NSString* fileType = [filename pathExtension];
    NSString* filePath = [filename stringByDeletingPathExtension];
    
    FileName = filename;
    
    // Decide what load method to use.
    if([fileType isEqualToString:@"md5anim"])
        Ready = [self loadMD5WithFileName:filePath];
    
    // The file was loaded successfully
    if(Ready)
    {
        CleanLog(GE_VERBOSE && AT_VERBOSE, @"Animation: Animation \"%@\" loaded successfully.", filename);
        
        m_frameDuration = 1.0f / (float)FrameRate;
        _Duration = m_frameDuration * (float)NumberOfFrames;
    }
}

- (bool)loadMD5WithFileName:(NSString*)filename;
{
    NSString *fileContents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"md5anim"] encoding:NSUTF8StringEncoding error:NULL];
    
    // All the lines in the file
    NSArray* lines = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    lines = [lines filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
    int lineIndex = 0;
    
    // Animation counters.
    unsigned int numberOfJoints = 0;
    unsigned int numberOfAnimatedComponents = 0;
    
    // Temporal data holders
    //Joints
    NSMutableArray* jointNames = [NSMutableArray new];
    struct jointInf
    {
        int parentID;
        int flags;
        int startData;
    };
    struct jointInf* jointInfs = 0;
    
    // Bounds
    struct bound
    {
        float maxX, maxY, maxZ;
        float minX, minY, minZ;
    };
    struct bound* bounds = 0;
    
    // Frames
    struct frameData
    {
        float* data;
    };
    struct frameData* frameDatas = 0;
    GEFrame* baseFrame = [GEFrame new];
    
    // Do work until reach all the content
    do
    {
        // Words in the line, eliminating the empty ones.
        NSArray* words = [self getWordsFromString:lines[lineIndex]];
        
        if([words[0] isEqual:@"numFrames"]) // Line with the number of frames in the animation.
        {
            NumberOfFrames = [words[1] unsignedIntValue];
            lineIndex++;
            continue;
        }
        else if([words[0] isEqual:@"numJoints"]) // Line with the number of joints to read.
        {
            numberOfJoints = [words[1] unsignedIntValue];
            lineIndex++;
            continue;
        }
        else if([words[0] isEqual:@"frameRate"]) // Line with the frame rate of the animation.
        {
            FrameRate = [words[1] unsignedIntValue];
            lineIndex++;
            continue;
        }
        else if([words[0] isEqual:@"numAnimatedComponents"]) // Line with the number of animated componen per frame.
        {
            numberOfAnimatedComponents = [words[1] unsignedIntValue];
            lineIndex++;
            continue;
        }
        else if([words[0] isEqual:@"hierarchy"])
        {
            // Create the temporal data holder.
            jointInfs = (struct jointInf*)calloc(numberOfJoints, sizeof(struct jointInf));
            
            // Fill the data holder with every joint line.
            for(int i = 0; i < numberOfJoints; i++)
            {
                // Joint line.
                lineIndex++;
                words = [self getWordsFromString:lines[lineIndex]];
                
                // Name.
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
                
                [jointNames addObject:[self stringWithOutQuotes:name]];
                
                // Data.
                jointInfs[i].parentID = [words[1 + offsetName] intValue];
                jointInfs[i].flags = [words[2 + offsetName] intValue];
                jointInfs[i].startData = [words[3 + offsetName] intValue];
            }
        }
        else if([words[0] isEqual:@"bounds"])
        {
            // Create the temporal data holders with the number of frames.
            bounds = (struct bound*)calloc(NumberOfFrames, sizeof(struct bound));
            frameDatas = (struct frameData*)calloc(NumberOfFrames, sizeof(struct frameData));
            
            // Fill the data holder with every bound line.
            for(int i = 0; i < NumberOfFrames; i++)
            {
                // Joint line.
                lineIndex++;
                words = [self getWordsFromString:lines[lineIndex]];
                
                // New Bound.
                bounds[i].minX = [words[1] floatValue];
                bounds[i].minY = [words[2] floatValue];
                bounds[i].minZ = [words[3] floatValue];
                bounds[i].maxX = [words[6] floatValue];
                bounds[i].maxY = [words[7] floatValue];
                bounds[i].maxZ = [words[8] floatValue];
            }
        }
        else if([words[0] isEqual:@"baseframe"])
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
                
                // Position data.
                position.x = [words[1] floatValue];
                position.y = [words[2] floatValue];
                position.z = [words[3] floatValue];
                
                // Orientation data.
                orientation.x = [words[6] floatValue];
                orientation.y = [words[7] floatValue];
                orientation.z = [words[8] floatValue];
                orientation.w = [self computeWComponentOfQuaternion:&orientation];
                
                currentJoint.Position = position;
                currentJoint.Orientation = orientation;
                
                // Add new joint.
                [baseFrame.Joints addObject:currentJoint];
            }
        }
        else if([words[0] isEqual:@"frame"])
        {
            // Create the data members with number of animated components.
            unsigned int frameIndex = [words[1] unsignedIntValue];
            frameDatas[frameIndex].data = (float*)calloc(numberOfAnimatedComponents, sizeof(float));
            
            // Fill the data with all the next data lines.
            unsigned int dataIndex = 0;
            unsigned int remainDatas = numberOfAnimatedComponents;
            do
            {
                // Joint line.
                lineIndex++;
                words = [self getWordsFromString:lines[lineIndex]];
                
                // Every line contains a portion of the total datas.
                remainDatas -= words.count;
                
                // Get the
                for(NSString* word in words)
                    frameDatas[frameIndex].data[dataIndex++] = [word floatValue];
                
                if(remainDatas == 0) break;
                    
            }
            while (true);
        }
        
        lineIndex++;
        if(lineIndex >= lines.count) break;
    }
    while (true);
    
    // Build frames
    Frames = [NSMutableArray new];
    
    for(int i = 0; i < NumberOfFrames; i++)
    {
        // New Frame
        GEFrame* currentFrame = [GEFrame new];
        
        // Fill bound inf.
        GLKVector3 maxBound = GLKVector3Make(bounds[i].maxX, bounds[i].maxY, bounds[i].maxZ);
        GLKVector3 minBound = GLKVector3Make(bounds[i].minX, bounds[i].minY, bounds[i].minZ);
        
        currentFrame.Bound.MaxBound = maxBound;
        currentFrame.Bound.MinBound = minBound;
        
        // Frame data
        struct frameData currentFrameData = frameDatas[i];
        
        // Calculate every new joint based on the base frame.
        for ( unsigned int j = 0; j < numberOfJoints; j++ )
        {
            // BaseJoint
            GEJoint* baseJoint = baseFrame.Joints[j];
            struct jointInf baseJointInf = jointInfs[j];
            
            // New joint
            GEJoint* currentJoint = [GEJoint new];
            
            GLKVector3 basePosition = baseJoint.Position;
            GLKQuaternion baseOrientation = baseJoint.Orientation;
            
            // Parenting
            currentJoint.Parent = baseJointInf.parentID != -1 ? currentFrame.Joints[baseJointInf.parentID] : nil;
            
            // Flags that tell what member in position and orientation is been modified.
            unsigned int o = 0;
            if(baseJointInf.flags & 1)
                basePosition.x = currentFrameData.data[baseJointInf.startData + o++];
            if(baseJointInf.flags & 2)
                basePosition.y = currentFrameData.data[baseJointInf.startData + o++];
            if(baseJointInf.flags & 4)
                basePosition.z = currentFrameData.data[baseJointInf.startData + o++];
            if(baseJointInf.flags & 8)
                baseOrientation.x = currentFrameData.data[baseJointInf.startData + o++];
            if(baseJointInf.flags & 16)
                baseOrientation.y = currentFrameData.data[baseJointInf.startData + o++];
            if(baseJointInf.flags & 32)
                baseOrientation.z = currentFrameData.data[baseJointInf.startData + o++];
            
            baseOrientation.w = [self computeWComponentOfQuaternion:&baseOrientation];
            
            if(currentJoint.Parent != nil) // Has a parent joint
            {
                GLKVector3 rotPosition = GLKQuaternionRotateVector3(currentJoint.Parent.Orientation, basePosition);
                
                currentJoint.Position = GLKVector3Add(currentJoint.Parent.Position, rotPosition);
                currentJoint.Orientation = GLKQuaternionNormalize(GLKQuaternionMultiply(currentJoint.Parent.Orientation, baseOrientation));
            }
            else
            {
                currentJoint.Position = basePosition;
                currentJoint.Orientation = baseOrientation;
            }
            
            // Push the new joint.
            [currentFrame.Joints addObject:currentJoint];
        }
        
        // Free the data for this frame since has been procesed.
        free(frameDatas[i].data);
        
        // Push the new frame.
        [Frames addObject:currentFrame];
    }
    
    // Clean the temporal data
    free(jointInfs);
    free(bounds);
    free(frameDatas);
    
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