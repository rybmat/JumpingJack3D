//
//  JJCameraTests.mm
//  JJCameraTests
//
//  Created by Maciej Żurad on 7/14/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "JJCameraTests.h"
#import "JJCamera.h"
#import "JJCameraPrivate.h"

@implementation JJCameraTests

- (NSString*)vec3toNSString:(glm::vec3)aVector
{
    return [NSString stringWithCString:glm::to_string(aVector).c_str() encoding:[NSString defaultCStringEncoding]];
}

bool operator==(const glm::vec3 &vecA, const glm::vec3 &vecB)
{
    const float epsilion = 0.0001;
    return  fabsf(vecA.x - vecB.x) < epsilion &&
    fabsf(vecA.y - vecB.y) < epsilion &&
    fabsf(vecA.z - vecB.z) < epsilion;
    
}

- (void)setUp
{
    [super setUp];
    NSLog(@"%@ setUp", self.name);
    camera = [[JJCamera alloc] initWithParameters:1.0f farClipping:50.0f FoV:50.0f aspectRatio:1.0f cameraRadius:0.5f];
    STAssertNotNil(camera, @"Cannot create JJCamera instance");
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

- (void)testGeoToCartesianCoords
{
    NSLog(@"%@ start", self.name);
    
    glm::vec3 cartesianAssumed(-0.5f, 0.0f, 0.0f);
    glm::vec3 cartesianConverted = [camera convertGeoToCartesian:0.5f longtitude:0.0f latitude:0.0f];
    NSString* assumed = [self vec3toNSString:cartesianAssumed];
    NSString* converted = [self vec3toNSString:cartesianConverted];
    
    STAssertTrue(cartesianAssumed == cartesianConverted, @"but instead was %@ and %@", assumed, converted);
    
    cartesianAssumed = glm::vec3(0.0f, 0.0f, 0.5f);
    cartesianConverted = [camera convertGeoToCartesian:0.5f longtitude:90.0f latitude:0.0f];
    assumed = [self vec3toNSString:cartesianAssumed];
    converted = [self vec3toNSString:cartesianConverted];
    
    STAssertTrue(cartesianAssumed == cartesianConverted, @"but instead was %@ and %@", assumed, converted);
    
    cartesianAssumed = glm::vec3(0.0f, 0.0f, -0.5f);
    cartesianConverted = [camera convertGeoToCartesian:0.5f longtitude:-90.0f latitude:0.0f];
    assumed = [self vec3toNSString:cartesianAssumed];
    converted = [self vec3toNSString:cartesianConverted];
    
    STAssertTrue(cartesianAssumed == cartesianConverted, @"but instead was %@ and %@", assumed, converted);
    cartesianAssumed = glm::vec3(0.5f, 0.0f, 0.0f);
    cartesianConverted = [camera convertGeoToCartesian:0.5f longtitude:180.0f latitude:0.0f];
    assumed = [self vec3toNSString:cartesianAssumed];
    converted = [self vec3toNSString:cartesianConverted];
    
    STAssertTrue(cartesianAssumed == cartesianConverted, @"but instead was %@ and %@", assumed, converted);
    
    cartesianAssumed = glm::vec3(0.0f, 0.5f, 0.0f);
    cartesianConverted = [camera convertGeoToCartesian:0.5f longtitude:0.0f latitude:90.0f];
    assumed = [self vec3toNSString:cartesianAssumed];
    converted = [self vec3toNSString:cartesianConverted];
    
    STAssertTrue(cartesianAssumed == cartesianConverted, @"but instead was %@ and %@", assumed, converted);
    
    cartesianAssumed = glm::vec3(0.0f, 0.5*0.707106f, 0.5*0.707106f);
    cartesianConverted = [camera convertGeoToCartesian:0.5f longtitude:90.0f latitude:45.0f];
    assumed = [self vec3toNSString:cartesianAssumed];
    converted = [self vec3toNSString:cartesianConverted];
    
    STAssertTrue(cartesianAssumed == cartesianConverted, @"but instead was %@ and %@", assumed, converted);
    
    cartesianAssumed = [camera convertGeoToCartesian:0.5f longtitude:-90.0f latitude:45.0f];
    cartesianConverted = [camera convertGeoToCartesian:0.5f longtitude:270.0f latitude:45.0f];
    assumed = [self vec3toNSString:cartesianAssumed];
    converted = [self vec3toNSString:cartesianConverted];
    
    STAssertTrue(cartesianAssumed == cartesianConverted, @"but instead was %@ and %@", assumed, converted);
    
    cartesianAssumed = [camera convertGeoToCartesian:0.5f longtitude:-90.0f latitude:135.0f];
    cartesianConverted = [camera convertGeoToCartesian:0.5f longtitude:90.0f latitude:45.0f];
    assumed = [self vec3toNSString:cartesianAssumed];
    converted = [self vec3toNSString:cartesianConverted];
    
    STAssertTrue(cartesianAssumed == cartesianConverted, @"but instead was %@ and %@", assumed, converted);
    
    NSLog(@"%@ end", self.name);
}

- (void)testForwardVectorCalculation
{
    
    NSLog(@"%@ start", self.name);
    
    glm::vec3 forwardVectorAssumed = camera.maxForwardDistance * glm::vec3(0.0f, 0.0f, -1.0f);
    glm::vec3 forwardVectorCalculated = [camera calculateForwardVectorWithLongtitude:90.0f];
    NSString* assumed = [self vec3toNSString:forwardVectorAssumed];
    NSString* calculated = [self vec3toNSString:forwardVectorCalculated];
    
    STAssertTrue(forwardVectorAssumed == forwardVectorCalculated, @"but instead was %@ and %@", assumed, calculated);
    
    NSLog(@"%@ end", self.name);
}

- (void)testSetCameraWithCharacterPosition
{
    NSLog(@"%@ start", self.name);
    
    /* -- 1ST TEST -- */
    
    glm::vec3 characterPosition = glm::vec3(0.5f, 0.5f, 0.5f);
    camera.longtitude = 90.0f;
    camera.latitude = 0.0f;
    
    [camera setWithCharacterPosition:characterPosition];
    
    glm::vec3 assumedCameraPosition = glm::vec3(0.5f, 0.5, 1.0f);
    glm::vec3 assumedLookAtVector = glm::vec3(0.0f, 0.0f, -1.0f);
    glm::vec3 assumedUpVector = glm::vec3(0.0f, 1.0f, 0.0f);
    
    NSString* calculatedPosition = [self vec3toNSString:camera.cameraPosition];
    NSString* calculatedLookAt = [self vec3toNSString:camera.target];
    NSString* calculatedUp = [self vec3toNSString:camera.up];
    
    NSString* assumedPosition = [self vec3toNSString:assumedCameraPosition];
    NSString* assumedLookAt = [self vec3toNSString:assumedLookAtVector];
    NSString* assumedUp = [self vec3toNSString:assumedUpVector];
    
    STAssertTrue(assumedCameraPosition == camera.cameraPosition, @"but instead was %@ and %@", assumedPosition, calculatedPosition);
    STAssertTrue(assumedLookAtVector == camera.target, @"but instead was %@ and %@", assumedLookAt, calculatedLookAt);
    STAssertTrue(assumedUpVector == camera.up, @"but instead was %@ and %@", assumedUp, calculatedUp);
    
    /* -- 2ND TEST -- */
    
    characterPosition = glm::vec3(10.0f, 10.0f, 10.0f);
    camera.longtitude = 135.0f;
    camera.latitude = 45.0f;
    
    [camera setWithCharacterPosition:characterPosition];
    
    assumedCameraPosition = glm::vec3(10.25f, 10.35355339f, 10.25f);
    assumedLookAtVector = glm::vec3(-0.578708, -0.574625, -0.578708);
    assumedUpVector = glm::vec3(-0.33254f, 0.669806f, -0.33254f);
    
    calculatedPosition = [self vec3toNSString:camera.cameraPosition];
    calculatedLookAt = [self vec3toNSString:camera.target];
    calculatedUp = [self vec3toNSString:camera.up];
    
    assumedPosition = [self vec3toNSString:assumedCameraPosition];
    assumedLookAt = [self vec3toNSString:assumedLookAtVector];
    assumedUp = [self vec3toNSString:assumedUpVector];
    
    STAssertTrue(assumedCameraPosition == camera.cameraPosition, @"but instead was %@ and %@", assumedPosition, calculatedPosition);
    STAssertTrue(assumedLookAtVector == camera.target, @"but instead was %@ and %@", assumedLookAt, calculatedLookAt);
    STAssertTrue(assumedUpVector == camera.up, @"but instead was %@ and %@", assumedUp, calculatedUp);
    
    NSLog(@"%@ end", self.name);
}

-(void)testCartesianToGeoCoords
{
    NSLog(@"%@ start", self.name);
    
    /* -- 1ST TEST -- */
    glm::vec3 cartesian = glm::vec3(1.0f, 0.0f, 0.0f);
    glm::vec3 geo = [camera convertCartesianToGeo:cartesian];
    glm::vec3 backToCartesian = [camera convertGeoToCartesian:geo.x longtitude:geo.y latitude:geo.z];
    
    NSString* cartesianString = [self vec3toNSString:cartesian];
    NSString* backToCartesianString = [self vec3toNSString:backToCartesian];
    
    STAssertTrue(backToCartesian == cartesian, @"but instead after conversion we have %@ and is %@", backToCartesianString, cartesianString);
    
    /* -- 2ND TEST -- */
    cartesian = glm::vec3(-1.0f, 0.0f, -1.0f);
    geo = [camera convertCartesianToGeo:cartesian];
    NSLog(@"%@", [self vec3toNSString:geo]);
    backToCartesian = [camera convertGeoToCartesian:geo.x longtitude:geo.y latitude:geo.z];
    NSLog(@"%@", [self vec3toNSString:backToCartesian]);
    
    
    cartesianString = [self vec3toNSString:cartesian];
    backToCartesianString = [self vec3toNSString:backToCartesian];
    
    STAssertTrue(backToCartesian == cartesian, @"but instead after conversion we have %@ and is %@", backToCartesianString, cartesianString);
    
    /* -- 3RD TEST -- */
    cartesian = glm::vec3(1.0f, 0.0f, -1.0f);
    geo = [camera convertCartesianToGeo:cartesian];
    NSLog(@"%@", [self vec3toNSString:geo]);
    backToCartesian = [camera convertGeoToCartesian:geo.x longtitude:geo.y latitude:geo.z];
    NSLog(@"%@", [self vec3toNSString:backToCartesian]);
    
    cartesianString = [self vec3toNSString:cartesian];
    backToCartesianString = [self vec3toNSString:backToCartesian];
    
    STAssertTrue(backToCartesian == cartesian, @"but instead after conversion we have %@ and is %@", backToCartesianString, cartesianString);
    
    /* -- 4TH TEST -- */
    cartesian = glm::vec3(1.34234f, 5.0f, -1.23424f);
    geo = [camera convertCartesianToGeo:cartesian];
    NSLog(@"%@", [self vec3toNSString:geo]);
    backToCartesian = [camera convertGeoToCartesian:geo.x longtitude:geo.y latitude:geo.z];
    NSLog(@"%@", [self vec3toNSString:backToCartesian]);
    
    cartesianString = [self vec3toNSString:cartesian];
    backToCartesianString = [self vec3toNSString:backToCartesian];
    
    STAssertTrue(backToCartesian == cartesian, @"but instead after conversion we have %@ and is %@", backToCartesianString, cartesianString);
}

@end
