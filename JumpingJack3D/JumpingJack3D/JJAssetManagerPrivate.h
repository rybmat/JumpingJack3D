//
//  JJAssetManager_Private.h
//  JumpingJack3D
//
//  Created by Maciej Żurad on 7/15/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJAssetManager.h"
#define FOURCC_DXT1 0x31545844 // Equivalent to "DXT1" in ASCII
#define FOURCC_DXT3 0x33545844 // Equivalent to "DXT3" in ASCII
#define FOURCC_DXT5 0x35545844 // Equivalent to "DXT5" in ASCII


@interface JJAssetManager () {}

typedef enum _extensionType {
    VERTEX_SHADER = 0,
    GEOMETRY_SHADER = 1,
    FRAGMENT_SHADER = 2,
    TGA = 3,
    PNG = 4,
    OBJ = 5,
    DDS = 6
} extensionType;

@property NSBundle* mainBundle;
@property NSArray* extensions;

@property (readonly, strong) NSDictionary* textures;
@property (readonly, strong) NSDictionary* meshes;
@property (readonly, strong) NSDictionary* shaders;

- (BOOL) loadTexture: (NSString*)fileName withColorMode: (GLuint)cmode texHandler: (GLuint*)tex;
- (NSDictionary*) createShaderDirsDictionary:(extensionType)aType;
- (void) loadShaders;
- (void) loadTextures;
- (void) loadMeshes;

@end
