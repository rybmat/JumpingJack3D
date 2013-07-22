//
//  JJLight.h
//  JumpingJack3D
//
//  Created by Maciej Żurad on 7/16/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "glm/glm.hpp"
#import "glm/gtc/matrix_transform.hpp"
#import "glm/gtc/type_ptr.hpp"

@interface JJLight : NSObject

+ (float*) getFirstLight;

+ (void) setFirstLightX: (float)x Y: (float)y Z: (float)z;

+ (float*) getSecondLight;

+ (void) setSecondLightX: (float)x Y: (float)y Z: (float)z;



@end
