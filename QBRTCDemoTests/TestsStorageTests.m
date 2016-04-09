//
//  TestStorageTests.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/19/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrest/OCHamcrest.h>

#import "SVUser.h"
#import "QBUUser+SVUser.h"
#import "TestsStorage.h"

@interface TestStorageTests : XCTestCase

@end

@implementation TestStorageTests


- (void)testCorrectInit {
	QBUUser *qbuser = [TestsStorage qbuserTest];
	
	SVUser *svuser = [TestsStorage svuserTest];

	assertThat(qbuser, notNilValue());
	
	assertThat(qbuser.login, equalTo(@"testlogin"));
	assertThat(qbuser.password, equalTo(@"testpass"));
	assertThat(@(qbuser.ID), equalTo(@(777)));
	
	assertThat(svuser, notNilValue());
	assertThat(svuser.login, equalTo(@"svlogin"));
	assertThat(svuser.password, equalTo(@"svpass"));
	assertThat(svuser.ID, equalTo(@(123)));
}

- (void)testCorrectChangingPropertiesOfQBUUser {
	QBUUser *qbuser = [TestsStorage qbuserTest];
	
	qbuser.login = @"testlogin2%cerm23er34r";
	qbuser.password = @"testrpgmr3497^F%ST*G&YFIU";
	qbuser.ID = 12943050;
	
	assertThat(qbuser.login, equalTo(@"testlogin2%cerm23er34r"));
	assertThat(qbuser.password, equalTo(@"testrpgmr3497^F%ST*G&YFIU"));
	assertThat(@(qbuser.ID), equalTo(@(12943050)));
	
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
	
	assertThat(svuser, notNilValue());
	assertThat(svuser.login, equalTo(login));
	assertThat(svuser.password, equalTo(password));
	assertThat(svuser.fullName, equalTo(fullName));
	
	assertThat(svuser.ID, equalTo(@(4785909)));
}

- (void)testStorageAreAlwaysInitialized {
	assertThat([TestsStorage svuserTest], notNilValue());
	assertThat([TestsStorage qbuserTest], notNilValue());
}


@end