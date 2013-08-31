//
//  JJRenderedObject.m
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 10.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJRenderedObject.h"

#import "glm/glm.hpp"
#import "glm/ext.hpp"
#import "glm/gtc/matrix_transform.hpp"
#import "glm/gtc/type_ptr.hpp"
#import "glm/gtc/quaternion.hpp"
#import "glm/gtx/quaternion.hpp"

@implementation JJRenderedObject

@synthesize shaderProgram;
@synthesize vertices;
@synthesize normals;
@synthesize vertexCount;
@synthesize camera;

@synthesize visible;
@synthesize position;
@synthesize rotation;
@synthesize scale;
@synthesize faceVector;
@synthesize boundingBox;

- (id) initWithShaderProgram: (JJShaderProgram*) shProg Camera: (JJCamera*) cam Vertices: (float*) verts Normals: (float*) norms VertexCount: (int) vCount PositionX: (float) x Y: (float) y Z: (float) z{
    
    self = [super init];
    if(self){
        [self setVisible:YES];
        [self setShaderProgram:shProg];
        [self setCamera: cam];
        [self setVertices:verts];
        [self setNormals:norms];
        [self setVertexCount:vCount];
        [self setPosition:glm::vec3(x,y,z)];
        [self setScale:glm::vec3(1.0f, 1.0f, 1.0f)];
        [self setFaceVector:glm::vec3(1.0f, 0.0f, 0.0f)];
        [self setRotation:glm::angleAxis(0.0f, glm::vec3(0.0f, 1.0f, 0.0f))];
        [self setBoundingBox:glm::vec3(1.0f, 1.0f, 1.0f)];
    }
    return self;
}

- (void) move: (glm::vec3)vector
{
    self.position += vector;
}

- (void) moveX: (float) x Y: (float) y Z: (float) z{
    self.position += glm::vec3(x,y,z);
}

- (void) moveX: (float) direction{
    self.position += glm::vec3(direction, 0.0f, 0.0f);    
}

- (void) moveY: (float) direction{
    self.position += glm::vec3(0.0f, direction, 0.0f);
}

- (void) moveZ: (float) direction{
    self.position += glm::vec3(0.0f, 0.0f, direction);
}

- (void) rotateYby: (float) angle{
    self.rotation = glm::angleAxis(angle, glm::vec3(0.0f, 1.0f, 0.0f)) * self.rotation;
    self.faceVector = glm::rotateY(self.faceVector, angle);
}

- (void) rotateForwardBy: (float) angle{
    self.rotation = glm::angleAxis(angle, [self getRightVector]) * self.rotation;
}

- (void) rotateSidewardBy: (float) angle{
    self.rotation = glm::angleAxis(angle, [self getFaceVector]) * self.rotation;
}

- (void) scaleX: (float) x Y: (float) y Z: (float) z{
    self.scale = glm::vec3(x * self.scale.x,
                           y * self.scale.y,
                           z * self.scale.z);
    self.boundingBox = glm::vec3(x * self.boundingBox.x,
                                 y * self.boundingBox.y,
                                 z * self.boundingBox.z);
}

- (void) scaleX: (float) amount{
    self.scale = glm::vec3(self.scale.x * amount,
                           self.scale.y,
                           self.scale.z);
    self.boundingBox = glm::vec3(self.boundingBox.x * amount,
                                 self.boundingBox.y,
                                 self.boundingBox.z);
}

- (void) scaleY: (float) amount{
    self.scale = glm::vec3(self.scale.x,
                           self.scale.y * amount,
                           self.scale.z);
    self.boundingBox = glm::vec3(self.boundingBox.x,
                                 self.boundingBox.y * amount,
                                 self.boundingBox.z);
}

- (void) scaleZ: (float) amount{
    self.scale = glm::vec3(self.scale.x,
                           self.scale.y,
                           self.scale.z * amount);
    self.boundingBox = glm::vec3(self.boundingBox.x,
                                 self.boundingBox.y,
                                 self.boundingBox.z * amount);
}

- (BOOL) isVisible
{
    return self.visible;
}

- (glm::mat4) constructModelMatrix
{
    glm::mat4 rotationMatrix = glm::toMat4(self.rotation);
    glm::mat4 translationMatrix = glm::translate(glm::mat4(1.0f), self.position);
    glm::mat4 scaleMatrix       = glm::scale(glm::mat4(1.0f), self.scale);
    return translationMatrix * rotationMatrix * scaleMatrix;
}

- (glm::vec3) getFaceVector
{
    return self.faceVector;
}

- (glm::vec3) getRightVector
{
    return glm::cross([self getFaceVector], glm::vec3(0.0f, 1.0f, 0.0f));
}

@end
