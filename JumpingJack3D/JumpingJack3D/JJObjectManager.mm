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
JJFloor* baseFloor;
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
        baseFloor = [[JJFloor alloc] initWithShaderProgram: [assetManagerRef getShaderProgram:@"floor"]
                                                               Camera: cameraRef
                                                             Vertices: [assetManagerRef getVertices:@"circle"]
                                                              Normals: [assetManagerRef getNormals:@"circle"]
                                                          VertexCount: [assetManagerRef getVertexCount:@"circle"]
                                                            PositionX: 0.0f Y: 0.0f Z: 0.0f
                                                              Texture: [assetManagerRef getTexture: @"circle"]
                                                            TexCoords: [assetManagerRef getUvs:@"circle"]];
        [baseFloor scaleX:1000 Y:1 Z:1000];
        enumer = [blocks objectEnumerator];
        paddingRatios = glm::vec3(0.1f, 0.1f, 0.1f);
        gridRatios = glm::vec3(1.7f, 2.5f, 1.7f);
        
        JJDynamicEnemy* star = [[JJDynamicEnemy alloc] initWithShaderProgram:[assetManagerRef getShaderProgram:@"star"]
                                                                      Camera:cameraRef
                                                                    Vertices:[assetManagerRef getVertices:@"star"]
                                                                     Normals:[assetManagerRef getNormals:@"star"]
                                                                 VertexCount:[assetManagerRef getVertexCount:@"star"]
                                                                   PositionX:-10.0f Y:10.0f Z:-10.0f
                                                                  PathPointB:glm::vec4(-10.0f, 10.0f, -10.0f, 1.0f)
                                                                    StepSize:0.07f
                                                                     Texture:[assetManagerRef getTexture:@"star"]
                                                               TextureCoords:[assetManagerRef getUvs:@"star"] ];
        [star scaleX:3 Y:1 Z:3];
        [self addObject:star];
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
    float x,y,z,x2,y2,z2;
    JJStaticPlatform* cube;
    JJDynamicEnemy* enemy;
    NSArray* position, *position2;
    int num = 1;
    //for (NSArray* position in [mapGenerator getWholeMap]) {
    for (int i = 0; i<[[mapGenerator getWholeMap] count]; i++){
        position = [[mapGenerator getWholeMap] objectAtIndex:i];
    
        x = [position[0] floatValue] * (gridRatios.x + paddingRatios.x) * 2;
        y = [position[1] floatValue] * (gridRatios.y + paddingRatios.y) * 2 + gridRatios.y;
        z = [position[2] floatValue] * (gridRatios.z + paddingRatios.z) * 2;
        
        if (i % 14 == 0 && i!=0) {
            position2 = [[mapGenerator getWholeMap] objectAtIndex:i+5];
            x2 = [position2[0] floatValue] * (gridRatios.x + paddingRatios.x) * 2;
            y2 = [position2[1] floatValue] * (gridRatios.y + paddingRatios.y) * 2 + gridRatios.y + 5;
            z2 = [position2[2] floatValue] * (gridRatios.z + paddingRatios.z) * 2;
            
            enemy = [[JJDynamicEnemy alloc] initWithShaderProgram:[assetManagerRef getShaderProgram:@"star"]
                                                           Camera:cameraRef
                                                         Vertices:[assetManagerRef getVertices:@"star"]
                                                          Normals:[assetManagerRef getNormals:@"star"]
                                                      VertexCount:[assetManagerRef getVertexCount:@"star"]
                                                        PositionX: x Y:y + 5 Z:z
                                                       PathPointB:glm::vec4(x2, y2, z2, 1.0f)
                                                         StepSize:0.07f
                                                          Texture:[assetManagerRef getTexture:@"star"]
                                                    TextureCoords:[assetManagerRef getUvs:@"star"] ];
            [enemy scaleX:3 Y:1.0 Z:3];
            [enemies addObject:enemy];

        }
        cube = [[JJStaticPlatform alloc] initWithShaderProgram: [assetManagerRef getShaderProgram:@"platform"]
                                                        Camera: cameraRef
                                                      Vertices: [assetManagerRef getVertices:@"cube"]
                                                       Normals: [assetManagerRef getNormals:@"cube"]
                                                   VertexCount: [assetManagerRef getVertexCount:@"cube"]
                                                     PositionX: x Y: y Z: z
                                                       Texture: [assetManagerRef getTexture: @"metal"]
                                                      Texture2: [assetManagerRef getTexture: @"metal_spec"]
                                                     TexCoords: [assetManagerRef getUvs:@"cube"]
                                                        Number: num];
        //[cube scaleY:.5f];
        [cube scaleX:gridRatios.x Y:gridRatios.y Z:gridRatios.z];
        // Debugging purposes
        //[cube setVisible:NO];
        [blocks addObject:cube];
        num++;
    }
