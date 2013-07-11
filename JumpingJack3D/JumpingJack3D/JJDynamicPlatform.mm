//
//  JJDynamicPlatform.m
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 11.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJDynamicPlatform.h"

@implementation JJDynamicPlatform

float* dynamicPlatformTexCoords0;
GLuint dynamicPlatformVao;
GLuint dynamicPlatformBufVertices;
GLuint dynamicPlatformBufNormals;
GLuint *dynamicPlatformTex0;
GLuint dynamicPlatformBufTexCoords;


- (id) initWithShaderProgram: (JJShaderProgram*) shProg Vertices: (float*) verts Normals: (float*) norms VertexCount: (int) vCount PositionX: (float) x Y: (float) y Z: (float) z Texture: (GLuint*) tex TexCoords: (float*) tCoords {
    
    self = [super initWithShaderProgram:shProg
                               Vertices:verts
                                Normals:norms
                            VertexCount:vCount
                              PositionX:x
                                      Y:y
                                      Z:z];
    
    dynamicPlatformTex0 = tex;
    dynamicPlatformTexCoords0 = tCoords;
    return self;
}

- (void) setupVBO{
    dynamicPlatformBufVertices = [self makeBuffer: [self vertices] vCount: [self vertexCount] vSize: sizeof(float)*4];
	dynamicPlatformBufNormals = [self makeBuffer: [self normals] vCount: [self vertexCount] vSize: sizeof(float)*4];
    dynamicPlatformBufTexCoords = [self makeBuffer: dynamicPlatformTexCoords0 vCount: [self vertexCount] vSize:sizeof(float) *2];
}

- (GLuint) makeBuffer: (void*) data vCount: (int) vertexCount vSize: (int) vertexSize {
	GLuint handle;
	
	glGenBuffers(1,&handle);
	glBindBuffer(GL_ARRAY_BUFFER,handle);
	glBufferData(GL_ARRAY_BUFFER, vertexCount*vertexSize, data, GL_STATIC_DRAW);
    
	return handle;
}

- (void) setupVAO{
    glGenVertexArrays(1,&dynamicPlatformVao);
	glBindVertexArray(dynamicPlatformVao);
    
	[self assignVBOtoAttribute:"vertex" BufVBO: dynamicPlatformBufVertices varSize:4];
	[self assignVBOtoAttribute:"normal" BufVBO: dynamicPlatformBufNormals varSize:4];
    [self assignVBOtoAttribute:"texCoords0" BufVBO: dynamicPlatformBufTexCoords varSize:2];
	
	glBindVertexArray(0);
    
}

- (void) assignVBOtoAttribute: (char*) attributeName BufVBO: (GLuint) bufVBO varSize: (int) variableSize {
	GLuint location=[[self shaderProgram] getAttribLocation:attributeName];
	glBindBuffer(GL_ARRAY_BUFFER,bufVBO);
	glEnableVertexAttribArray(location);
	glVertexAttribPointer(location,variableSize,GL_FLOAT, GL_FALSE, 0, NULL);
}

- (void) dealloc{
    glDeleteVertexArrays(1,&dynamicPlatformVao);
    
    glDeleteBuffers(1,&dynamicPlatformBufVertices);
	glDeleteBuffers(1,&dynamicPlatformBufNormals);
    glDeleteBuffers(1, &dynamicPlatformBufTexCoords);
    
    glDeleteTextures(1, dynamicPlatformTex0);
    
}

- (void) render{
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, *dynamicPlatformTex0);
    
    [[self shaderProgram] use];
    
    //glUniformMatrix4fv([[self shaderProgram] getUniformLocation:"P"],1, false, glm::value_ptr([JJSceneObject matP]));
	//glUniformMatrix4fv([[self shaderProgram] getUniformLocation:"V" ],1, false, glm::value_ptr([JJSceneObject matV]));
	glUniformMatrix4fv([[self shaderProgram] getUniformLocation:"M"],1, false, glm::value_ptr([self matM]));
	glUniform1i([[self shaderProgram] getUniformLocation:"textureMap0"], 0);
    
    
    glBindVertexArray(dynamicPlatformVao);
    
	//Narysowanie obiektu
    glDrawArrays(GL_TRIANGLES,0,[self vertexCount]);
	
}

@end
