//
//  JJAssetManager_Private.h
//  JumpingJack3D
//
//  Created by Maciej Żurad on 7/15/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJAssetManager.h"

@interface JJAssetManager () {}

typedef enum _extensionType {
    VERTEX_SHADER = 0,
    GEOMETRY_SHADER = 1,
    FRAGMENT_SHADER = 2,
    TGA = 3,
    PNG = 4,
    OBJ = 5
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
