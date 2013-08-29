//
//  JJObjectManager.m
//  JumpingJack3D
//
//  Created by Maciej Żurad on 8/16/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJObjectManager.h"

@implementation JJObjectManager

NSMutableArray* enemies;
NSMutableArray* blocks;

//NSMutableArray* map;

JJMapGenerator* mapGenerator;
JJCharacter* characterRef;
JJStaticPlatform* baseFloor;
JJAssetManager* assetManagerRef;
JJCamera* cameraRef;

NSEnumerator* enumer;

glm::vec3 gridRatios;
glm::vec3 paddingRatios;

- (id) initWithRefs:(JJAssetManager*)aAssetManagerRef cameraRef:(JJCamera*)aCameraRef characterRef:(JJCharacter *)aCharacterRef
{
    self = [super init];
    if (self) {
        
        assetManagerRef = aAssetManagerRef;
        cameraRef = aCameraRef;
        characterRef = aCharacterRef;
        
        mapGenerator = [[JJMapGenerator alloc] init];
        
        enemies = [[NSMutableArray alloc] init];
        blocks = [[NSMutableArray alloc] init];
        baseFloor = [[JJStaticPlatform alloc] initWithShaderProgram: [assetManagerRef getShaderProgram:@"platform"]
                                                               Camera: cameraRef
                                                             Vertices: [assetManagerRef getVertices:@"floor"]
                                                              Normals: [assetManagerRef getNormals:@"floor"]
                                                          VertexCount: [assetManagerRef getVertexCount:@"floor"]
                                                            PositionX: 0.0f Y: 0.0f Z: 0.0f
                                                              Texture: [assetManagerRef getTexture: @"floor"]
                                                            TexCoords: [assetManagerRef getUvs:@"floor"]];
        [baseFloor scaleX:1000 Y:1 Z:1000];
        enumer = [blocks objectEnumerator];
        paddingRatios = glm::vec3(0.1f, 0.1f, 0.1f);
        gridRatios = glm::vec3(2.0f, 0.5f, 2.0f);
    }
    return self;
}

- (void) addObject:(id)aObject
{
    Class aClass = [aObject class];
    if ([aClass isSubclassOfClass:[JJRenderedObject class]]) {
        if ([aClass isSubclassOfClass:[JJDynamicEnemy class]] or [aClass isSubclassOfClass:[JJStaticEnemy class]]) {
            [enemies addObject:aObject];
        } else {
            [blocks addObject:aObject];
        }
    } else {
        NSLog(@"JJObjectManager: object is not subclass of JJRenderedObject");
    }
}

- (void) generateWorld
{
    int counter = 1;
    JJStaticPlatform* cube;
    for (NSArray* position in [mapGenerator getWholeMap]) {
        float x = [position[0] floatValue] * (gridRatios.x + paddingRatios.x) * 2;
        float y = [position[1] floatValue] * (gridRatios.y + paddingRatios.y) * 2 + gridRatios.y;
        float z = [position[2] floatValue] * (gridRatios.z + paddingRatios.z) * 2;
        cube = [[JJStaticPlatform alloc] initWithShaderProgram: [assetManagerRef getShaderProgram:@"platform"]
                                                        Camera: cameraRef
                                                      Vertices: [assetManagerRef getVertices:@"cube"]
                                                       Normals: [assetManagerRef getNormals:@"cube"]
                                                   VertexCount: [assetManagerRef getVertexCount:@"cube"]
                                                     PositionX: x Y: y Z: z
                                                       Texture: [assetManagerRef getTexture: @"metal"]
                                                     TexCoords: [assetManagerRef getUvs:@"cube"]];
        //[cube scaleY:.5f];
        [cube scaleX:gridRatios.x Y:gridRatios.y Z:gridRatios.z];
        // Debugging purposes
        //[cube setVisible:NO];
        [blocks addObject:cube];
        characterRef.position = glm::vec3(x,y+4,z);
        counter++;
    }
}


- (void) showNewBlock
{
    JJStaticPlatform* cube = [enumer nextObject];
    [cube setVisible:YES];
}

- (void) renderObjects
{
    [baseFloor render];
    [characterRef render];
    for (id object in enemies) {
        if ([object isVisible]) {
            [object render];
        }
    }
    for (id object in blocks) {
        if ([object isVisible]) {
            [object render];
        }
    }
}

- (void) applyAction
{
    for (id object in enemies) {
        if ([object isKindOfClass:[JJDynamicObject class]]) {
            [object moveThroughPath];
        }
    }
    for (id object in blocks) {
        if ([object isKindOfClass:[JJDynamicObject class]]) {
            [object moveThroughPath];
        }
    }
    [self calculatePhysics];
}

- (void) calculatePhysics
{
    [characterRef applyPhysics];
    if (characterRef.position.y  < baseFloor.position.y + characterRef.boundingBox.r) {
        float difference = ABS(characterRef.position.y - (baseFloor.position.y + characterRef.boundingBox.r));
        [characterRef moveY:difference];
        [characterRef bounce];        
    };
    for (JJRenderedObject* block in blocks) {
        if (characterRef.position.x < block.position.x + block.boundingBox.x and
            characterRef.position.x > block.position.x - block.boundingBox.x and
            characterRef.position.z < block.position.z + block.boundingBox.z and
            characterRef.position.z > block.position.z - block.boundingBox.z ) {
            // inside 2d horizontal plane
            // calculate min vector distance
            float minDistance = block.boundingBox.y + characterRef.boundingBox.r;
            float distance = glm::length(characterRef.position - block.position);
            float minUpwardsVector   = glm::length(glm::vec3(characterRef.position.x,
                                                             block.position.y + minDistance,
                                                             characterRef.position.z) - block.position);
            float minDownwardsVector = glm::length(glm::vec3(characterRef.position.x,
                                                             block.position.y - minDistance,
                                                             characterRef.position.z) - block.position);
            if (characterRef.position.y >= block.position.y and distance < minUpwardsVector ) {
                float difference = ABS(characterRef.position.y - (block.position.y + minDistance));
                [characterRef moveY:difference];
                [characterRef setYVelocity:0.0f];
                characterRef.jumped = NO;
                
            } else if (characterRef.position.y < block.position.y and distance < minDownwardsVector ){
                float difference = ABS(characterRef.position.y - (block.position.y - minDistance));
                [characterRef moveY:-difference];
                [characterRef setYVelocity:0.0f];
                characterRef.jumped = NO;
             }
        }
    }
}

@end
