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

@property (strong) NSDictionary* textures;
@property (strong) NSDictionary* meshes;
@property (strong) NSDictionary* shaders;

- (id) init;
- (void) load;


@end
