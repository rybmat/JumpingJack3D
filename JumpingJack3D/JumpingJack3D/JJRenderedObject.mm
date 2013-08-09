//
//  JJRenderedObject.m
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 10.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJRenderedObject.h"

@implementation JJRenderedObject

@synthesize matM;
@synthesize shaderProgram;
@synthesize vertices;
@synthesize normals;
@synthesize vertexCount;
@synthesize camera;

- (id) initWithShaderProgram: (JJShaderProgram*) shProg Camera: (JJCamera*) cam Vertices: (float*) verts Normals: (float*) norms VertexCount: (int) vCount PositionX: (float) x Y: (float) y Z: (float) z{
    
    self = [super init];
    if(self){
        [self setShaderProgram:shProg];
        [self setCamera: cam];
        [self setVertices:verts];
        [self setNormals:norms];
        [self setVertexCount:vCount];
        [self setMatM:glm::translate(glm::mat4(1.0f), glm::vec3(x,y,z))];
    }
    return self;
}

- (void) moveX: (float) x Y: (float) y Z: (float) z{
    [self setMatM:glm::translate([self matM], glm::vec3(x, y, z))];
}

- (void) moveX: (float) direction{
    [self setMatM:glm::translate([self matM], glm::vec3(direction, 0.0f, 0.0f))];
    
}

- (void) moveY: (float) direction{
    [self setMatM:glm::translate([self matM], glm::vec3(0.0f, direction, 0.0f))];
}

- (void) moveZ: (float) direction{
    [self setMatM:glm::translate([self matM], glm::vec3(0.0f, 0.0f, direction))];
}



- (void) rotateX: (float) x Y: (float) y Z: (float) z ByAngle: (float) angle{
    [self setMatM:glm::rotate([self matM], angle, glm::vec3(x, y, z))];
}

- (void) rotateX: (float) direction byAngle: (float) angle{
    [self setMatM:glm::rotate([self matM], angle, glm::vec3(direction, 0.0f, 0.0f))];
}

- (void) rotateY: (float) direction byAngle: (float) angle{
    [self setMatM:glm::rotate([self matM], angle, glm::vec3(0.0f, direction, 0.0f))];
}

- (void) rotateZ: (float) direction byAngle: (float) angle{
    [self setMatM:glm::rotate([self matM], angle, glm::vec3(0.0f, 0.0f, direction))];

}



- (void) scaleX: (float) x Y: (float) y Z: (float) z{
    [self setMatM:glm::scale([self matM], glm::vec3(x, y, z))];
}

- (void) scaleX: (float) scale{
    [self setMatM:glm::scale([self matM], glm::vec3(scale, 1.0f, 1.0f))];
}

- (void) scaleY: (float) scale{
    [self setMatM:glm::scale([self matM], glm::vec3(1.0f, scale, 1.0f))];
}

- (void) scaleZ: (float) scale{
        [self setMatM:glm::scale([self matM], glm::vec3(1.0f, 1.0f, scale))];
}


-(glm::vec4) getModelPosition{
    glm::vec4 position;
    
    position.x = [self matM][3][0];
    position.y = [self matM][3][1];
    position.z = [self matM][3][2];
    position.w = 1;
    
    return position;
}
@end
