//
//  SVUserTests.m
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11/21/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SVUser.h"
#import "TestsStorage.h"
#import "NSObject+Testing.h"

@interface SVUserTests : XCTestCase

@end


@implementation SVUserTests

- (void)testThatIsEqualMethodCorrectlyComparesDifferentObjects {
	SVUser *testUser = [TestsStorage svuserTest];
	
	SVUser *notEqualUser = [SVUser userWithID:@(13) login:@"nologin" password:@"somepass"];
	
	XCTAssertNotEqual(testUser, notEqualUser);
}

- (void)testThatIsEqualMethodCorrectlyComparesEqualObjects {
	SVUser *testUser = [TestsStorage svuserTest];
	
	SVUser *equalUser = [[SVUser alloc] initWithID:testUser.ID login:testUser.login fullName:@"full_name" password:testUser.password tags:@[@"svtag"]];
	
	XCTAssertEqualObjects(testUser, equalUser);
}

- (void)testSVUserSupportsNSCoding {
	SVUser *testUser = [TestsStorage svuserTest];
	[testUser compareWithSelfClonedObject];
}

- (void)testSVUserSupportsNSCopying {
	SVUser *testUser = [TestsStorage svuserTest];
	[testUser compareWithSelfCopiedObject];
}

@end
