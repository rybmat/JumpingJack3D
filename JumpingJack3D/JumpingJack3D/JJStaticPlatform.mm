//
//  JJStaticPlatform.m
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 11.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJStaticPlatform.h"

@implementation JJStaticPlatform

float* staticPlatformTexCoords0;
GLuint staticPlatformVao;
GLuint staticPlatformBufVertices;
GLuint staticPlatformBufNormals;
GLuint *staticPlatformTex0;
GLuint staticPlatformBufTexCoords;


- (id) initWithShaderProgram: (JJShaderProgram*) shProg Camera: (JJCamera*) cam Vertices: (float*) verts Normals: (float*) norms VertexCount: (int) vCount PositionX: (float) x Y: (float) y Z: (float) z Texture: (GLuint*) tex TexCoords: (float*) tCoords {
    
    self = [super initWithShaderProgram:shProg
                                 Camera:cam
                               Vertices:verts
                                Normals:norms
                            VertexCount:vCount
                              PositionX:x
                                      Y:y
                                      Z:z];
    
    staticPlatformTex0 = tex;
    staticPlatformTexCoords0 = tCoords;
    return self;
}

- (void) setupVBO{
    staticPlatformBufVertices = [self makeBuffer: [self vertices] vCount: [self vertexCount] vSize: sizeof(float)*4];
	staticPlatformBufNormals = [self makeBuffer: [self normals] vCount: [self vertexCount] vSize: sizeof(float)*4];
    staticPlatformBufTexCoords = [self makeBuffer: staticPlatformTexCoords0 vCount: [self vertexCount] vSize:sizeof(float) *2];    
}

- (GLuint) makeBuffer: (void*) data vCount: (int) vertexCount vSize: (int) vertexSize {
	GLuint handle;
	
	glGenBuffers(1,&handle);
	glBindBuffer(GL_ARRAY_BUFFER,handle);
	glBufferData(GL_ARRAY_BUFFER, vertexCount*vertexSize, data, GL_STATIC_DRAW);
    
	return handle;
}

- (void) setupVAO{
    glGenVertexArrays(1,&staticPlatformVao);
	glBindVertexArray(staticPlatformVao);
    
	[self assignVBOtoAttribute:"vertex" BufVBO: staticPlatformBufVertices varSize:4];
	[self assignVBOtoAttribute:"normal" BufVBO: staticPlatformBufNormals varSize:4];
    [self assignVBOtoAttribute:"texCoords0" BufVBO: staticPlatformBufTexCoords varSize:2];
	
	glBindVertexArray(0);
    
}

- (void) assignVBOtoAttribute: (char*) attributeName BufVBO: (GLuint) bufVBO varSize: (int) variableSize {
	GLuint location=[[self shaderProgram] getAttribLocation:attributeName];
	glBindBuffer(GL_ARRAY_BUFFER,bufVBO);
	glEnableVertexAttribArray(location);
	glVertexAttribPointer(location,variableSize,GL_FLOAT, GL_FALSE, 0, NULL);
}

- (void) dealloc{
    glDeleteVertexArrays(1,&staticPlatformVao);
    
    glDeleteBuffers(1,&staticPlatformBufVertices);
	glDeleteBuffers(1,&staticPlatformBufNormals);
    glDeleteBuffers(1, &staticPlatformBufTexCoords);
    
    glDeleteTextures(1, staticPlatformTex0);
    
}

- (void) render{
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, *staticPlatformTex0);
    
    [[self shaderProgram] use];
    
    glUniformMatrix4fv([[self shaderProgram] getUniformLocation:"P"],1, false, glm::value_ptr([[self camera] projectionMatrix]));
	glUniformMatrix4fv([[self shaderProgram] getUniformLocation:"V" ],1, false, glm::value_ptr([[self camera] viewMatrix]));
	glUniformMatrix4fv([[self shaderProgram] getUniformLocation:"M"],1, false, glm::value_ptr([self matM]));
	glUniform1i([[self shaderProgram] getUniformLocation:"textureMap0"], 0);
    glUniform1fv([[self shaderProgram] getUniformLocation:"lp0"], 1, glm::value_ptr([JJLight getFirstLight]));
    glUniform1fv([[self shaderProgram] getUniformLocation:"lp1"], 1, glm::value_ptr([JJLight getSecondLight]));
    
    glBindVertexArray(staticPlatformVao);
    
	//Narysowanie obiektu
    glDrawArrays(GL_TRIANGLES,0,[self vertexCount]);
}

@end
