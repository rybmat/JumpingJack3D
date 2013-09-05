//
//  JJCamera.h
//  JumpingJack3D
//
//  Created by Maciej Żurad on 7/11/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "glm/glm.hpp"
#import "glm/gtc/matrix_transform.hpp"
#import "glm/gtc/type_ptr.hpp"
#import "glm/ext.hpp"


@interface JJCamera : NSObject {}

/*  Camera matrices  */
@property glm::mat4 viewMatrix;
@property glm::mat4 projectionMatrix;

/*  Projection matrix properties  */
@property float nearClipping;
@property float farClipping;
@property float fieldOfView;
@property float aspectRatio;

- (id) init;
- (id) initWithParameters:(float)nClipping farClipping:(float)fClipping FoV:(float)fov aspectRatio:(float)aRatio cameraRadius:(float)radius;

- (void) setWithCharacterPosition:(glm::vec3)charPosition andCharactersFaceVector:(glm::vec3)fVector;
- (void) setWithCharacterPosition:(glm::vec3)charPostion;

- (void) resetWithCharacterFaceVector:(glm::vec3)fVector;

- (void) refresh;
- (void) refreshWithProjection;

- (void) zoomIn:(float) amount;
- (void) zoomOut:(float) amount;

- (void) rotateHorizontal:(float) degrees;
- (void) rotateVertical:(float) degrees;

- (void) lock;
- (void) unlock;

@end
