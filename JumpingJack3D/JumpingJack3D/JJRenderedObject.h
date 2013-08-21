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
#import "glm/gtc/matrix_transform.hpp"
#import "glm/gtc/type_ptr.hpp"

#import "JJCamera.h"
#import "JJLight.h"

@interface JJRenderedObject : NSObject

@property glm::mat4 matM;
@property JJShaderProgram* shaderProgram;
@property float* vertices;
@property float* normals;
@property int vertexCount;
@property JJCamera* camera;
@property glm::vec3 faceVector;

@property BOOL visible;

- (id) initWithShaderProgram: (JJShaderProgram*) shProg Camera: (JJCamera*) cam Vertices: (float*) verts Normals: (float*) norms VertexCount: (int) vCount PositionX: (float) x Y: (float) y Z: (float) z;

- (void) setVisible:(BOOL)visible;
- (BOOL) isVisible;

- (void) moveX: (float) x Y: (float) y Z: (float) z;
- (void) moveX: (float) direction;
- (void) moveY: (float) direction;
- (void) moveZ: (float) direction;

- (void) rotateX: (float) x Y: (float) y Z: (float) z ByAngle: (float) angle;
- (void) rotateX: (float) direction byAngle: (float) angle;
- (void) rotateY: (float) direction byAngle: (float) angle;
- (void) rotateZ: (float) direction byAngle: (float) angle;

- (void) scaleX: (float) x Y: (float) y Z: (float) z;
- (void) scaleX: (float) scale;
- (void) scaleY: (float) scale;
- (void) scaleZ: (float) scale;


- (glm::vec3) getModelPosition; //x,y,z
@end
