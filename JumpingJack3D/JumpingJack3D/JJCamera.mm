//
//  JJCamera.m
//  JumpingJack3D
//
//  Created by Maciej Żurad on 7/11/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJCamera.h"
#import "JJCameraPrivate.h"

@implementation JJCamera

static const glm::vec3 worldUp = glm::vec3(0.0f, 1.0f, 0.0f);
static const float maxZoomIn = 1.0f;
static const float maxZoomOut = 50.0f;
static const float standardLatitude = 30.0f;

/* Basic initializer */
- (id) init
{
    return [self initWithParameters:1.0f farClipping:100.0f FoV:50.0f aspectRatio:1.0f cameraRadius:30.0f];
}

/* Specialized initializer */
- (id) initWithParameters:(float)nClipping farClipping:(float)fClipping FoV:(float)fov aspectRatio:(float)aRatio cameraRadius:(float)radius
{
    return [self initWithParameters:nClipping farClipping:fClipping FoV:fov aspectRatio:aRatio cameraRadius:radius latitude:0 longtitude:0];
}

/* Initializes Camera with all parameters*/
- (id) initWithParameters:(float)nClipping farClipping:(float)fClipping FoV:(float)fov aspectRatio:(float)aRatio cameraRadius:(float)radius latitude:(float)aLatitude longtitude:(float)aLongtitude
{
    self = [super init];
    if (self) {
        self.nearClipping = nClipping;
        self.farClipping = fClipping;
        self.fieldOfView = fov;
        self.aspectRatio = aRatio;
        
        self.radius = radius;
        self.latitude = aLatitude;
        self.longtitude = aLongtitude;
                
        self.maxForwardDistance = [self calculateForwardDistanceBasedOn:radius];
        
        self.characterPosition = glm::vec3(1.0f, 0.0f, 0.0f);
        
        self.cameraPosition = glm::vec3(0.0f, 1.0f, -20.0f);
        self.target = glm::vec3(1.0f, 0.0f, 0.0f);
        self.up = glm::vec3(0.0f, 1.0f, 0.0f);
        
        self.projectionMatrix = glm::perspective(self.fieldOfView, self.aspectRatio,
                                                 self.nearClipping, self.farClipping);
        self.viewMatrix = glm::lookAt(self.cameraPosition, self.target, self.up);
    }
    
    return self;
}

/* Rotates camera around character horizontally */
- (void) rotateHorizontal:(float)degrees
{
    self.longtitude += degrees;
}

/* Rotates camera around character vertically */
- (void) rotateVertical:(float)degrees
{
    self.latitude += degrees;
    if (self.latitude >= 90.0f) {
        self.latitude = 90.0f;
    } else if (self.latitude <= -90.0f) {
        self.latitude = -90.0f;
    }
}

/* Zooms in, checks constraints and recalculates forward vector distance */
- (void) zoomIn:(float)amount
{
    if ((self.radius -= amount) <= maxZoomIn) {
        self.radius = maxZoomIn;
    }
    self.maxForwardDistance = [self calculateForwardDistanceBasedOn:self.radius];
}

/* Zooms out, checks constraints and recalculates forward vector distance */
- (void) zoomOut:(float)amount
{
    if ((self.radius += amount) >= maxZoomOut) {
        self.radius = maxZoomOut;
    }
    self.maxForwardDistance = [self calculateForwardDistanceBasedOn:self.radius];

}

/* Refreshes camera view with current attributes and Character's position */
- (void) refresh
{
    [self setWithCharacterPosition:self.characterPosition];
}

/* Refreshes camera view and projection matrix with current attributes    */
-(void) refreshWithProjection
{
    self.projectionMatrix = glm::perspective(self.fieldOfView, self.aspectRatio,
                                             self.nearClipping, self.farClipping);
    [self refresh];
}

- (void) refreshWithoutMoving
{

}

