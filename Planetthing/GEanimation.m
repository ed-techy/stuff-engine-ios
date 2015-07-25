#import "GEanimation.h"

@implementation GEJoint
@end

@implementation GEJointInfo
@end

@implementation GEBound
@end

@interface GEAnimation()
{
    NSMutableArray* m_jointInfs;
    NSMutableArray* m_frames;
    NSMutableArray* m_bounds;
}

- (NSArray*)getWordsFromString:(NSString*)string;
- (NSString*)stringWithOutQuotes:(NSString*)string;
- (float)computeWComponentOfQuaternion:(GLKQuaternion*)quaternion;

@end

@implementation GEAnimation

@synthesize NumberOfFrames;
@synthesize FrameRate;

- (void)loadAnimationWithFileName:(NSString*)filename
{
    NSString *fileContents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"md5anim"] encoding:NSUTF8StringEncoding error:NULL];
    
    // All the lines in the file
    NSArray* lines = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    lines = [lines filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
    int lineIndex = 0;
    
    // Animation counters.
    unsigned int numberOfJoints = 0;
    unsigned int numberOfAnimatedComponents = 0;
    
    // Create the arrays for each object type.
    m_jointInfs = [[NSMutableArray alloc] init];
    m_bounds = [[NSMutableArray alloc] init];
    
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
            // Make a joint object for each joint line.
            for(int i = 0; i < numberOfJoints; i++)
            {
                // Joint line.
                lineIndex++;
                words = [self getWordsFromString:lines[lineIndex]];
                
                // New joint.
                GEJointInfo* currentJoint = [[GEJointInfo alloc] init];
                currentJoint.Name = [self stringWithOutQuotes:words[0]];
                currentJoint.ParentID = [words[1] intValue];
                currentJoint.Flags = [words[2] unsignedIntValue];
                currentJoint.StartIndex = [words[3] unsignedIntValue];
                
                // Add new joint.
                [m_jointInfs addObject:currentJoint];
            }
        }
        else if([words[0] isEqual:@"bounds"])
        {
            // Temporal bound positions.
            GLKVector3 maxBound, minBound;
            
            // Make a bound object for each bound line.
            for(int i = 0; i < NumberOfFrames; i++)
            {
                // Joint line.
                lineIndex++;
                words = [self getWordsFromString:lines[lineIndex]];
                
                // New Bound.
                GEBound* currentBound = [[GEBound alloc] init];
                
                // Max bound data
                maxBound.x = [words[1] floatValue];
                maxBound.y = [words[2] floatValue];
                maxBound.z = [words[3] floatValue];
                currentBound.MaxBound = maxBound;
                
                // Min bound data
                minBound.x = [words[6] floatValue];
                minBound.y = [words[7] floatValue];
                minBound.z = [words[8] floatValue];
                currentBound.MinBound = minBound;
                
                // Add new bound.
                [m_bounds addObject:currentBound];
            }
        }
        
        lineIndex++;
        if(lineIndex >= lines.count) break;
    }
    while (true);
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