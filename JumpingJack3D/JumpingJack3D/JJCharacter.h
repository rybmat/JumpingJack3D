//
//  JJCharacter.h
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 11.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJRenderedObject.h"

@interface JJCharacter : JJRenderedObject

@property float* texCoords0;
@property GLuint vao;
@property GLuint bufVertices;
@property GLuint bufNormals;
@property GLuint tex0;
@property GLuint bufTexCoords;

@property float maxForwardVelocity;
@property float maxJumpVelocity;
@property float maxStrafeVelocity;
@property float angularVelocity;

@property float acceleration;
@property float decceleration; //energy loss
@property float gravity;

@property float radius;

@property BOOL deccelerate;
@property BOOL jumped;

- (id) initWithShaderProgram: (JJShaderProgram*) shProg Camera: (JJCamera*) cam Vertices: (float*) verts Normals: (float*) norms VertexCount: (int) vCount PositionX: (float) x Y: (float) y Z: (float) z Texture: (GLuint) tex TexCoords: (float*) tCoords frameRate:(int)ratewwww;

- (void) setupVBO;

- (void) setupVAO;

- (void) assignVBOtoAttribute: (char*) attributeName BufVBO: (GLuint) bufVBO varSize: (int) variableSize;

- (GLuint) makeBuffer: (void*) data vCount: (int) vertexCount vSize: (int) vertexSize;

- (void) dealloc;

- (void) render;

- (void) applyPhysics;

- (void) moveForwards;
- (void) moveBackwards;
- (void) strafeLeft;
- (void) strafeRight;
- (void) rotateLeft;
- (void) rotateRight;
- (void) rotateBy:(float)angle;
- (void) jump;
- (void) dive;

- (void) changeFrameRate:(int)frameRate;

@end
