//
//  JJMapGenerator.m
//  JumpingJack3D
//
//  Created by Maciej Żurad on 8/16/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJMapGenerator.h"
#import "JJMapGeneratorPrivate.h"

@implementation JJMapGenerator



- (id) init
{
    return [self initWithStartingPosition:glm::vec3(0,0,0) mapStartingCapacity:100];
}

- (id) initWithStartingPosition:(glm::vec3)position mapStartingCapacity:(int)capacity
{
    self = [super init];
    if (self) {
        self.startingPosition = position;
        self.mapRefreshSize = capacity;
        self.previousPointsCapacity = 5;
        self.previousPointsMarker = 0;
        self.mapCurrentSize = 0;
        self.map            = [[NSMutableArray alloc] initWithCapacity:self.mapRefreshSize];
        self.previousPoints = [[NSMutableArray alloc] initWithCapacity:self.previousPointsCapacity];
        
        self.upwardsChance = 0.8;
        self.forwardsChance = 0.5;
        self.sidewardsChance = 0.5;
        
        [self initMap];
    }
    return self;
}

- (void) initMap
{
    for (int i=0; i<self.previousPointsCapacity; ++i) {
        self.previousPoints[i] = @[[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0]];
    }
    self.previousPoints[0] = @[[NSNumber numberWithInt:(int)self.startingPosition.x],
                               [NSNumber numberWithInt:(int)self.startingPosition.y],
                               [NSNumber numberWithInt:(int)self.startingPosition.z]];
    
    [self.map addObject:self.previousPoints[0]];
    self.previousPointsMarker++;
    NSArray* newPoint;
    for (int i = 1; i < self.mapRefreshSize; ++i) {
        do {
            newPoint = [self add:[self randomizeDirection] toSecond:self.map[i-1]];
            
        } while ([self checkPossiblePoint:newPoint] == NO);
        
        [self.map addObject:newPoint];
        
        self.previousPointsMarker++;
        self.previousPointsMarker %= self.previousPointsCapacity;
    }
    self.mapCurrentSize = self.mapRefreshSize;
}

- (NSArray*) getVisibleMap
{
    NSMutableArray* tempArray = [[NSMutableArray alloc] init];
    for (int i=0; i<20; i++) {
        [tempArray addObject:self.map[i]];
    }
    return tempArray;
}

- (BOOL) checkPossiblePoint:(NSArray*)newPoint
{
    BOOL retVal = NO;
    
    for (NSArray* pos in self.previousPoints) {
        if ([pos isEqualToArray:newPoint]) {
            continue;
        } else if ([self isValidPoint:newPoint] == YES){
            return YES;
        }
    }
    return retVal;
}

- (BOOL) isValidPoint:(NSArray*)point
{
    int temp = self.previousPointsMarker-2;
    int compareIndex = (temp < 0) ? ( self.previousPointsCapacity + temp ) : temp;
    if (self.previousPoints[compareIndex][0] == point[0] and self.previousPoints[compareIndex][2] == point[2]) {
        return NO;
    } else {
        return YES;
    }
}

- (NSArray*) add:(NSArray*)firstArray toSecond:(NSArray*)secondArray
{
    return @[[NSNumber numberWithInt:([firstArray[0] intValue]+[secondArray[0] intValue])],
             [NSNumber numberWithInt:([firstArray[1] intValue]+[secondArray[1] intValue])],
             [NSNumber numberWithInt:([firstArray[2] intValue]+[secondArray[2] intValue])]];
}

// Modify
- (NSArray*) randomizeDirection
{
    int upwards = ( (float)rand() / RAND_MAX <= self.upwardsChance ) ? 1 : 0;
    int forwards = ( (float)rand() / RAND_MAX <= self.forwardsChance ) ? 1 : 0 ;
    int sidewards = ( (float)rand() / RAND_MAX <= self.sidewardsChance ) ? 1 : 0 ;
    
    return @[[NSNumber numberWithInt:sidewards],
             [NSNumber numberWithInt:upwards],
             [NSNumber numberWithInt:forwards]];
}


@end
