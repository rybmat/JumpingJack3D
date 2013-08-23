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
@property glm::vec4 faceVector;
@property float XAxisVelocity;
@property float YAxisVelocity;
@property float ZAxisVelocity;
@property float gravity;

- (id) initWithShaderProgram: (JJShaderProgram*) shProg Camera: (JJCamera*) cam Vertices: (float*) verts Normals: (float*) norms VertexCount: (int) vCount PositionX: (float) x Y: (float) y Z: (float) z Texture: (GLuint) tex TexCoords: (float*) tCoords ;

- (glm::vec3) getFaceVectorInWorldSpace;

- (void) setupVBO;

- (GLuint) makeBuffer: (void*) data vCount: (int) vertexCount vSize: (int) vertexSize;

- (void) setupVAO;

- (void) assignVBOtoAttribute: (char*) attributeName BufVBO: (GLuint) bufVBO varSize: (int) variableSize;

- (void) dealloc;

- (void) render;

- (void) moveXwithDirection:(int) direction;
- (void) moveYwithDirection:(int) direction;
- (void) moveZwithDirection:(int) direction;
@end
