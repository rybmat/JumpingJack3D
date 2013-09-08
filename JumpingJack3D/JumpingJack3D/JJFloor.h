//
//  JJFloor.h
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 01.09.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJStaticObject.h"

@interface JJFloor : JJStaticObject

@property float* texCoords0;
@property GLuint vao;
@property GLuint bufVertices;
@property GLuint bufNormals;
@property GLuint tex0;
@property GLuint tex1;
@property GLuint bufTexCoords;

- (id) initWithShaderProgram: (JJShaderProgram*) shProg Camera: (JJCamera*) cam Vertices: (float*) verts Normals: (float*) norms VertexCount: (int) vCount PositionX: (float) x Y: (float) y Z: (float) z Texture: (GLuint) tex Texture2: (GLuint) tex2 TexCoords: (float*) tCoords;


- (void) render;

@end
