#import "GEmaterial.h"

@interface GEJoint : NSObject
@property NSString* Name;
@property int ParentID;
@property GLKVector3 Position;
@property GLKQuaternion Orientation;
@end

@interface GEWight : NSObject
@property GLKVector3 Position;
@property GEJoint* Joint;
@property float Bias;
@end

@interface GEVertex : NSObject
@property GLKVector3 Position;
@property GLKVector3 Normal;
@property GLKVector2 TextureCoord;
@property NSMutableArray* Weights;
@end

@interface GETriangle :NSObject
@property GEVertex* Vertex1;
@property GEVertex* Vertex2;
@property GEVertex* Vertex3;
@end

@interface GEMesh : NSObject

@property GEMaterial* Material;
@property NSMutableArray* Vertices;
@property NSMutableArray* Triangles;
@property NSMutableArray* Weights;

@end