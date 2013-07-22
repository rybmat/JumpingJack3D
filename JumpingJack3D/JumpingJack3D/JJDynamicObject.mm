//
//  JJDynamicObject.m
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 11.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJDynamicObject.h"

@implementation JJDynamicObject



bool moveDirectionAtoB;
float dynamicObjectActualPosition[3];

@synthesize pathPointA;
@synthesize pathPointB;
@synthesize moveTimer;


- (id) initWithShaderProgram: (JJShaderProgram*) shProg Camera: (JJCamera*) cam Vertices: (float*) verts Normals: (float*) norms VertexCount: (int) vCount PositionX: (float) x Y: (float) y Z: (float) z PathPointB: (glm::vec4) pointB TimeIntervalBetweenMoves: (float) tInterval{
    
    self = [super initWithShaderProgram:shProg
                                 Camera:cam
                               Vertices:verts
                                Normals:norms
                            VertexCount:vCount
                              PositionX:x
                                      Y:y
                                      Z:z];
    
    [self setPathPointA:glm::vec4(x, y, z, 1)];
    [self setPathPointB:pointB];
    moveDirectionAtoB = TRUE;
    dynamicObjectActualPosition[0] = [self pathPointA].x;
    dynamicObjectActualPosition[1] = [self pathPointA].y;
    dynamicObjectActualPosition[2] = [self pathPointA].z;
    
    [self setMoveTimer:[NSTimer timerWithTimeInterval:tInterval
                                          target:self
                                        selector:@selector(moveThroughPath:)
                                        userInfo:nil
                                         repeats:YES]];
    [[NSRunLoop currentRunLoop] addTimer:moveTimer
                                 forMode:NSDefaultRunLoopMode];
    
    [[NSRunLoop currentRunLoop]
     addTimer:moveTimer
     forMode:NSEventTrackingRunLoopMode];
    
    
    return self;
}

-(void) moveThroughPath: (id) sender {
    
    glm::vec3 step = glm::vec3(0.0f,0.0f,0.0f);
    if(moveDirectionAtoB){
        
        if(dynamicObjectActualPosition[0] < [self pathPointB].x){
            step.x += DYNAMIC_OBJECT_STEP_SIZE;
            dynamicObjectActualPosition[0] += DYNAMIC_OBJECT_STEP_SIZE;
        }
        if(dynamicObjectActualPosition[0] > [self pathPointB].x){
            step.x -= DYNAMIC_OBJECT_STEP_SIZE;
            dynamicObjectActualPosition[0] -= DYNAMIC_OBJECT_STEP_SIZE;
        }
        
        if(dynamicObjectActualPosition[1] < [self pathPointB].y){
            step.y += DYNAMIC_OBJECT_STEP_SIZE;
            dynamicObjectActualPosition[1] += DYNAMIC_OBJECT_STEP_SIZE;
        }
        if(dynamicObjectActualPosition[1] > [self pathPointB].y){
            step.y -= DYNAMIC_OBJECT_STEP_SIZE;
            dynamicObjectActualPosition[1] -= DYNAMIC_OBJECT_STEP_SIZE;
        }
        
        if(dynamicObjectActualPosition[2] < [self pathPointB].z){
            step.z += DYNAMIC_OBJECT_STEP_SIZE;
            dynamicObjectActualPosition[2] += DYNAMIC_OBJECT_STEP_SIZE;
        }
        if(dynamicObjectActualPosition[2] > [self pathPointB].z){
            step.z -= DYNAMIC_OBJECT_STEP_SIZE;
            dynamicObjectActualPosition[2] -= DYNAMIC_OBJECT_STEP_SIZE;
        }
        
    }else{
        
        if(dynamicObjectActualPosition[0] < [self pathPointA].x){
            step.x += DYNAMIC_OBJECT_STEP_SIZE;
            dynamicObjectActualPosition[0] += DYNAMIC_OBJECT_STEP_SIZE;
        }
        if(dynamicObjectActualPosition[0] > [self pathPointA].x){
            step.x -= DYNAMIC_OBJECT_STEP_SIZE;
            dynamicObjectActualPosition[0] -= DYNAMIC_OBJECT_STEP_SIZE;
        }
        
        if(dynamicObjectActualPosition[1] < [self pathPointA].y){
            step.y += DYNAMIC_OBJECT_STEP_SIZE;
            dynamicObjectActualPosition[1] += DYNAMIC_OBJECT_STEP_SIZE;
        }
        if(dynamicObjectActualPosition[1] > [self pathPointA].y){
            step.y -= DYNAMIC_OBJECT_STEP_SIZE;
            dynamicObjectActualPosition[1] -= DYNAMIC_OBJECT_STEP_SIZE;
        }
        
        if(dynamicObjectActualPosition[2] < [self pathPointA].z){
            step.z += DYNAMIC_OBJECT_STEP_SIZE;
            dynamicObjectActualPosition[2] += DYNAMIC_OBJECT_STEP_SIZE;
        }
        if(dynamicObjectActualPosition[2] > [self pathPointA].z){
            step.z -= DYNAMIC_OBJECT_STEP_SIZE;
            dynamicObjectActualPosition[2] -= DYNAMIC_OBJECT_STEP_SIZE;
        }
        
    }
    
    //NSLog(@"x: %f y: %f z: %f",dynamicObjectActualPosition[0], dynamicObjectActualPosition[1], dynamicObjectActualPosition[2]);
    
    if((step.x == 0.0f) && (step.y == 0.0f) && (step.z == 0.0f)){
        moveDirectionAtoB = !moveDirectionAtoB;
    }else{
        [self setMatM:glm::translate([self matM], step)];
    }
    
}

@end