//    [characterRef setCheckPoint:glm::vec3(-10,0,-10)];
//    characterRef.position = glm::vec3(x,y+4,z);
    [characterRef setCheckPoint:glm::vec3(x,y+4,z)];
    characterRef.position = glm::vec3(-10,4,-10);

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
        [characterRef bounceVertical];
        [characterRef setScore:0];

    };
    for (JJRenderedObject* block in blocks) {
        // Vertical collisions
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
                [characterRef bounceVertical];
                [characterRef setScore:block.number];
                
                if (block.number % 10 == 0) {
                    glm::vec3 checkPoint = glm::vec3(block.position.x, block.position.y + minDistance + 2.0f, block.position.z);
                    [characterRef setCheckPoint: checkPoint];
                }
                
            } else if (characterRef.position.y < block.position.y and distance < minDownwardsVector ){
                float difference = ABS(characterRef.position.y - (block.position.y - minDistance));
                [characterRef moveY:-difference];
                [characterRef bounceVertical];
             }
        }
        // Horizontal YZ plane collisons
        if (characterRef.position.y < block.position.y + block.boundingBox.y and
            characterRef.position.y > block.position.y - block.boundingBox.y and
            characterRef.position.z < block.position.z + block.boundingBox.z and
            characterRef.position.z > block.position.z - block.boundingBox.z ) {
            // inside 2d vetical plane
            // calculate min vector distance
            float minDistance = block.boundingBox.x + characterRef.boundingBox.r;
            float distance = glm::length(characterRef.position - block.position);
            float minUpwardsVector   = glm::length(glm::vec3(block.position.x + minDistance,
                                                             characterRef.position.y,
                                                             characterRef.position.z) - block.position);
            float minDownwardsVector = glm::length(glm::vec3(block.position.x - minDistance,
                                                             characterRef.position.y,
                                                             characterRef.position.z) - block.position);
            if (characterRef.position.x >= block.position.x and distance < minUpwardsVector ) {
                float difference = ABS(characterRef.position.x - (block.position.x + minDistance));
                [characterRef moveX:difference];
                [characterRef bounceHorizontalX];
                
            } else if (characterRef.position.x < block.position.x and distance < minDownwardsVector ){
                float difference = ABS(characterRef.position.x - (block.position.x - minDistance));
                [characterRef moveX:-difference];
                [characterRef bounceHorizontalX];
            }
        }
        //Horizontal YX plane collisions
        if (characterRef.position.y < block.position.y + block.boundingBox.y and
            characterRef.position.y > block.position.y - block.boundingBox.y and
            characterRef.position.x < block.position.x + block.boundingBox.x and
            characterRef.position.x > block.position.x - block.boundingBox.x ) {
            // inside 2d vetical plane
            // calculate min vector distance
            float minDistance = block.boundingBox.z + characterRef.boundingBox.r;
            float distance = glm::length(characterRef.position - block.position);
            float minUpwardsVector   = glm::length(glm::vec3(characterRef.position.x,
                                                             characterRef.position.y,
                                                             block.position.z + minDistance) - block.position);
            float minDownwardsVector = glm::length(glm::vec3(characterRef.position.x,
                                                             characterRef.position.y,
                                                             block.position.z - minDistance) - block.position);
            if (characterRef.position.z >= block.position.z and distance < minUpwardsVector ) {
                float difference = ABS(characterRef.position.z - (block.position.z + minDistance));
                [characterRef moveZ:difference];
                [characterRef bounceHorizontalZ];
                
            } else if (characterRef.position.z < block.position.z and distance < minDownwardsVector ){
                float difference = ABS(characterRef.position.z - (block.position.z - minDistance));
                [characterRef moveZ:-difference];
                [characterRef bounceHorizontalZ];
            }
        }
    }
    for (JJRenderedObject* enemy in enemies) {
        glm::vec3 horizontalDistance = glm::vec3(characterRef.position.x - enemy.position.x,
                                                 0,
                                                 characterRef.position.z - enemy.position.z);
        
        if (glm::length(horizontalDistance) <= enemy.boundingBox.r) {
            //inside 2d horizontal circle
            float bounding = characterRef.boundingBox.r; //+ enemy.boundingBox.z;
            
            if (characterRef.position.y >= enemy.position.y and characterRef.position.y < enemy.position.y + bounding) {
                // above
                float difference = ABS(characterRef.position.y - (enemy.position.y + bounding));
                [characterRef moveY:difference];
                [characterRef bounceVertical];
                [characterRef dieWithExplosion:YES];
            }
            if (characterRef.position.y < enemy.position.y and characterRef.position.y  > enemy.position.y - bounding) {
                // below
                float difference = ABS(characterRef.position.y - (enemy.position.y + bounding));
                [characterRef moveY:-difference];
                [characterRef bounceVertical];
                [characterRef dieWithExplosion:YES];
            }
        }
    }
}

@end
