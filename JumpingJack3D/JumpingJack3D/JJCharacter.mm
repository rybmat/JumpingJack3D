//
//  JJCharacter.m
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 11.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJCharacter.h"

@implementation JJCharacter

float yVelocity;
float forwardVelocity;
float strafeVelocity;

float jumpKineticEnergy;

float invertedFrameRate;

int savedScore;

float explosionState = 0.0f;
float maxExplosionState = 1000.0f;

BOOL isExploding = NO;

BOOL setToDie = NO;

- (id) initWithShaderProgram: (JJShaderProgram*) shProg Camera: (JJCamera*) cam Vertices: (float*) verts Normals: (float*) norms VertexCount: (int) vCount PositionX: (float) x Y: (float) y Z: (float) z Texture: (GLuint) tex TexCoords: (float*) tCoords frameRate:(int) rate{
    
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
    
    yVelocity = forwardVelocity = strafeVelocity = jumpKineticEnergy = 0.0f;
    
    invertedFrameRate = (float) 1 / rate;
    
    self.jumped = NO;
    
    [self setupVBO];
    [self setupVAO];
        
    self.maxForwardVelocity = 10;
    self.maxJumpVelocity = 22;
    self.maxStrafeVelocity = 10;
    self.angularVelocity = 270;
    self.gravity = 30 ;
    
    self.acceleration = 20;
    self.decceleration = self.acceleration / 20.0f;
    
    self.deccelerateStrafe  = YES;
    self.deccelerateForward = YES;
    
    self.horizontalCollisionEnergyLoss = 0.2f;
    self.verticalCollisionEnergyLoss   = 0.5f;
    
    self.deathSpeed = 50.0f;
    
    self.checkPoint = self.position;
    
    self.score = 0;
    self.lives = 5;
    
    savedScore = 0;
    
    return self;
}

- (void) setupVBO{
    
    float* velMulBuffer = (float*)malloc(sizeof(float) * [self vertexCount]);
    
    for (int i=0; i < [self vertexCount]; i++) {
        velMulBuffer[i] = ((float)rand() / RAND_MAX) + .5f;
    }
    
    _bufVertices   = [self makeBuffer: [self vertices] vCount: [self vertexCount] vSize: sizeof(float)*4];
	_bufNormals    = [self makeBuffer: [self normals] vCount: [self vertexCount] vSize: sizeof(float)*4];
    _bufTexCoords  = [self makeBuffer: _texCoords0 vCount: [self vertexCount] vSize:sizeof(float) *2];
    _velMultiplier = [self makeBuffer:velMulBuffer vCount: [self vertexCount] vSize:sizeof(float)];
    
    free(velMulBuffer);
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
    
	[self assignVBOtoAttribute:@"vertex" BufVBO: _bufVertices varSize:4];
	[self assignVBOtoAttribute:@"normal" BufVBO: _bufNormals varSize:4];
    [self assignVBOtoAttribute:@"texCoords0" BufVBO: _bufTexCoords varSize:2];
	[self assignVBOtoAttribute:@"velocities" BufVBO: _velMultiplier varSize:1];
    
	glBindVertexArray(0);
    
}

- (void) assignVBOtoAttribute: (NSString*) attributeName BufVBO: (GLuint) bufVBO varSize: (int) variableSize {
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
    glDeleteBuffers(1, &_velMultiplier);
    
    glDeleteTextures(1, &_tex0);
    
}

- (void) render{
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _tex0);
    
    [[self shaderProgram] use];
    
    glUniformMatrix4fv([[self shaderProgram] getUniformLocation:@"P"],1, false, glm::value_ptr([[self camera] projectionMatrix]));
	glUniformMatrix4fv([[self shaderProgram] getUniformLocation:@"V" ],1, false, glm::value_ptr([[self camera] viewMatrix]));
	glUniformMatrix4fv([[self shaderProgram] getUniformLocation:@"M"],1, false, glm::value_ptr([self constructModelMatrix]));
	glUniform1i([[self shaderProgram] getUniformLocation:@"textureMap0"], 0);
    glUniform4fv([[self shaderProgram] getUniformLocation:@"lp0"], 1, [JJLight getFirstLight]);
    glUniform4fv([[self shaderProgram] getUniformLocation:@"lp1"], 1, [JJLight getSecondLight]);
    
    glUniform1f([[self shaderProgram] getUniformLocation:@"time"], explosionState);
    
    glBindVertexArray(_vao);
    
	//Narysowanie obiektu
    glDrawArrays(GL_TRIANGLES,0,[self vertexCount]);
}

- (void) applyPhysics
{
    // Explosion handling
    if (isExploding == YES) {
        explosionState += 15.0f;
        if (explosionState >= maxExplosionState - 0.05) {
            [self explosionEnded];
        }
    } else {
        
        // Velocity constraints handling
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
        
        
        yVelocity -= self.gravity * invertedFrameRate;
        [self moveY:yVelocity * invertedFrameRate];
        
        if (yVelocity < -self.deathSpeed and setToDie == NO) {
            [self.camera lock];
            setToDie = YES;
            return;
        }

        if (setToDie == YES and self.position.y < 20.0) {
            [self.camera prepareDeathCam:self.position];
        }
        
        glm::vec3 moveForwardVector = forwardVelocity * invertedFrameRate * self.getFaceVector;
        [self move:moveForwardVector];

        
        glm::vec3 strafeVector = glm::cross(self.getFaceVector, glm::vec3(0.0f,1.0f,0.0f));
        glm::vec3 moveSidewardVector = strafeVelocity * invertedFrameRate * strafeVector;
        [self move:moveSidewardVector];

        
        if (self.deccelerateForward == YES) {
            float deccelerationStep = self.decceleration * invertedFrameRate;
            forwardVelocity += (forwardVelocity > 0) ? -deccelerationStep : deccelerationStep;
        }
        
        if (self.deccelerateStrafe == YES) {
            float deccelerationStep = self.decceleration * invertedFrameRate;
            strafeVelocity  += (strafeVelocity  > 0) ? -deccelerationStep : deccelerationStep;
        }
        
        if (isExploding == NO) {
            int rotateSign = (forwardVelocity > 0 ) ? -1 : 1;
            [self rotateForwardBy: rotateSign * [self calculateRotationFromMoveVector:moveForwardVector]];
            rotateSign = (strafeVelocity > 0) ? 1 : -1;
            [self rotateSidewardBy: rotateSign * [self calculateRotationFromMoveVector:moveSidewardVector]];
        }
    }
}

