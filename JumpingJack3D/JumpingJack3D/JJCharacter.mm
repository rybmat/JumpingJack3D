//
//  JJCharacter.m
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 11.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJCharacter.h"

@implementation JJCharacter

@synthesize faceVector;


- (id) initWithShaderProgram: (JJShaderProgram*) shProg Camera: (JJCamera*) cam Vertices: (float*) verts Normals: (float*) norms VertexCount: (int) vCount PositionX: (float) x Y: (float) y Z: (float) z Texture: (GLuint) tex TexCoords: (float*) tCoords {
    
    self = [super initWithShaderProgram:shProg
                                 Camera:cam
                               Vertices:verts
                                Normals:norms
                            VertexCount:vCount
                              PositionX:x
                                      Y:y
                                      Z:z];
    
    _tex0 = tex;
    _texCoords0 = tCoords;
    
    [self setFaceVector:glm::vec4(0.0f, 0.0f, 10.0f, 0.0f)];
    
    [self setupVBO];
    [self setupVAO];
    
    self.XAxisVelocity = 15;
    self.YAxisVelocity = 15;
    self.ZAxisVelocity = 15;
    self.gravity = 0.02;
    
    return self;
}

- (glm::vec3) getFaceVectorInWorldSpace{
    glm::vec4 tmp4 = [self matM]*[self faceVector];
    glm::vec3 tmp3 = glm::vec3(tmp4.x, tmp4.y, tmp4.z);
    return tmp3;
}

- (void) setupVBO{
    _bufVertices = [self makeBuffer: [self vertices] vCount: [self vertexCount] vSize: sizeof(float)*4];
	_bufNormals = [self makeBuffer: [self normals] vCount: [self vertexCount] vSize: sizeof(float)*4];
    _bufTexCoords = [self makeBuffer: _texCoords0 vCount: [self vertexCount] vSize:sizeof(float) *2];
}

- (GLuint) makeBuffer: (void*) data vCount: (int) vertexCount vSize: (int) vertexSize {
	GLuint handle;
	
	glGenBuffers(1,&handle);
	glBindBuffer(GL_ARRAY_BUFFER,handle);
	glBufferData(GL_ARRAY_BUFFER, vertexCount*vertexSize, data, GL_STATIC_DRAW);
    
	return handle;
}

- (void) setupVAO{
    glGenVertexArrays(1,&_vao);
	glBindVertexArray(_vao);
    
	[self assignVBOtoAttribute:"vertex" BufVBO: _bufVertices varSize:4];
	[self assignVBOtoAttribute:"normal" BufVBO: _bufNormals varSize:4];
    [self assignVBOtoAttribute:"texCoords0" BufVBO: _bufTexCoords varSize:2];
	
	glBindVertexArray(0);
    
}

- (void) assignVBOtoAttribute: (char*) attributeName BufVBO: (GLuint) bufVBO varSize: (int) variableSize {
	GLuint location=[[self shaderProgram] getAttribLocation:attributeName];
	glBindBuffer(GL_ARRAY_BUFFER,bufVBO);
	glEnableVertexAttribArray(location);
	glVertexAttribPointer(location,variableSize,GL_FLOAT, GL_FALSE, 0, NULL);
}

- (void) dealloc{
    glDeleteVertexArrays(1,&_vao);
    
    glDeleteBuffers(1,&_bufVertices);
	glDeleteBuffers(1,&_bufNormals);
    glDeleteBuffers(1, &_bufTexCoords);
    
    glDeleteTextures(1, &_tex0);
    
}

- (void) render{
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _tex0);
    
    [[self shaderProgram] use];
    
    glUniformMatrix4fv([[self shaderProgram] getUniformLocation:"P"],1, false, glm::value_ptr([[self camera] projectionMatrix]));
	glUniformMatrix4fv([[self shaderProgram] getUniformLocation:"V" ],1, false, glm::value_ptr([[self camera] viewMatrix]));
	glUniformMatrix4fv([[self shaderProgram] getUniformLocation:"M"],1, false, glm::value_ptr([self matM]));
	glUniform1i([[self shaderProgram] getUniformLocation:"textureMap0"], 0);
    glUniform4fv([[self shaderProgram] getUniformLocation:"lp0"], 1, [JJLight getFirstLight]);
    glUniform4fv([[self shaderProgram] getUniformLocation:"lp1"], 1, [JJLight getSecondLight]);
    
    glBindVertexArray(_vao);
    
	//Narysowanie obiektu
    glDrawArrays(GL_TRIANGLES,0,[self vertexCount]);
}
- (void) moveXwithDirection:(int) direction;
{
    [self moveX:self.XAxisVelocity/60.0f * direction];
}

- (void) moveYwithDirection:(int) direction;
{
    [self moveY:self.YAxisVelocity/60.0f * direction];
}

- (void) moveZwithDirection:(int) direction;
{

    [self moveZ:self.ZAxisVelocity/60.0f * direction];

}

- (void) jump
{
    
}

@end
