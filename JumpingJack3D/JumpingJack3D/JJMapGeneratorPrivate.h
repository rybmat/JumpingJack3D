//
//  JJMapGenerator_Private.h
//  JumpingJack3D
//
//  Created by Maciej Żurad on 8/17/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJMapGenerator.h"

@interface JJMapGenerator () {}

@property NSMutableArray* map;
@property NSMutableArray* previousPoints;

@property float upwardsChance, forwardsChance,
                sidewardsChance, backwardsChance;

@property int previousPointsCapacity, previousPointsMarker;
@property int mapRefreshSize, mapCurrentSize;
@property glm::vec3 startingPosition;

- (void) initMap;

- (BOOL) checkPossiblePoint:(NSArray*)change;
- (BOOL) isValidPoint:(NSArray*)point;
- (NSArray*) randomizeDirection;

@end
