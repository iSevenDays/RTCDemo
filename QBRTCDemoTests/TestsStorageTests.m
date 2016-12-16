//
//  TestStorageTests.m
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11/19/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SVUser.h"
#import "QBUUser+SVUser.h"

@interface TestStorageTests : XCTestCase

@end

@implementation TestStorageTests


- (void)testCorrectInit {
	QBUUser *qbuser = [TestsStorage qbuserTest];
	
	SVUser *svuser = [TestsStorage svuserTest];

	XCTAssertNotNil(qbuser);
	XCTAssertEqual(qbuser.login, @"testlogin");
	XCTAssertEqual(qbuser.password, @"testpass");
	XCTAssertEqual(qbuser.ID, 777);
	
	XCTAssertNotNil(svuser);
	XCTAssertEqual(svuser.login, @"svlogin");
	XCTAssertEqual(svuser.password, @"svpass");
	XCTAssertEqualObjects(svuser.ID, @(123));
}

- (void)testCorrectChangingPropertiesOfQBUUser {
	QBUUser *qbuser = [TestsStorage qbuserTest];
	
	qbuser.login = @"testlogin2%cerm23er34r";
	qbuser.password = @"testrpgmr3497^F%ST*G&YFIU";
	qbuser.ID = 12943050;
	
	XCTAssertEqual(qbuser.login, @"testlogin2%cerm23er34r");
	XCTAssertEqual(qbuser.password, @"testrpgmr3497^F%ST*G&YFIU");
	XCTAssertEqual(qbuser.ID, 12943050);
}

- (void)testCorrectChangingPropertiesOfSVUser {
	SVUser *svuser = [TestsStorage svuserTest];
	
	NSString *login = @"svg4h7580gijr9aeov[SVM";
	NSString *password = @"svdrhugijno43487gAYCHOU*IJ__";
	NSString *fullName = @"full_name_test";
	
	svuser.login = login;
	svuser.password = password;
	svuser.fullName = fullName;
	svuser.ID = @(4785909);
	
	XCTAssertNotNil(svuser);
	XCTAssertEqual(svuser.login, login);
	XCTAssertEqual(svuser.password, password);
	XCTAssertEqualObjects(svuser.ID, @(4785909));
}

- (void)testStorageAreAlwaysInitialized {
	XCTAssertNotNil([TestsStorage svuserTest]);
	XCTAssertNotNil([TestsStorage qbuserTest]);
}


@end
