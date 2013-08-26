//
//  JJCharacterTests.m
//  JumpingJack3D
//
//  Created by Maciej Żurad on 8/23/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJCharacterTests.h"

@implementation JJCharacterTests

- (void)setUp
{
    [super setUp];
    NSLog(@"%@ setUp", self.name);
    chr = [[JJCharacter alloc] init];
    STAssertNotNil(chr, @"Cannot create JJCharacter instance");
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

- (void)testRotateByAngle
{
    chr.faceVector = glm::vec3(1.0f,0.0f,0.0f);
    [chr rotateBy:90.0f];
    glm::vec3 assumed = glm::vec3(0.0f,0.0f,-1.0f);
    STAssertTrue(chr.faceVector == assumed, @"but instead was %f %f %f", chr.faceVector.x, chr.faceVector.y, chr.faceVector.z);
}

@end