/* Sets all camera attributes needed for View matrix and the builds it      */
/* Converts geographical representation of camera in 3D space to cartesian  */
/* Calculates lookAt and up vectors and builds View matrix                  */
/* Uses forward vector to aim camera not directly at character but above it */
- (void) setWithCharacterPosition:(glm::vec3)charPosition
{
    if (isLocked == YES) {
        [self followTarget:charPosition];
        return;
    }
    self.characterPosition = charPosition;
    self.cameraPosition = charPosition + [self convertGeoToCartesian:self.radius
                                                          longtitude:self.longtitude
                                                            latitude:self.latitude];
    
    glm::vec3 targetPosition = charPosition + [self calculateForwardVectorWithLongtitude:self.longtitude];
    
    self.target = glm::normalize(targetPosition - self.cameraPosition);
    glm::vec3 rightVector = glm::cross(self.target, worldUp);
    self.up = glm::cross(rightVector, self.target);
    
    self.viewMatrix = glm::lookAt(self.cameraPosition, targetPosition, self.up);
}

- (void) followTarget:(glm::vec3)targetPosition
{
    glm::vec3 targetVector = glm::normalize(targetPosition - self.cameraPosition);
    glm::vec3 geographical = [self convertCartesianToGeo:-targetVector];
    
    self.longtitude = geographical.y;
    self.latitude   = geographical.z;

    targetPosition = targetPosition + [self calculateForwardVectorWithLongtitude:self.longtitude];
    
    self.target = glm::normalize(targetPosition - self.cameraPosition);
    glm::vec3 rightVector = glm::cross(self.target, worldUp);
    self.up = glm::cross(rightVector, self.target);
    
    self.viewMatrix = glm::lookAt(self.cameraPosition, targetPosition, self.up);
    
}

/* Sets all camera attributes needed for View matrix and the builds it       */
/* Takes into consideration where character faces currently and places       */
/* camera exactly behind it, using subroutine                                */
- (void) setWithCharacterPosition:(glm::vec3)charPosition andCharactersFaceVector:(glm::vec3)fVector
{
    if (isLocked == YES) {
        [self followTarget:charPosition];
        return;
    }
    glm::vec3 geographical = [self convertCartesianToGeo:-fVector];
    //self.radius = geographical.x;
    self.longtitude = geographical.y;   
    self.latitude = standardLatitude;
    
    //NSLog(@"x: %f, y: %f, z: %f,",geographical.x, geographical.y, geographical.z);
    [self setWithCharacterPosition:charPosition];
}

- (void) resetWithCharacterFaceVector:(glm::vec3)fVector
{
    glm::vec3 geographical = [self convertCartesianToGeo:-fVector];
    self.radius = geographical.x;
    self.longtitude = geographical.y;   
    self.latitude = standardLatitude;
    [self refresh];
}

/* Calculates forward vector which always points in the direction of lookAt   */
/* vector projected on XZ plane and its lengths is always @maxForwardDistance */
- (glm::vec3) calculateForwardVectorWithLongtitude:(float)aLongitude
{
    float longtitudeAngles = glm::radians(aLongitude);
    
    return self.maxForwardDistance * glm::vec3(glm::cos(longtitudeAngles),
                                               0.0f,
                                               -glm::sin(longtitudeAngles));
}

/* Converts from Geographical Coordinate System to Cartesian Coordinate System */
/* Longtitude from -pi() to pi()                                               */
/* Latitude from -pi()/2 to pi()/2                                             */
- (glm::vec3) convertGeoToCartesian:(float)radius longtitude:(float)aLongitude latitude:(float)aLatitude
{
    if (radius <= 0.0f) {
        return glm::vec3(0.0f);
    }
    float longtitudeAngles = glm::radians(aLongitude);
    float latitudeAngles = glm::radians(aLatitude);
    
    return radius * glm::vec3(-glm::cos(latitudeAngles)*glm::cos(longtitudeAngles),
                              glm::sin(latitudeAngles),
                              glm::sin(longtitudeAngles)*glm::cos(latitudeAngles));
}
/* Converts from Cartesian Coordinate System to Geographical Coordinate System */
/* Returns vector (radius, longtitude, latitutde)                              */
- (glm::vec3) convertCartesianToGeo:(glm::vec3)vector
{
    float radius = glm::length(vector);
    float latitude = glm::degrees(glm::asin(vector.y/radius));
    float longtitude = -glm::degrees(glm::atan2(vector.z, vector.x)) + 180.0f;
    return glm::vec3(radius, longtitude, latitude);
}

/* Calculates forward vector distance based on radius of geographical coord system */
// Expected to have a better function in future - TODO
- (float) calculateForwardDistanceBasedOn:(float)radius
{
    return radius*0.4f;
}

- (void) lock
{
    isLocked = YES;
}

- (void) unlock
{
    isLocked = NO;
}
@end