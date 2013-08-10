//
//  JJCharacter.m
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 11.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJCharacter.h"

@implementation JJCharacter

float* characterTexCoords0;
GLuint characterVao;
GLuint characterBufVertices;
GLuint characterBufNormals;
GLuint *characterTex0;
GLuint characterBufTexCoords;


- (id) initWithShaderProgram: (JJShaderProgram*) shProg Camera: (JJCamera*) cam Vertices: (float*) verts Normals: (float*) norms VertexCount: (int) vCount PositionX: (float) x Y: (float) y Z: (float) z Texture: (GLuint*) tex TexCoords: (float*) tCoords {
    
    self = [super initWithShaderProgram:shProg
                                 Camera:cam
                               Vertices:verts
                                Normals:norms
                            VertexCount:vCount
                              PositionX:x
                                      Y:y
                                      Z:z];
    
    characterTex0 = tex;
    characterTexCoords0 = tCoords;
    
    [self setupVBO];
    [self setupVAO];
    
    return self;
}

- (void) setupVBO{
    characterBufVertices = [self makeBuffer: [self vertices] vCount: [self vertexCount] vSize: sizeof(float)*4];
	characterBufNormals = [self makeBuffer: [self normals] vCount: [self vertexCount] vSize: sizeof(float)*4];
    characterBufTexCoords = [self makeBuffer: characterTexCoords0 vCount: [self vertexCount] vSize:sizeof(float) *2];
}

- (GLuint) makeBuffer: (void*) data vCount: (int) vertexCount vSize: (int) vertexSize {
	GLuint handle;
	
	glGenBuffers(1,&handle);
	glBindBuffer(GL_ARRAY_BUFFER,handle);
	glBufferData(GL_ARRAY_BUFFER, vertexCount*vertexSize, data, GL_STATIC_DRAW);
    
	return handle;
}

- (void) setupVAO{
    glGenVertexArrays(1,&characterVao);
	glBindVertexArray(characterVao);
    
	[self assignVBOtoAttribute:"vertex" BufVBO: characterBufVertices varSize:4];
	[self assignVBOtoAttribute:"normal" BufVBO: characterBufNormals varSize:4];
    [self assignVBOtoAttribute:"texCoords0" BufVBO: characterBufTexCoords varSize:2];
	
	glBindVertexArray(0);
    
}

- (void) assignVBOtoAttribute: (char*) attributeName BufVBO: (GLuint) bufVBO varSize: (int) variableSize {
	GLuint location=[[self shaderProgram] getAttribLocation:attributeName];
	glBindBuffer(GL_ARRAY_BUFFER,bufVBO);
	glEnableVertexAttribArray(location);
	glVertexAttribPointer(location,variableSize,GL_FLOAT, GL_FALSE, 0, NULL);
}

- (void) dealloc{
    glDeleteVertexArrays(1,&characterVao);
    
    glDeleteBuffers(1,&characterBufVertices);
	glDeleteBuffers(1,&characterBufNormals);
    glDeleteBuffers(1, &characterBufTexCoords);
    
    glDeleteTextures(1, characterTex0);
    
}

- (void) render{
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, *characterTex0);
    
    [[self shaderProgram] use];
    
    glUniformMatrix4fv([[self shaderProgram] getUniformLocation:"P"],1, false, glm::value_ptr([[self camera] projectionMatrix]));
	glUniformMatrix4fv([[self shaderProgram] getUniformLocation:"V" ],1, false, glm::value_ptr([[self camera] viewMatrix]));
	glUniformMatrix4fv([[self shaderProgram] getUniformLocation:"M"],1, false, glm::value_ptr([self matM]));
	glUniform1i([[self shaderProgram] getUniformLocation:"textureMap0"], 0);
    glUniform4fv([[self shaderProgram] getUniformLocation:"lp0"], 1, [JJLight getFirstLight]);
    glUniform4fv([[self shaderProgram] getUniformLocation:"lp1"], 1, [JJLight getSecondLight]);
    
    glBindVertexArray(characterVao);
    
	//Narysowanie obiektu
    glDrawArrays(GL_TRIANGLES,0,[self vertexCount]);
}

@end
