//
//  JJCharacter.h
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 11.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJRenderedObject.h"
#import "JJHUD.h"

@interface JJCharacter : JJRenderedObject

@property float* texCoords0;
@property GLuint vao;
@property GLuint bufVertices;
@property GLuint bufNormals;
@property GLuint tex0;
@property GLuint bufTexCoords;
@property GLuint velMultiplier;

@property (readonly) glm::vec3 checkPoint;

@property float maxForwardVelocity;
@property float maxJumpVelocity;
@property float maxStrafeVelocity;
@property float angularVelocity;

@property float acceleration;
@property float decceleration; //energy loss from friction
@property float gravity;

@property (readonly) int score;
@property int lives;

@property float horizontalCollisionEnergyLoss;
@property float verticalCollisionEnergyLoss;

@property int deathSpeed;

@property BOOL deccelerateForward;
@property BOOL deccelerateStrafe;
@property BOOL jumped;

- (id) initWithShaderProgram: (JJShaderProgram*) shProg Camera: (JJCamera*) cam Vertices: (float*) verts Normals: (float*) norms VertexCount: (int) vCount PositionX: (float) x Y: (float) y Z: (float) z Texture: (GLuint) tex TexCoords: (float*) tCoords frameRate:(int)rate;

- (void) dealloc;

- (void) render;

- (void) applyPhysics;

- (void) moveForwards;
- (void) moveBackwards;
- (void) strafeLeft;
- (void) strafeRight;
- (void) rotateLeft;
- (void) rotateRight;
- (void) rotateBy:(float)angle;
- (void) jump;
- (void) dive;

- (void) dieWithExplosion:(BOOL)triggered;

- (void) hitEnemy;

- (void) triggerExplosion;

- (void) bounceVertical;
- (void) bounceHorizontalX;
- (void) bounceHorizontalZ;

- (void) portToCheckPoint;
- (void) setCheckPoint:(glm::vec3)checkPoint;

- (void) changeFrameRate:(int)frameRate;

- (void) setYVelocity:(float)velocity;

- (void) setScore:(int)score;

@end
