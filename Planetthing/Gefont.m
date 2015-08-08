#import "GEfont.h"

@interface GEFont()
{
    FT_Library  m_library;
    FT_Face m_face;
    
    NSString* m_fontName;
}

- (void)preProccesMetricsForTextureSide:(unsigned int)side;

@end

@implementation GEFont

@synthesize LowerCaseLayoutTextureID;
@synthesize UpperCaseLayoutTextureID;
@synthesize SybolsAndNumbersLayoutTextureID;

// ------------------------------------------------------------------------------ //
// ------------------------------ Unique Font Sytem ----------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Unique Font Sytem

static NSMapTable* m_fontsHolder;

+ (instancetype)fontWithName:(NSString *)name
{
    // Create the fonts holder
    if(m_fontsHolder == nil)
        m_fontsHolder = [NSMapTable strongToWeakObjectsMapTable];
    
    // The font is already loaded?
    GEFont* font = [m_fontsHolder objectForKey:name];
    if(font == nil)
    {
        font = [GEFont new];
        [font loadFontWithName:name];
        [m_fontsHolder setObject:font forKey:name];
    }
    
    return font;
}

- (void)dealloc
{
    [m_fontsHolder removeObjectForKey:m_fontName];
    
    // Remove the texture holder if there is no more textures to hold
    if(m_fontsHolder.count == 0)
        m_fontsHolder = nil;
}

// ------------------------------------------------------------------------------ //
// ------------------------------------- Load ----------------------------------- //
// ------------------------------------------------------------------------------ //
#pragma mark Load

- (void)loadFontWithName:(NSString *)name
{
    // Get the path to the true type font in the bundle.
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"ttf"];
    
    m_fontName = name;

    // Check if the file for this font exist in the bindle.
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        CleanLog(GE_VERBOSE && FN_VERBOSE, @"Font: %@.ttf is not a fount available in this bundle.", name);
        return;
    }
    
    // Initialize the free type library.
    if(FT_Init_FreeType( &m_library ))
    {
        CleanLog(GE_VERBOSE && FN_VERBOSE, @"Font: Free type library can't be initialized.");
        return;
    }
    
    // Load the face from the file.
    if (FT_New_Face(m_library, [path UTF8String], 0, &m_face))
    {
        FT_Done_FreeType(m_library);
        CleanLog(GE_VERBOSE && FN_VERBOSE, @"Font: There was an error loading the face from the file.");
        return;
    }
    
    //Procces font for texture fitting.
    [self preProccesMetricsForTextureSide: 1024];
}

// ------------------------------------------------------------------------------ //
// -------------------------------- Pre Processing ------------------------------ //
// ------------------------------------------------------------------------------ //
#pragma mark Pre Processing

- (void)preProccesMetricsForTextureSide:(unsigned int)side
{
    unsigned int glyph_index;
    
    // Set size for initial size recognition.
    FT_Set_Pixel_Sizes(m_face, 0, 512);
    
    struct gliph_inf
    {
        unsigned int width;
        unsigned int height;
    };
    
    // Max sizes
    unsigned int maxHeight = 0;
    
    // Sizes for lower cases letters.
    for(int i = 97; i < 123; i++)
    {
        // Get the glyph index to load.
        glyph_index= FT_Get_Char_Index(m_face, i);
        
        // Load the gliph information.
        if(FT_Load_Glyph(m_face, glyph_index, FT_LOAD_DEFAULT ))
        {
            CleanLog(GE_VERBOSE && FN_VERBOSE, @"Font: There was an error loading the gliph for '%c'", i);
        }
        unsigned int height = m_face->glyph->metrics.height / 64;
        maxHeight = height > maxHeight ? height : maxHeight;
    }
    
    float heightProportion = maxHeight / 100.0f;
    
    // Set size for por 1/6 texture size
    FT_Set_Pixel_Sizes(m_face, 0, heightProportion * 250);
    
    // Sizes for lower cases letters.
    for(int i = 97; i < 123; i++)
    {
        // Get the glyph index to load.
        glyph_index= FT_Get_Char_Index(m_face, i);
        
        // Load the gliph information.
        if(FT_Load_Glyph(m_face, glyph_index, FT_LOAD_DEFAULT ))
        {
            CleanLog(GE_VERBOSE && FN_VERBOSE, @"Font: There was an error loading the gliph for '%c'", i);
        }
        unsigned int height = m_face->glyph->metrics.height /64;
        maxHeight = height > maxHeight ? height : maxHeight;
    }
    
    heightProportion = maxHeight / 100.0f;
    
}

@end