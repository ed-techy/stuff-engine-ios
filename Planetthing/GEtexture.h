#import "GEcontext.h"

@interface GETexture : NSObject

// -------------------------------------------- //
// ---------------- Properties ---------------- //
// -------------------------------------------- //
#pragma mark Properties
@property (readonly) GLuint TextureID;
@property (readonly) NSString* FileName;
@property (readonly) unsigned int Width;
@property (readonly) unsigned int Height;


// -------------------------------------------- //
// ----------- Unique Texture Sytem ----------- //
// -------------------------------------------- //
#pragma mark Unique Texture Sytem

+ (instancetype)textureWithFileName:(NSString*)filename;

// -------------------------------------------- //
// ------------------- Load ------------------- //
// -------------------------------------------- //
#pragma mark Load
- (void)loadTextureWithFileName:(NSString*)filename;

@end
