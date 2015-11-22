//
//  SVUserTests.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/21/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrest/OCHamcrest.h>

#import "SVUser.h"
#import "TestsStorage.h"

@interface SVUserTests : XCTestCase

@end


@implementation SVUserTests

- (void)testThatIsEqualMethodCorrectlyComparesDifferentObjects {
	SVUser *testUser = [TestsStorage svuserTest];
	
	SVUser *notEqualUser = [SVUser userWithID:@(13) login:@"nologin" password:@"somepass"];
	
	assertThat(testUser, isNot(equalTo(notEqualUser)));
}

- (void)testThatIsEqualMethodCorrectlyComparesEqualObjects {
	SVUser *testUser = [TestsStorage svuserTest];
	
	SVUser *equalUser = [SVUser userWithID:testUser.ID login:testUser.login password:testUser.password];
	
	assertThat(testUser, equalTo(equalUser));
}

@end