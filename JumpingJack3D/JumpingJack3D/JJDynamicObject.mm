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
glm::vec4 dynamicObjectActualPosition;

@synthesize pathPointA;
@synthesize pathPointB;
@synthesize moveTimer;


- (id) initWithShaderProgram: (JJShaderProgram*) shProg Vertices: (float*) verts Normals: (float*) norms VertexCount: (int) vCount PositionX: (float) x Y: (float) y Z: (float) z PathPointB: (glm::vec4) pointB TimeIntervalBetweenMoves: (float) tInterval{
    
    self = [super initWithShaderProgram:shProg
                               Vertices:verts
                                Normals:norms
                            VertexCount:vCount
                              PositionX:x
                                      Y:y
                                      Z:z];
    
    [self setPathPointA:glm::vec4(x, y, z, 1)];
    [self setPathPointB:pointB];
    moveDirectionAtoB = TRUE;
    dynamicObjectActualPosition = [self pathPointA];
    
    [self setMoveTimer:[NSTimer timerWithTimeInterval:tInterval
                                          target:self
                                        selector:@selector(moveThroughPath:)
                                        userInfo:nil
                                         repeats:YES]];
    
    
    return self;
}

-(void) moveThroughPath: (id) sender {
    
    glm::vec3 step = glm::vec3(0.0f,0.0f,0.0f);
    if(moveDirectionAtoB){
        
        if(dynamicObjectActualPosition.x < [self pathPointB].x){
            step.x = DYNAMIC_OBJECT_STEP_SIZE;
        }
        if(dynamicObjectActualPosition.x > [self pathPointB].x){
            step.x = -DYNAMIC_OBJECT_STEP_SIZE;
        }
        
        if(dynamicObjectActualPosition.y < [self pathPointB].y){
            step.y = DYNAMIC_OBJECT_STEP_SIZE;
        }
        if(dynamicObjectActualPosition.y > [self pathPointB].y){
            step.y = -DYNAMIC_OBJECT_STEP_SIZE;
        }
        
        if(dynamicObjectActualPosition.z < [self pathPointB].z){
            step.z = DYNAMIC_OBJECT_STEP_SIZE;
        }
        if(dynamicObjectActualPosition.z > [self pathPointB].z){
            step.z = -DYNAMIC_OBJECT_STEP_SIZE;
        }
        
    }else{
        
        if(dynamicObjectActualPosition.x < [self pathPointA].x){
            step.x = DYNAMIC_OBJECT_STEP_SIZE;
        }
        if(dynamicObjectActualPosition.x > [self pathPointA].x){
            step.x = -DYNAMIC_OBJECT_STEP_SIZE;
        }
        
        if(dynamicObjectActualPosition.y < [self pathPointA].y){
            step.y = DYNAMIC_OBJECT_STEP_SIZE;
        }
        if(dynamicObjectActualPosition.y > [self pathPointA].y){
            step.y = -DYNAMIC_OBJECT_STEP_SIZE;
        }
        
        if(dynamicObjectActualPosition.z < [self pathPointA].z){
            step.z = DYNAMIC_OBJECT_STEP_SIZE;
        }
        if(dynamicObjectActualPosition.z > [self pathPointA].z){
            step.z = -DYNAMIC_OBJECT_STEP_SIZE;
        }
        
    }
    
    if((step.x == 0.0f) && (step.y == 0.0f) && (step.z == 0.0f)){
        moveDirectionAtoB = !moveDirectionAtoB;
    }else{
        [self setMatM:glm::translate([self matM], step)];
    }
    
}

@end
