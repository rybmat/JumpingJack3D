//
//  JJDynamicObject.h
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 11.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJRenderedObject.h"

@interface JJDynamicObject : JJRenderedObject

@property glm::vec4 pathPointA, pathPointB;
@property bool moveDirectionAtoB;
@property float* dynamicObjectActualPosition;
@property float stepSize;


- (id) initWithShaderProgram: (JJShaderProgram*) shProg Camera: (JJCamera*) cam Vertices: (float*) verts Normals: (float*) norms VertexCount: (int) vCount PositionX: (float) x Y: (float) y Z: (float) z PathPointB: (glm::vec4) pointB Step: (float) stp;
    
-(void) moveThroughPath;//: (id) sender;

@end
