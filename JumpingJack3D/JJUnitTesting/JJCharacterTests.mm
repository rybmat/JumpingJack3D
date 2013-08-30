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
}

@end
