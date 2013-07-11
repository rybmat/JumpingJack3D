//
//  JJStaticPlatform.h
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 11.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJStaticObject.h"

@interface JJStaticPlatform : JJStaticObject


- (id) initWithShaderProgram: (JJShaderProgram*) shProg Vertices: (float*) verts Normals: (float*) norms VertexCount: (int) vCount PositionX: (float) x Y: (float) y Z: (float) z;

@end
