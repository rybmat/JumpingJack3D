//
//  JJRenderedObject.h
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 10.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGL/gl3.h>
#import "JJShaderProgram.h"

#import "glm/glm.hpp"

#import "JJCamera.h"
#import "JJLight.h"

@interface JJRenderedObject : NSObject

@property JJShaderProgram* shaderProgram;
@property float* vertices;
@property float* normals;
@property int vertexCount;
@property JJCamera* camera;

@property glm::vec3 position;
@property glm::vec3 rotation;
@property glm::vec3 scale;

@property BOOL visible;

- (id) initWithShaderProgram: (JJShaderProgram*) shProg Camera: (JJCamera*) cam Vertices: (float*) verts Normals: (float*) norms VertexCount: (int) vCount PositionX: (float) x Y: (float) y Z: (float) z;

- (void) setVisible:(BOOL)visible;
- (BOOL) isVisible;

- (void) move: (glm::vec3)vector;
- (void) moveX: (float) x Y: (float) y Z: (float) z;
- (void) moveX: (float) direction;
- (void) moveY: (float) direction;
- (void) moveZ: (float) direction;

- (void) rotateX: (float) x Y: (float) y Z: (float) z;
- (void) rotateXby: (float) angle;
- (void) rotateYby: (float) angle;
- (void) rotateZby: (float) angle;

- (void) scaleX: (float) x Y: (float) y Z: (float) z;
- (void) scaleX: (float) scale;
- (void) scaleY: (float) scale;
- (void) scaleZ: (float) scale;

- (glm::mat4) constructModelMatrix;

@end
