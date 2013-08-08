//
//  JJMesh.h
//  JumpingJack3D
//
//  Created by Maciej Żurad on 7/15/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "glm/glm.hpp"

@interface JJMesh : NSObject {

}

@property (readonly) int uncompressedVertexCount;
@property (readonly) int vertexCount;
@property (readonly) int normalsCount;
@property (readonly) int uvCount;
@property (readonly) int faceCount;

@property (readonly) GLfloat* vertices;
@property (readonly) GLfloat* normals;
@property (readonly) GLfloat* uvs;

- (id) init;
- (BOOL) loadModel:(NSString*)filePath;
- (void) setCountsWithLines:(NSArray*) lines;
- (void) dealloc;

@end
