//
//  JJLight.m
//  JumpingJack3D
//
//  Created by Maciej Żurad on 7/16/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJLight.h"

static glm::vec4 firstLight;
static glm::vec4 secondLight;

@implementation JJLight

+ (glm::vec4) getFirstLight{
    return firstLight;
}

+ (void) setFirstLight: (glm::vec4) fl{
    firstLight = fl;
}

+ (glm::vec4) getSecondLight{
    return secondLight;
}

+ (void) setSecondLight: (glm::vec4) sl{
    secondLight = sl;
}

@end
