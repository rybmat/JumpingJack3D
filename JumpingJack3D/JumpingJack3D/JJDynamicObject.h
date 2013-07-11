//
//  JJDynamicObject.h
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 11.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJRenderedObject.h"

#define DYNAMIC_OBJECT_STEP_SIZE 0.1f

@interface JJDynamicObject : JJRenderedObject

@property glm::vec4 pathPointA, pathPointB;
@property NSTimer* moveTimer;


- (id) initWithShaderProgram: (JJShaderProgram*) shProg Vertices: (float*) verts Normals: (float*) norms VertexCount: (int) vCount PositionX: (float) x Y: (float) y Z: (float) z PathPointB: (glm::vec4) pointB TimeIntervalBetweenMoves: (float) tInterval;
    
-(void) moveThroughPath: (id) sender;

@end
