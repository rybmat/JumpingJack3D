//
//  JJDynamicPlatform.h
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 11.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJDynamicObject.h"

@interface JJDynamicPlatform : JJDynamicObject

@property float* texCoords0;
@property GLuint vao;
@property GLuint bufVertices;
@property GLuint bufNormals;
@property GLuint tex0;
@property GLuint bufTexCoords;

- (id) initWithShaderProgram: (JJShaderProgram*) shProg Camera: (JJCamera*) cam Vertices: (float*) verts Normals: (float*) norms VertexCount: (int) vCount PositionX: (float) x Y: (float) y Z: (float) z PathPointB: (glm::vec4) pointB StepSize: (float) stp Texture: (GLuint) tex TextureCoords: (float*) tCoords Number:(int) num;


- (void) render;

@end
