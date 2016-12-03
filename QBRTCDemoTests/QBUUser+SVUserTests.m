//
//  QBUUser_SVUserTests.m
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11/18/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SVUser.h"
#import "QBUUser+SVUser.h"

@interface QBUUser_SVUserTests : XCTestCase

@property (nonatomic, strong, nullable) QBUUser *qbuser;
@property (nonatomic, strong, nullable) SVUser *svuser;

@end

@implementation QBUUser_SVUserTests

- (void)setUp {
	self.qbuser = [QBUUser user];
	self.qbuser.login = @"testlogin";
	self.qbuser.ID = 777;
	self.qbuser.password = @"testpass";
	
	self.svuser = [[SVUser alloc] initWithID:@(123) login:@"svlogin" password:@"svpass"];
}

- (void)tearDown {
	self.qbuser = nil;
	self.svuser = nil;
}

- (void)testQBUUserCorrectlyInitWithSVUser {
	QBUUser *user = [QBUUser userWithSVUser:self.svuser];
	
	XCTAssertEqual(user.ID, self.svuser.ID.unsignedIntegerValue);
	XCTAssertEqual(user.login, self.svuser.login);
	XCTAssertEqual(user.password, self.svuser.password);
}

- (void)testSVUserCorrectlyInit {
	SVUser *user = [SVUser userWithID:@(self.qbuser.ID) login:self.qbuser.login password:self.qbuser.password];
	
	XCTAssertEqual(user.ID.unsignedIntegerValue, self.qbuser.ID);
	XCTAssertEqual(user.login, self.qbuser.login);
	XCTAssertEqual(user.password, self.qbuser.password);
}

@end
