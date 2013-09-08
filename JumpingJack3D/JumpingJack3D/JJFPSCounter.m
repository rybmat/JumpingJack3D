//
//  JJFPSCounter.m
//  JumpingJack3D
//
//  Created by Maciej Żurad on 9/9/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJFPSCounter.h"

@implementation JJFPSCounter


- (id) init {
    return [self initWithFrameTimesSize:20];
}

- (id) initWithFrameTimesSize:(int)aSize {
    if (self = [super init]) {
        previousFrameTime = 0.0;
        frameTimesSize = aSize;
        frameTimesCounter = 0;
        frameTimes = (double*)malloc(sizeof(double) * aSize);
        for (int i=0; i<frameTimesSize; ++i) {
            frameTimes[i] = 0.0;
        }
    }
    return self;
}

- (void) setNumberOfFrameTimes:(int)aSize {
    int previousSize = frameTimesSize;
    frameTimesSize = aSize;
    frameTimes = (double*)realloc(frameTimes, aSize * sizeof(double));
    
    double average = 0.0;
    
    for (int i=0; i<previousSize; ++i) {
        average += frameTimes[i];
    }
    average /= previousSize;
    for (int i=previousSize; i<frameTimesSize; ++i) {
        frameTimes[i] = average;
    }
}

- (void) fetchTime {
    double frameTime  = CACurrentMediaTime() - previousFrameTime;
    previousFrameTime = CACurrentMediaTime();
    
    frameTimes[frameTimesCounter] = frameTime;
    frameTimesCounter++;
    frameTimesCounter %= frameTimesSize;
}

- (float) getCurrentFPS {
    double frameTime = 0.0;
    
    for (int i=0; i<frameTimesSize; ++i) {
        frameTime += frameTimes[i];
    }
    frameTime /= frameTimesSize;
    return (float) 1/frameTime;
}

- (void) dealloc {
    free(frameTimes);
}


@end
