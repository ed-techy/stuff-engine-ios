#import "GEtexture.h"

@interface GETexture()
{
    
}

- (char*)LoadImageFromFileName:(NSString*)filename;

@end

@implementation GETexture

@synthesize TextureID;
@synthesize Width;
@synthesize Height;
@synthesize FileName;

// ------------------------------------------------------------------------------ //
// ---------------------------- Unique Testure Sytem ---------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Unique Testure Sytem

static NSMapTable* m_texturesHolder;

+ (instancetype)textureFromFileName:(NSString*)filename
{
    // Create the textures holder
   if(m_texturesHolder == nil)
       m_texturesHolder = [NSMapTable strongToWeakObjectsMapTable];
    
    GETexture* texture = [m_texturesHolder objectForKey:filename];
    if(texture == nil)
    {
        texture = [[GETexture alloc] initFromFilename:filename];
        [m_texturesHolder setObject:texture forKey:filename];
    }
    
    return texture;
}

- (void)dealloc
{
    [m_texturesHolder removeObjectForKey:FileName];
        
    if(m_texturesHolder.count == 0)
            m_texturesHolder = nil;
}

- (id)initFromFilename:(NSString*)filename
{
    self = [super init];
    
    if(self)
    {
        [self LoadImageFromFileName:filename];
    }
    
    return self;
}

// ------------------------------------------------------------------------------ //
// --------------------------------- Load Image --------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Load Image

- (char*)LoadImageFromFileName:(NSString*)filename
{
    // Load the image.
    CGImageRef spriteImage = [UIImage imageNamed:filename].CGImage;
    if (spriteImage == nil)
    {
        NSLog(@"Texture: Failed to load image %@", filename);
        FileName = nil;
        exit(1);
    }
    
    FileName = filename;
    
    // Set the size
    Width = (unsigned int)CGImageGetWidth(spriteImage);
    Height = (unsigned int)CGImageGetHeight(spriteImage);
    
    char* rawPixels = (char*)calloc(Width * Height * 4, sizeof(char));
    
    CGContextRef spriteContext = CGBitmapContextCreate(rawPixels, Width, Height, 8, Width * 4, CGImageGetColorSpace(spriteImage), (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, Width, Height), spriteImage);
    CGContextRelease(spriteContext);
    
    return rawPixels;
}

@end
