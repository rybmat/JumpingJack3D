//
//  JJMapGenerator.m
//  JumpingJack3D
//
//  Created by Maciej Żurad on 8/16/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#define RANDOM_MAP_SIZE   10000
#define MAX_PATTERN_SIZE      8
#define PROPABILITY_MAP_SIZE 17

#define _case(something,X,Y,Z) case (something):\
                                sidewards = X;\
                                upwards = Y;\
                                forwards = Z;\
                              break;

#define _morph_rule(dir, amount) case (dir): \
                            switchPattern[dir][dir ## _GROUND] *= amount; \
                            switchPattern[dir][dir ## _UP] = 1 - switchPattern[dir][dir ## _GROUND]; \
                        break;

#import "JJMapGenerator.h"
#import "JJMapGeneratorPrivate.h"

@implementation JJMapGenerator

enum platformDirections {FORWARD_GROUND, BACKWARD_GROUND, LEFT_GROUND, RIGHT_GROUND,
                         FORWARD_LEFT_GROUND, FORWARD_RIGHT_GROUND, BACKWARD_LEFT_GROUND, BACKWARD_RIGHT_GROUND,
                         FORWARD_UP, BACKWARD_UP, LEFT_UP, RIGHT_UP,
                         FORWARD_LEFT_UP, FORWARD_RIGHT_UP, BACKWARD_LEFT_UP, BACKWARD_RIGHT_UP, MID_UP};

enum patternSignature { FORWARD_LEFT, LEFT, BACKWARD_LEFT, BACKWARD, BACKWARD_RIGHT, RIGHT, FORWARD_RIGHT, FORWARD };

// has to add up to 1.0f
float directionRates[PROPABILITY_MAP_SIZE] = { 0.1f, 0.1f, 0.1f, 0.1f, 0.05f, 0.05f, 0.05f, 0.05f, 0.05f, 0.05f, 0.05f, 0.05f, 0.05f, 0.05f, 0.05f, 0.05f, 0.0f };
//float directionRates[PROPABILITY_MAP_SIZE] = { 0.05f, 0.05f, 0.05f, 0.05f, 0.0f, 0.0f, 0.0f, 0.0f, 0.2f, 0.2f, 0.2f, 0.2f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f };

    
// DESCRIPTION                                        FG    BG    LG    RG    FLG    FRG    BLG    BRG    FU     BU     LU     RU     FLU    FRU    BLU    BRU    MU
float leftForwardPattern[PROPABILITY_MAP_SIZE]   = { 0.1f, 0.0f, 0.1f, 0.0f, 0.15f, 0.0f,  0.0f,  0.0f,  0.25f, 0.0f,  0.25f, 0.0f,  0.15f, 0.0f,  0.0f,  0.0f,  0.0f };
float rightForwardPattern[PROPABILITY_MAP_SIZE]  = { 0.1f, 0.0f, 0.0f, 0.1f, 0.0f,  0.15f, 0.0f,  0.0f,  0.25f, 0.0f,  0.0f,  0.25f, 0.0f,  0.15f, 0.0f,  0.0f,  0.0f };
float leftBackwardPattern[PROPABILITY_MAP_SIZE]  = { 0.0f, 0.1f, 0.1f, 0.0f, 0.0f,  0.0f,  0.15f, 0.0f,  0.0f,  0.25f, 0.25f, 0.0f,  0.0f,  0.0f,  0.15f, 0.0f,  0.0f };
float rightBackwardPattern[PROPABILITY_MAP_SIZE] = { 0.0f, 0.1f, 0.0f, 0.1f, 0.0f,  0.0f,  0.0f,  0.15f, 0.0f,  0.25f, 0.0f,  0.25f, 0.0f,  0.0f,  0.0f,  0.15f, 0.0f };

float leftPattern[PROPABILITY_MAP_SIZE]          = { 0.0f, 0.0f, 0.5f, 0.0f, 0.0f,  0.0f, 0.0f,   0.0f,  0.0f,  0.0f,  0.5f,  0.0f,  0.0f,  0.0f,  0.0f,  0.0f,  0.0f };
float rightPattern[PROPABILITY_MAP_SIZE]         = { 0.0f, 0.0f, 0.0f, 0.5f, 0.0f,  0.0f, 0.0f,   0.0f,  0.0f,  0.0f,  0.0f,  0.5f,  0.0f,  0.0f,  0.0f,  0.0f,  0.0f };
float forwardPattern[PROPABILITY_MAP_SIZE]       = { 0.5f, 0.0f, 0.0f, 0.0f, 0.0f,  0.0f, 0.0f,   0.0f,  0.5f,  0.0f,  0.0f,  0.0f,  0.0f,  0.0f,  0.0f,  0.0f,  0.0f };
float backwardPattern[PROPABILITY_MAP_SIZE]      = { 0.0f, 0.5f, 0.0f, 0.0f, 0.0f,  0.0f, 0.0f,   0.0f,  0.0f,  0.5f,  0.0f,  0.0f,  0.0f,  0.0f,  0.0f,  0.0f,  0.0f };

float* switchPattern[MAX_PATTERN_SIZE] = {&leftForwardPattern[0],   &leftPattern[0],  &leftBackwardPattern[0], &backwardPattern[0],
                                          &rightBackwardPattern[0], &rightPattern[0], &rightForwardPattern[0], &forwardPattern[0]};

//float directionRates[PROPABILITY_MAP_SIZE] = { 0.25f, 0.0f, 0.15f, 0.0f, 0.15f, 0.0f, 0.0f, 0.0f, 0.15f, 0.0f, 0.15f, 0.0f, 0.15f, 0.0f, 0.0f, 0.0f, 0.0f };

float* patternHandler = NULL;

int changeRate          = 8;
int maxChangeRate       = 10;
int minChangeRate       = 1;
int changeDirection     = 1;
int directionChangerate = 3;

int currentPattern = 0;

int randomMap[RANDOM_MAP_SIZE];

- (id) init
{
    return [self initWithStartingPosition:glm::vec3(0,0,0) mapStartingCapacity:50];
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
        
        [self morphMapGeneration:0];
        [self initMap];
        NSLog(@"floor %f", ceil(2.2f));
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
        

        [self morphMapGeneration:i];

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
            NSLog(@"MapGenerator: Choosing default path, there must have been some mistake");
            break;
    }
    
    return @[[NSNumber numberWithInt:sidewards],
             [NSNumber numberWithInt:upwards],
             [NSNumber numberWithInt:forwards]];
}

- (void) morphMapGeneration:(int)pointNumber
{
    if (pointNumber % changeRate == 0) {
        changeRate += changeDirection;
        if (changeRate >= maxChangeRate) {
            changeRate = maxChangeRate;
            changeDirection *= -1;
        }
        if (changeRate <= minChangeRate) {
            changeRate = minChangeRate;
            changeDirection *= -1;
        }
        
        currentPattern += changeDirection;
        
        if (currentPattern >= MAX_PATTERN_SIZE) {
            currentPattern = 0;
        } else if (currentPattern < 0) {
            currentPattern = MAX_PATTERN_SIZE - 1;
        }
        patternHandler = switchPattern[currentPattern];
        [self prepareRandomMap];
    }
}

- (void) prepareRandomMap
{
    float constraintCheck = 0.0f;
    for (int i=0; i<PROPABILITY_MAP_SIZE; ++i) {
        constraintCheck += patternHandler[i];
    }
    
    if ( ABS(constraintCheck - 1.0f) > 0.0001 ) {
        NSLog(@"MapGenerator: Constraint check violated, direction propabilites do not add up to 1.0 instead they sum to %f", constraintCheck);
        [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
    }
    
    for (int i=0, j=0, k=0; i<RANDOM_MAP_SIZE; ++i) {
        randomMap[i] = j ;
        if (k + 1 >= RANDOM_MAP_SIZE * patternHandler[j]) {
            k = 0;
            j++;
        } else {
            k++;
        }
    }
}

- (void) morphPattern:(int)type
{
    switch (type) {
            _morph_rule(FORWARD, 1.5)
            _morph_rule(BACKWARD, 1.5)
            _morph_rule(LEFT, 1.5)
            _morph_rule(RIGHT, 1.5)
    }
}

@end
