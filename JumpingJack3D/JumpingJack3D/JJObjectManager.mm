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
                                                            PositionX: 0.0f Y: -1.0f Z: 0.0f
                                                              Texture: [assetManagerRef getTexture: @"metal"]
                                                            TexCoords: [assetManagerRef getUvs:@"floor"]];
        [baseFloor scaleX:100 Y:1 Z:100];
        enumer = [blocks objectEnumerator];
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
    JJStaticPlatform* cube;
    for (NSArray* position in [mapGenerator getWholeMap]) {
        float x = [position[0] floatValue];
        float y = [position[1] floatValue];
        float z = [position[2] floatValue];
        cube = [[JJStaticPlatform alloc] initWithShaderProgram: [assetManagerRef getShaderProgram:@"platform"]
                                                        Camera: cameraRef
                                                      Vertices: [assetManagerRef getVertices:@"cube"]
                                                       Normals: [assetManagerRef getNormals:@"cube"]
                                                   VertexCount: [assetManagerRef getVertexCount:@"cube"]
                                                     PositionX: x*2 Y: y*2 Z: z*2
                                                       Texture: [assetManagerRef getTexture: @"metal"]
                                                     TexCoords: [assetManagerRef getUvs:@"cube"]];
        [cube setVisible:NO];
        [blocks addObject:cube];
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
}


@end
