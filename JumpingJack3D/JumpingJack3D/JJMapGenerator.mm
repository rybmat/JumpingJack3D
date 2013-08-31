//
//  JJMapGenerator.m
//  JumpingJack3D
//
//  Created by Maciej Żurad on 8/16/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#define RANDOM_MAP_SIZE 100

#define _case(something,X,Y,Z) case (something):\
                                sidewards = X;\
                                upwards = Y;\
                                forwards = Z;\
                              break;


#import "JJMapGenerator.h"
#import "JJMapGeneratorPrivate.h"

@implementation JJMapGenerator

enum platformDirections {FORWARD_GROUND, BACKWARD_GROUND, LEFT_GROUND, RIGHT_GROUND,
                         FORWARD_LEFT_GROUND, FORWARD_RIGHT_GROUND, BACKWARD_LEFT_GROUND, BACKWARD_RIGHT_GROUND,
                         FORWARD_UP, BACKWARD_UP, LEFT_UP, RIGHT_UP,
                         FORWARD_LEFT_UP, FORWARD_RIGHT_UP, BACKWARD_LEFT_UP, BACKWARD_RIGHT_UP, MID_UP};

// has to add up to 1.0f
float directionRates[17] = { 0.1f, 0.1f, 0.1f, 0.1f, 0.05f, 0.05f, 0.05f, 0.05f, 0.05f, 0.05f, 0.05f, 0.05f, 0.05f, 0.05f, 0.05f, 0.05f, 0.0f };
//float directionRates[17] = { 0.05f, 0.05f, 0.05f, 0.05f, 0.0f, 0.0f, 0.0f, 0.0f, 0.2f, 0.2f, 0.2f, 0.2f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f };

int randomMap[RANDOM_MAP_SIZE];

- (id) init
{
    return [self initWithStartingPosition:glm::vec3(0,0,0) mapStartingCapacity:40];
}

- (id) initWithStartingPosition:(glm::vec3)position mapStartingCapacity:(int)capacity
{
    self = [super init];
    if (self) {
        self.startingPosition = position;
        self.mapRefreshSize = capacity;
        self.previousPointsCapacity = 20;
        self.previousPointsMarker = 0;
        self.mapCurrentSize = 0;
        self.map            = [[NSMutableArray alloc] initWithCapacity:self.mapRefreshSize];
        self.previousPoints = [[NSMutableArray alloc] initWithCapacity:self.previousPointsCapacity];
        
        self.upwardsChance = 0.8;
        self.forwardsChance = 0.5;
        self.sidewardsChance = 0.5;
        
        [self fillRandomMap];
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
        
        [self.previousPoints replaceObjectAtIndex:self.previousPointsMarker withObject:newPoint];
        
        self.previousPointsMarker++;
        self.previousPointsMarker %= self.previousPointsCapacity;
    }
    self.mapCurrentSize = self.mapRefreshSize;
}

- (NSArray*) getVisibleMap
{
    NSMutableArray* tempArray = [[NSMutableArray alloc] init];
    for (int i=0; i<100; i++) {
        [tempArray addObject:self.map[i]];
    }
    return tempArray;
}

- (NSArray*) getWholeMap
{
    return self.map;
}

- (BOOL) checkPossiblePoint:(NSArray*)newPoint
{
    BOOL retVal = NO;
    
    for (NSArray* pos in self.previousPoints) {
        if ([self checkTwoPointsForSimilarity:pos second:newPoint] == YES) {
            continue;
        }
        if ([self isValidPoint:newPoint] == YES){
            return YES;
        }
    }
    return retVal;
}

- (BOOL) isValidPoint:(NSArray*)point
{
    int temp = self.previousPointsMarker-2;
    int compareIndex = (temp < 0) ? ( self.previousPointsCapacity + temp ) : temp;
    if ([self.previousPoints[compareIndex][0] intValue] == [point[0] intValue] and
        [self.previousPoints[compareIndex][2] intValue] == [point[2] intValue]) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL) checkTwoPointsForSimilarity:(NSArray*)firstArray second:(NSArray*)secondArray
{
    if ([firstArray isEqualToArray:secondArray]) {
        return YES;
    } else if ([firstArray[0] intValue] == [secondArray[0] intValue] and
               [firstArray[2] intValue] == [secondArray[2] intValue] and
               abs([firstArray[1] intValue] - [secondArray[1] intValue]) <= 1 )
    {
        return YES;
    } else {
        return NO;
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
    int upwards, forwards, sidewards;
    
    switch (randomMap[ rand()% RANDOM_MAP_SIZE ]) {
        _case(FORWARD_GROUND, 0, 0, -1)
        _case(BACKWARD_GROUND, 0, 0, 1)
        _case(LEFT_GROUND, -1, 0, 0)
        _case(RIGHT_GROUND, 1, 0, 0)
        _case(FORWARD_LEFT_GROUND, -1, 0, -1)
        _case(FORWARD_RIGHT_GROUND, 1, 0, -1)
        _case(BACKWARD_LEFT_GROUND, -1, 0, 1)
        _case(BACKWARD_RIGHT_GROUND, 1, 0, 1)
        _case(FORWARD_UP, 0, 1, -1)
        _case(BACKWARD_UP, 0, 1, 1)
        _case(LEFT_UP, -1, 1, 0)
        _case(RIGHT_UP, 1, 1, 0)
        _case(FORWARD_LEFT_UP, -1, 1, -1)
        _case(FORWARD_RIGHT_UP, 1, 1, -1)
        _case(BACKWARD_LEFT_UP, -1, 1, 1)
        _case(BACKWARD_RIGHT_UP, 1, 1, 1)
        _case(MID_UP, 0, 1, 0)
        default:
            upwards = 1;
            forwards = 0;
            sidewards = 0;
            NSLog(@"default path");
            break;
    }
    
    return @[[NSNumber numberWithInt:sidewards],
             [NSNumber numberWithInt:upwards],
             [NSNumber numberWithInt:forwards]];
}

- (void) fillRandomMap
{
    for (int i=0, j=0, k=0; i<RANDOM_MAP_SIZE; ++i) {
        randomMap[i] = j ;
        if (k + 1 >= RANDOM_MAP_SIZE * directionRates[j]) {
            k = 0;
            j++;
        } else {
            k++;
        }
    }
}

@end
