//
//  JJCharacter.m
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 11.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJCharacter.h"

@implementation JJCharacter

@synthesize deccelerate;

float yVelocity;
float forwardVelocity;
float strafeVelocity;

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
    
    self.jumped = NO;
    
    [self setupVBO];
    [self setupVAO];
        
    self.maxForwardVelocity = 40;
    self.maxJumpVelocity = 40;
    self.maxStrafeVelocity = 40;
    
    self.angularVelocity = 270;
    self.gravity = 30 ;
    
    self.acceleration = 20;
    self.decceleration = self.acceleration / 1.0f;
    
    self.deccelerate = YES;
    
    self.radius = 1.0f;
    
    return self;
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
	glUniformMatrix4fv([[self shaderProgram] getUniformLocation:"M"],1, false, glm::value_ptr([self constructModelMatrix]));
	glUniform1i([[self shaderProgram] getUniformLocation:"textureMap0"], 0);
    glUniform4fv([[self shaderProgram] getUniformLocation:"lp0"], 1, [JJLight getFirstLight]);
    glUniform4fv([[self shaderProgram] getUniformLocation:"lp1"], 1, [JJLight getSecondLight]);
    
    glBindVertexArray(_vao);
    
	//Narysowanie obiektu
    glDrawArrays(GL_TRIANGLES,0,[self vertexCount]);
}

- (void) applyPhysics
{
    if (forwardVelocity > self.maxForwardVelocity) {
        forwardVelocity = self.maxForwardVelocity;
    }
    if (forwardVelocity < -self.maxForwardVelocity) {
        forwardVelocity = -self.maxForwardVelocity;
    }
    if (strafeVelocity > self.maxStrafeVelocity) {
        strafeVelocity = self.maxStrafeVelocity;
    }
    if (strafeVelocity < -self.maxStrafeVelocity) {
        strafeVelocity = -self.maxStrafeVelocity;
    }
    
    if (self.jumped == YES) {
        yVelocity -= self.gravity / 60.0f;
        [self moveY:yVelocity / 60.0f];
    }
    glm::vec3 moveVector = forwardVelocity / 60.0f * self.getFaceVector;
    [self move:moveVector];
    int rotateSign = (forwardVelocity > 0 ) ? -1 : 1;
    [self rotateForwardBy: rotateSign * [self calculateRotationFromMoveVector:moveVector]];
    
    glm::vec3 strafeVector = glm::cross(self.getFaceVector, glm::vec3(0.0f,1.0f,0.0f));
    moveVector = strafeVelocity / 60.0f * strafeVector;
    [self move:moveVector];
    rotateSign = (strafeVelocity > 0) ? 1 : -1;
    [self rotateSidewardBy: rotateSign * [self calculateRotationFromMoveVector:moveVector]];
    
    if (self.deccelerate == YES) {
        float deccelerationStep = self.deccelerate / 60.0f;
        forwardVelocity += (forwardVelocity > 0) ? -deccelerationStep : deccelerationStep;
        strafeVelocity  += (strafeVelocity  > 0) ? -deccelerationStep : deccelerationStep;
    }
    
}

- (void) moveForwards
{
    self.deccelerate = NO;

    forwardVelocity += self.acceleration / 60.0f;

}

- (void) moveBackwards
{
    self.deccelerate = NO;
    
    forwardVelocity -= self.acceleration / 60.0f;

}

- (void) strafeRight
{
    self.deccelerate = NO;
    
    strafeVelocity += self.acceleration / 60.0f;

}

- (void) strafeLeft
{
    self.deccelerate = NO;
    
    strafeVelocity -= self.acceleration / 60.0f;

}

- (void) rotateRight
{
    float angle = - self.angularVelocity / 60.0f;
    [self rotateYby:angle];
}

- (void) rotateLeft
{
    float angle = self.angularVelocity / 60.0f;
    [self rotateYby:angle];
}

- (void) rotateBy:(float)angle
{
    [self rotateYby:angle];
}

- (void) jump
{
    if (self.jumped == YES) {
        return;
    }
    yVelocity = self.maxJumpVelocity;
    self.jumped = YES;
}

- (void) dive
{
    if (self.jumped == NO) {
        return;
    }
    yVelocity = -self.maxJumpVelocity;
}

- (float) calculateRotationFromMoveVector:(glm::vec3)vector
{
    float length = glm::length(vector);
    float angle = length * 180 / (3.1415 * self.radius);
    return angle;
}

@end
