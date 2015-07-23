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
// ----------- Unique Testure Sytem ----------- //
// -------------------------------------------- //
#pragma mark Unique Testure Sytem

+ (instancetype)textureFromFileName:(NSString*)filename;
- (id)initFromFilename:(NSString*)filename;

@end
