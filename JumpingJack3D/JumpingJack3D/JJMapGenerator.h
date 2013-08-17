//
//  JJMapGenerator.h
//  JumpingJack3D
//
//  Created by Maciej Żurad on 8/16/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "glm/glm.hpp"

@interface JJMapGenerator : NSObject

- (id) init;
- (id) initWithStartingPosition:(glm::vec3)position mapStartingCapacity:(int)capacity ;

- (NSArray*) getVisibleMap;


@end
