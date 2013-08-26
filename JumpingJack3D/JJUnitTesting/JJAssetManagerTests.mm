//
//  JJAssetManagerTests.m
//  JumpingJack3D
//
//  Created by Maciej Żurad on 7/15/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//


#import "JJAssetManagerTests.h"
#import "JJAssetManagerPrivate.h"

@implementation JJAssetManagerTests

- (void)setUp
{
    [super setUp];
    NSLog(@"%@ setUp", self.name);
    assetManager = [[JJAssetManager alloc] init];
    STAssertNotNil(assetManager, @"Cannot create JJCamera instance");
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

// Proper tests

- (void)testShaderExtensions
{
    NSLog(@"%@ start", self.name);
    STAssertEqualObjects(assetManager.extensions[VERTEX_SHADER], @"vsh",
                         @"but instead was %@", assetManager.extensions[VERTEX_SHADER]);
    STAssertEqualObjects(assetManager.extensions[GEOMETRY_SHADER],@"gsh",
                         @"but instead was %@", assetManager.extensions[GEOMETRY_SHADER]);
    STAssertEqualObjects(assetManager.extensions[FRAGMENT_SHADER],@"fsh",
                         @"but instead was %@", assetManager.extensions[FRAGMENT_SHADER]);
    NSLog(@"%@ end", self.name);
}

- (void)testShaderDirsDictionaryCreation
{
    NSLog(@"%@ start", self.name);
    NSString* resPath = [[NSBundle mainBundle] resourcePath];
    
    NSDictionary* geoDict = [assetManager createShaderDirsDictionary:GEOMETRY_SHADER];
    NSDictionary* verDict = [assetManager createShaderDirsDictionary:VERTEX_SHADER];
    NSDictionary* fraDict = [assetManager createShaderDirsDictionary:FRAGMENT_SHADER];
    
    NSDictionary* assumedVerDict = @{@"platform": [resPath stringByAppendingPathComponent:@"platform.vsh"],
                                     @"ball": [resPath stringByAppendingPathComponent:@"ball.vsh"]
                                    };
    NSDictionary* assumedFraDict = @{@"platform": [resPath stringByAppendingPathComponent:@"platform.fsh"],
                                     @"ball": [resPath stringByAppendingPathComponent:@"ball.fsh"]
                                     };
    NSDictionary* assumedGeoDict = @{};
    
    //STAssertEqualObjects(verDict[@"ball"], assumedVerDict[@"ball"], @"but instead was @%", assumedVerDict);
    STAssertEqualObjects(fraDict[@"platform"], assumedFraDict[@"platform"], @"but instead was @%", assumedFraDict);
    STAssertEqualObjects(geoDict, assumedGeoDict, @"but instead was @%", assumedGeoDict);
    
    
    NSLog(@"%@ end", self.name);
}

- (void)testLoadShaders
{
    NSLog(@"%@ start", self.name);
    
    [assetManager loadShaders];
    //STAssertNotNil(assetManager.shaders[@"ball"], @"but intead is nil");
    STAssertNotNil(assetManager.shaders[@"platform"], @"but instead is nil");
    
    NSLog(@"%@ end", self.name);
}

- (void)testLoadTextures
{
    NSLog(@"%@ start", self.name);
    
    [assetManager loadTextures];
    //STAssertNotNil(assetManager.textures[@"ball"], @"but intead is nil");
    //STAssertNotNil(assetManager.textures[@"platform"], @"but instead is nil");
    
    NSLog(@"%@ end", self.name);
}

@end
