#import "GEmesh.h"
#import "GEtextureshader.h"

@interface GEAnimatedModel : NSObject

- (void)loadModelWithFileName:(NSString*)filename;
- (void)render;

@end
