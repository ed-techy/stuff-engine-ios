#import "GEtexture.h"

@interface GETexture()
{
    
}

- (char*)loadImageFromFileName:(NSString*)filename;
- (void)generateTextureFromPixels:(char*)rawPixels;

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
    
    // The texture is already loaded?
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
    
    // Remove the texture holder if there is no more textures to hold
    if(m_texturesHolder.count == 0)
        m_texturesHolder = nil;
}

- (id)initFromFilename:(NSString*)filename
{
    self = [super init];
    
    if(self)
    {
        TextureID = 0;
        Width = 0;
        Height = 0;
        
        // Load the image form file
        char* rawPixels = [self loadImageFromFileName:filename];
        
        // Generate the openGL reference in the video card
        [self generateTextureFromPixels:rawPixels];
        
        // Don't keep the pixels in RAM
        free(rawPixels);
    }
    
    return self;
}

// ------------------------------------------------------------------------------ //
// ---------------------------- Load Image - Texture ---------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Load Image - Texture

- (char*)loadImageFromFileName:(NSString*)filename
{
    // Load the image.
    CGImageRef spriteImage = [UIImage imageNamed:filename].CGImage;
    if (spriteImage == nil)
    {
        CleanLog(GE_VERBOSE && TX_VERBOSE, @"Texture: Failed to load image %@", filename);
        FileName = nil;
        exit(1);
    }
    
    FileName = filename;
    
    // Set the size
    Width = (unsigned int)CGImageGetWidth(spriteImage);
    Height = (unsigned int)CGImageGetHeight(spriteImage);
    
    char* rawPixels = (char*)calloc(Width * Height * 4, sizeof(char));
    
    // Fucking ios aplha premultiplied inevitable.
    CGContextRef spriteContext = CGBitmapContextCreate(rawPixels, Width, Height, 8, Width * 4, CGImageGetColorSpace(spriteImage), (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    CGContextSetBlendMode(spriteContext, kCGBlendModeCopy);
    
    // Create the pixel Data
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, Width, Height), spriteImage);
    CGContextRelease(spriteContext);
    
    return rawPixels;
}

- (void)generateTextureFromPixels:(char*)rawPixels
{
    // Generate an ID for the texture.
    glGenTextures(1, &TextureID);
    
    // Bind the texture as a 2D texture.
    glBindTexture(GL_TEXTURE_2D, TextureID);
    
    // Load the image data into the texture unit.
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, Width, Height, 0, GL_RGBA, GL_UNSIGNED_BYTE, rawPixels);
    
    // Use linear filetring
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

    //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    // Generate mipmaps for the texture.
    glGenerateMipmap(GL_TEXTURE_2D);
}

@end
