//
//  JJMapGeneratorTests.m
//  JumpingJack3D
//
//  Created by Maciej Żurad on 8/17/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJMapGeneratorTests.h"

@implementation JJMapGeneratorTests

- (void)setUp
{
    [super setUp];
    NSLog(@"%@ setUp", self.name);
    srand(time(0));
    gen = [[JJMapGenerator alloc] init];
    STAssertNotNil(gen, @"Cannot create JJMapGenerator instance");
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

@end
