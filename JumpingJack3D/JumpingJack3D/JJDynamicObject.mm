//
//  JJDynamicObject.m
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 11.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJDynamicObject.h"

@implementation JJDynamicObject


@synthesize pathPointA;
@synthesize pathPointB;
@synthesize stepSize;


- (id) initWithShaderProgram: (JJShaderProgram*) shProg Camera: (JJCamera*) cam Vertices: (float*) verts Normals: (float*) norms VertexCount: (int) vCount PositionX: (float) x Y: (float) y Z: (float) z PathPointB: (glm::vec4) pointB Step: (float) stp{
    
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
    [self setStepSize:stp];
    
    _moveDirectionAtoB = TRUE;
    
    _dynamicObjectActualPosition = (float*)malloc(3*sizeof(float));
    _dynamicObjectActualPosition[0] = [self pathPointA].x;
    _dynamicObjectActualPosition[1] = [self pathPointA].y;
    _dynamicObjectActualPosition[2] = [self pathPointA].z;
    
    
    return self;
}

-(void) moveThroughPath{//: (id) sender {
    
    glm::vec3 step = glm::vec3(0.0f,0.0f,0.0f);
    if(_moveDirectionAtoB){
        
        if(_dynamicObjectActualPosition[0] < [self pathPointB].x){
            step.x += [self stepSize];
            _dynamicObjectActualPosition[0] += [self stepSize];
        }
        if(_dynamicObjectActualPosition[0] > [self pathPointB].x){
            step.x -= [self stepSize];
            _dynamicObjectActualPosition[0] -= [self stepSize];
        }
        
        if(_dynamicObjectActualPosition[1] < [self pathPointB].y){
            step.y += [self stepSize];
            _dynamicObjectActualPosition[1] += [self stepSize];
        }
        if(_dynamicObjectActualPosition[1] > [self pathPointB].y){
            step.y -= [self stepSize];
            _dynamicObjectActualPosition[1] -= [self stepSize];
        }
        
        if(_dynamicObjectActualPosition[2] < [self pathPointB].z){
            step.z += [self stepSize];
            _dynamicObjectActualPosition[2] += [self stepSize];
        }
        if(_dynamicObjectActualPosition[2] > [self pathPointB].z){
            step.z -= [self stepSize];
            _dynamicObjectActualPosition[2] -= [self stepSize];
        }
        
    }else{
        
        if(_dynamicObjectActualPosition[0] < [self pathPointA].x){
            step.x += [self stepSize];
            _dynamicObjectActualPosition[0] += [self stepSize];
        }
        if(_dynamicObjectActualPosition[0] > [self pathPointA].x){
            step.x -= [self stepSize];
            _dynamicObjectActualPosition[0] -= [self stepSize];
        }
        
        if(_dynamicObjectActualPosition[1] < [self pathPointA].y){
            step.y += [self stepSize];
            _dynamicObjectActualPosition[1] += [self stepSize];
        }
        if(_dynamicObjectActualPosition[1] > [self pathPointA].y){
            step.y -= [self stepSize];
            _dynamicObjectActualPosition[1] -= [self stepSize];
        }
        
        if(_dynamicObjectActualPosition[2] < [self pathPointA].z){
            step.z += [self stepSize];
            _dynamicObjectActualPosition[2] += [self stepSize];
        }
        if(_dynamicObjectActualPosition[2] > [self pathPointA].z){
            step.z -= [self stepSize];
            _dynamicObjectActualPosition[2] -= [self stepSize];
        }
        
    }
    
    //NSLog(@"x: %f y: %f z: %f",dynamicObjectActualPosition[0], dynamicObjectActualPosition[1], dynamicObjectActualPosition[2]);
    
    if((step.x == 0.0f) && (step.y == 0.0f) && (step.z == 0.0f)){
        _moveDirectionAtoB = !_moveDirectionAtoB;
    }else{
        //[self setMatM:glm::translate([self constructModelMatrix], step)];
        [self moveX: step.x Y:step.y Z:step.z];
    }
    
}

@end
