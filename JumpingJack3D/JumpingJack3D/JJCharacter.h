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

@property float forwardVelocity;
@property float jumpVelocity;
@property float strafeVelocity;
@property float angularVelocity;
@property float gravity;

@property float radius;

- (id) initWithShaderProgram: (JJShaderProgram*) shProg Camera: (JJCamera*) cam Vertices: (float*) verts Normals: (float*) norms VertexCount: (int) vCount PositionX: (float) x Y: (float) y Z: (float) z Texture: (GLuint) tex TexCoords: (float*) tCoords ;

- (void) setupVBO;

- (void) setupVAO;

- (void) assignVBOtoAttribute: (char*) attributeName BufVBO: (GLuint) bufVBO varSize: (int) variableSize;

- (GLuint) makeBuffer: (void*) data vCount: (int) vertexCount vSize: (int) vertexSize;

- (void) dealloc;

- (void) render;

- (void) moveForwards;
- (void) moveBackwards;
- (void) strafeLeft;
- (void) strafeRight;
- (void) rotateLeft;
- (void) rotateRight;
- (void) rotateBy:(float)angle;
- (void) jump;
- (void) dive;

@end
