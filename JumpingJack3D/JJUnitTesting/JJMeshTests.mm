//
//  JJMeshTests.m
//  JumpingJack3D
//
//  Created by Maciej Żurad on 7/16/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJMeshTests.h"

@implementation JJMeshTests

- (void)setUp
{
    [super setUp];
    NSLog(@"%@ setUp", self.name);
    mesh = [[JJMesh alloc] init];
    STAssertNotNil(mesh, @"Cannot create JJMesh instance");
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

- (void)testSetCounts
{
    NSLog(@"%@ start", self.name);
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"cube" ofType:@"obj"];
    NSString* data = [NSString stringWithContentsOfFile:filePath
                                               encoding:NSUTF8StringEncoding
                                                  error:nil];
    
    NSArray* lines = [data componentsSeparatedByString:@"\n"];
    [mesh setCountsWithLines:lines];
    
    STAssertTrue(mesh.uvCount      == 14, @"but instead was %d", mesh.uvCount);
    STAssertTrue(mesh.normalsCount == 8,  @"but instead was %d", mesh.normalsCount);
    STAssertTrue(mesh.vertexCount  == 8,  @"but instead was %d", mesh.vertexCount);
    STAssertTrue(mesh.faceCount    == 12, @"but instead was %d", mesh.faceCount);
    
    NSLog(@"%@ end", self.name);
}

- (void)testLoadMesh
{
    NSLog(@"%@ start", self.name);

    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"cube" ofType:@"obj"];
    [mesh loadModel:filePath];
    NSLog(@"%@ end", self.name);
}

@end
