//
//  JJStaticEnemy.h
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 11.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJStaticObject.h"

@interface JJStaticEnemy : JJStaticObject

@property float* texCoords0;
@property GLuint vao;
@property GLuint bufVertices;
@property GLuint bufNormals;
@property GLuint tex0;
@property GLuint bufTexCoords0;

- (id) initWithShaderProgram: (JJShaderProgram*) shProg Camera: (JJCamera*) cam Vertices: (float*) verts Normals: (float*) norms VertexCount: (int) vCount PositionX: (float) x Y: (float) y Z: (float) z Texture: (GLuint) tex TexCoords: (float*) tCoords;


- (void) render;
@end
