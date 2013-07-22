//
//  JJLight.m
//  JumpingJack3D
//
//  Created by Maciej Żurad on 7/16/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJLight.h"

static float firstLight[4];
static float secondLight[4];

@implementation JJLight

+ (float*) getFirstLight{
    return firstLight;
}

+ (void) setFirstLightX: (float)x Y: (float)y Z: (float)z{
    firstLight[0] = x;
    firstLight[1] = y;
    firstLight[2] = z;
    firstLight[3] = 1.0f;
}

+ (float*) getSecondLight{
    return secondLight;
}

+ (void) setSecondLightX: (float)x Y: (float)y Z: (float)z{
    secondLight[0] = x;
    secondLight[1] = y;
    secondLight[2] = z;
    secondLight[3] = 1.0f;
}

@end
