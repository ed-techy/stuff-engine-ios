#import "GEcommon.h"
#include <ft2build.h>
#include FT_FREETYPE_H
#include FT_GLYPH_H

@interface GEFont : NSObject

// -------------------------------------------- //
// ---------------- Properties ---------------- //
// -------------------------------------------- //
#pragma mark Properties
@property (readonly)GLuint LowerCaseLayoutTextureID;
@property (readonly)GLuint UpperCaseLayoutTextureID;
@property (readonly)GLuint SybolsAndNumbersLayoutTextureID;
@property (readonly)NSString* FontFamily;

// -------------------------------------------- //
// ------------ Unique Font Sytem ------------- //
// -------------------------------------------- //
#pragma markUnique Font Sytem

+ (instancetype)fontWithName:(NSString*)name;

// -------------------------------------------- //
// ------------------- Load ------------------- //
// -------------------------------------------- //
#pragma mark Load
- (void)loadFontWithName:(NSString*)name;


@end