- (void) moveForwards
{
    self.deccelerateForward = NO;

    forwardVelocity += self.acceleration * invertedFrameRate;

}

- (void) moveBackwards
{
    self.deccelerateForward = NO;
    
    forwardVelocity -= self.acceleration * invertedFrameRate;

}

- (void) strafeRight
{
    self.deccelerateStrafe = NO;
    
    strafeVelocity += self.acceleration * invertedFrameRate;

}

- (void) strafeLeft
{
    self.deccelerateStrafe = NO;
    
    strafeVelocity -= self.acceleration * invertedFrameRate;

}

- (void) rotateRight
{
    if (isExploding == NO) {
        float angle = - self.angularVelocity * invertedFrameRate;
        [self rotateYby:angle];
    }
}

- (void) rotateLeft
{
    if (isExploding == NO) {
        float angle = self.angularVelocity * invertedFrameRate;
        [self rotateYby:angle];
    }
}

- (void) rotateBy:(float)angle
{
    if (isExploding == NO) {
        [self rotateYby:angle];
    }
}

- (void) jump 
{
    if (self.jumped == YES) {
        return;
    }
    yVelocity = jumpKineticEnergy = self.maxJumpVelocity;
    self.jumped = YES;
}

- (void) dive
{
    if (self.jumped == NO) {
        yVelocity = 0; 
        return;
    }
    yVelocity = -self.maxJumpVelocity;
}

- (void) hitEnemy
{
    [self dieWithExplosion:YES];
}

- (void) bounceVertical
{    
    if (setToDie == YES) {
        [self dieWithExplosion:YES];
        yVelocity = 0;
        return;
    }
    
    float lossMul = 1 - self.verticalCollisionEnergyLoss;
    yVelocity = ABS(yVelocity) * lossMul;
    jumpKineticEnergy *= lossMul;
    if (jumpKineticEnergy < self.maxJumpVelocity * lossMul ) {
        self.jumped = NO;
    }
}

- (void) bounceHorizontalX
{
    glm::vec3 right = glm::normalize(glm::cross(self.faceVector, glm::vec3(0.0f, 1.0f, 0.0f)));
    glm::vec3 move = right * strafeVelocity + self.faceVector * forwardVelocity;
    glm::vec3 inverted = glm::vec3(-move.x,0.0f,move.z);

    float lossMul = 1 - self.horizontalCollisionEnergyLoss;
    
    forwardVelocity = (glm::dot(inverted, self.faceVector) / glm::length(self.faceVector)) * lossMul ;
    strafeVelocity  = (glm::dot(inverted, right) / glm::length(right)) * lossMul;

}

- (void) bounceHorizontalZ
{
    glm::vec3 right = glm::normalize(glm::cross(self.faceVector, glm::vec3(0.0f, 1.0f, 0.0f)));
    glm::vec3 move = right * strafeVelocity + self.faceVector * forwardVelocity;
    glm::vec3 inverted = glm::vec3(move.x,0.0f,-move.z);
    
    float lossMul = 1 - self.horizontalCollisionEnergyLoss;
    
    forwardVelocity = (glm::dot(inverted, self.faceVector) / glm::length(self.faceVector)) * lossMul;
    strafeVelocity  = (glm::dot(inverted, right) / glm::length(right)) * lossMul;
}

- (void) portToCheckPoint
{
    forwardVelocity = strafeVelocity = yVelocity = 0.0f;
    glm::vec3 difference = self.checkPoint - self.position;
    [self move:difference];
}

- (float) calculateRotationFromMoveVector:(glm::vec3)vector
{
    float length = glm::length(vector);
    return length * 180 / (3.1415 * self.boundingBox.x);
}
- (void) changeFrameRate:(int)frameRate
{
    invertedFrameRate = (float) 1 / frameRate;
}

- (void) setYVelocity:(float)velocity
{
    yVelocity = velocity;
} 

- (void) setScore:(int)score
{
    _score = score;
    [JJHUD changeScore:self.score andLives:self.lives];
}

- (void) dieWithExplosion:(BOOL)triggered
{
    [JJHUD flashMessage:@"         YOU DIED!" for:3.0];
    self.lives--;
    if (self.lives == 0) {
        [JJHUD flashMessage:@"       GAME OVER!" for:2.0];
        [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:2.0];
    }
    setToDie = NO;
    
    if (triggered == YES) {
        [self triggerExplosion];
    } else {
        [self portToCheckPoint];
    }
}

- (void) triggerExplosion
{
    if (explosionState >= maxExplosionState or isExploding == YES) {
        return;
    }
    isExploding = YES;
}

- (void) explosionEnded
{
    explosionState = 0.0f;
    isExploding = NO;
    [self.camera unlock];
    [self portToCheckPoint];
}

- (void) setCheckPoint:(glm::vec3)checkPoint
{
    if (_checkPoint != checkPoint) {
        _checkPoint = checkPoint;
        [JJHUD flashMessage:@"NEW CHECKPOINT!" for:3];
    }
}
@end
