//
//  JJCamera_Tests.h
//  JumpingJack3D
//
//  Created by Maciej Żurad on 7/14/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJCamera.h"

@interface JJCamera () {
    BOOL isLocked;
}

// Camera's View matrix variables
@property glm::vec3 up;
@property glm::vec3 cameraPosition;
@property glm::vec3 target;

// Camera's geographical coordinates
@property float longtitude;
@property float latitude;
@property float radius;

// Camera's realistic variables
@property float maxForwardDistance;

@property glm::vec3 characterPosition;

- (glm::vec3) convertGeoToCartesian:(float)radius longtitude:(float)aLongitude latitude:(float)aLatitude;
- (glm::vec3) convertCartesianToGeo:(glm::vec3)vector;
- (glm::vec3) calculateForwardVectorWithLongtitude:(float)aLongitude;

@end
