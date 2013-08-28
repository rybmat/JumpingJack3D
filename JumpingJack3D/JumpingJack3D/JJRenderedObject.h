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
#import "glm/gtc/quaternion.hpp"

#import "JJCamera.h"
#import "JJLight.h"

@interface JJRenderedObject : NSObject

@property JJShaderProgram* shaderProgram;
@property float* vertices;
@property float* normals;
@property int vertexCount;
@property JJCamera* camera;

@property glm::vec3 scale;
@property glm::vec3 position;
@property glm::vec3 faceVector;
@property glm::quat rotation;


@property BOOL visible;

- (id) initWithShaderProgram: (JJShaderProgram*) shProg Camera: (JJCamera*) cam Vertices: (float*) verts Normals: (float*) norms VertexCount: (int) vCount PositionX: (float) x Y: (float) y Z: (float) z;

- (void) setVisible:(BOOL)visible;
- (BOOL) isVisible;

- (void) move: (glm::vec3)vector;
- (void) moveX: (float) x Y: (float) y Z: (float) z;
- (void) moveX: (float) direction;
- (void) moveY: (float) direction;
- (void) moveZ: (float) direction;

- (void) rotateYby: (float) angle;
- (void) rotateForwardBy: (float) angle;
- (void) rotateSidewardBy: (float) angle;

- (void) scaleX: (float) x Y: (float) y Z: (float) z;
- (void) scaleX: (float) scale;
- (void) scaleY: (float) scale;
- (void) scaleZ: (float) scale;

- (glm::mat4) constructModelMatrix;
- (glm::vec3) getFaceVector;

@end
