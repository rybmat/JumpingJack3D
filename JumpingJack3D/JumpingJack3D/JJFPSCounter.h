//
//  JJFPSCounter.h
//  JumpingJack3D
//
//  Created by Maciej Żurad on 9/9/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JJFPSCounter : NSObject {
    double  previousFrameTime;
    double* frameTimes;
    int     frameTimesCounter;
    int     frameTimesSize;
}   

- (id) init;
- (id) initWithFrameTimesSize:(int)aSize;

- (void) setNumberOfFrameTimes:(int)aSize;

- (void) fetchTime;

- (float) getCurrentFPS;

- (void) dealloc;

@end
