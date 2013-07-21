//
//  JJAssetManager.h
//  JumpingJack3D
//
//  Created by Maciej Żurad on 7/10/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JJShaderProgram.h"
#import "JJMesh.h"

@interface JJAssetManager : NSObject

@property (readonly, strong) NSDictionary* textures;
@property (readonly, strong) NSDictionary* meshes;
@property (readonly, strong) NSDictionary* shaders;

- (id) init;
- (void) load;

- (float*) getVertices: (NSString*) dictionaryKey;
- (float*) getNormals: (NSString*) dictionaryKey;
- (float*) getUvs: (NSString*) dictionaryKey;
- (int) getVertexCount: (NSString*) dictionaryKey;
- (GLuint*) getTexture: (NSString*) dictionaryKey;


@end
