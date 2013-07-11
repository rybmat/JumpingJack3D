//
//  JJDynamicEnemy.m
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 11.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJDynamicEnemy.h"

@implementation JJDynamicEnemy

float* dynamicEnemyTexCoords0;
GLuint dynamicEnemyVao;
GLuint dynamicEnemyBufVertices;
GLuint dynamicEnemyBufNormals;
GLuint *dynamicEnemyTex0;
GLuint dynamicEnemyBufTexCoords;


- (id) initWithShaderProgram: (JJShaderProgram*) shProg Vertices: (float*) verts Normals: (float*) norms VertexCount: (int) vCount PositionX: (float) x Y: (float) y Z: (float) z Texture: (GLuint*) tex TexCoords: (float*) tCoords {
    
    self = [super initWithShaderProgram:shProg
                               Vertices:verts
                                Normals:norms
                            VertexCount:vCount
                              PositionX:x
                                      Y:y
                                      Z:z];
    
    dynamicEnemyTex0 = tex;
    dynamicEnemyTexCoords0 = tCoords;
    return self;
}

- (void) setupVBO{
    dynamicEnemyBufVertices = [self makeBuffer: [self vertices] vCount: [self vertexCount] vSize: sizeof(float)*4];
	dynamicEnemyBufNormals = [self makeBuffer: [self normals] vCount: [self vertexCount] vSize: sizeof(float)*4];
    dynamicEnemyBufTexCoords = [self makeBuffer: dynamicEnemyTexCoords0 vCount: [self vertexCount] vSize:sizeof(float) *2];
}

- (GLuint) makeBuffer: (void*) data vCount: (int) vertexCount vSize: (int) vertexSize {
	GLuint handle;
	
	glGenBuffers(1,&handle);
	glBindBuffer(GL_ARRAY_BUFFER,handle);
	glBufferData(GL_ARRAY_BUFFER, vertexCount*vertexSize, data, GL_STATIC_DRAW);
    
	return handle;
}

- (void) setupVAO{
    glGenVertexArrays(1,&dynamicEnemyVao);
	glBindVertexArray(dynamicEnemyVao);
    
	[self assignVBOtoAttribute:"vertex" BufVBO: dynamicEnemyBufVertices varSize:4];
	[self assignVBOtoAttribute:"normal" BufVBO: dynamicEnemyBufNormals varSize:4];
    [self assignVBOtoAttribute:"texCoords0" BufVBO: dynamicEnemyBufTexCoords varSize:2];
	
	glBindVertexArray(0);
    
}

- (void) assignVBOtoAttribute: (char*) attributeName BufVBO: (GLuint) bufVBO varSize: (int) variableSize {
	GLuint location=[[self shaderProgram] getAttribLocation:attributeName];
	glBindBuffer(GL_ARRAY_BUFFER,bufVBO);
	glEnableVertexAttribArray(location);
	glVertexAttribPointer(location,variableSize,GL_FLOAT, GL_FALSE, 0, NULL);
}

- (void) dealloc{
    glDeleteVertexArrays(1,&dynamicEnemyVao);
    
    glDeleteBuffers(1,&dynamicEnemyBufVertices);
	glDeleteBuffers(1,&dynamicEnemyBufNormals);
    glDeleteBuffers(1, &dynamicEnemyBufTexCoords);
    
    glDeleteTextures(1, dynamicEnemyTex0);
    
}

- (void) render{
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, *dynamicEnemyTex0);
    
    [[self shaderProgram] use];
    
    //glUniformMatrix4fv([[self shaderProgram] getUniformLocation:"P"],1, false, glm::value_ptr([JJSceneObject matP]));
	//glUniformMatrix4fv([[self shaderProgram] getUniformLocation:"V" ],1, false, glm::value_ptr([JJSceneObject matV]));
	glUniformMatrix4fv([[self shaderProgram] getUniformLocation:"M"],1, false, glm::value_ptr([self matM]));
	glUniform1i([[self shaderProgram] getUniformLocation:"textureMap0"], 0);
    
    
    glBindVertexArray(dynamicEnemyVao);
    
	//Narysowanie obiektu
    glDrawArrays(GL_TRIANGLES,0,[self vertexCount]);
	
}

@end
