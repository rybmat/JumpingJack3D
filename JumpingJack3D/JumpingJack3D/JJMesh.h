//
//  JJMesh.h
//  JumpingJack3D
//
//  Created by Maciej Żurad on 7/15/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JJMesh : NSObject

@property GLfloat* textureCoords;
@property GLfloat* vertices;
@property GLfloat* normals;

- (id) init;
- (BOOL) loadModel:(NSString*)filePath;
- (void) dealloc;

@end
