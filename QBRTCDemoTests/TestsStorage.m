//
//  TestsStorage.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/19/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "TestsStorage.h"

@implementation TestsStorage

static QBUUser *qbuser = nil;
static SVUser *svuser = nil;

+ (SVUser *)svuserRealUser1 {
	return [[SVUser alloc] initWithID:@(6942802) login:@"rtcuser1" password:@"rtcuser1"];
}

+ (SVUser *)svuserRealUser2 {
	return [[SVUser alloc] initWithID:@(6942819) login:@"rtcuser2" password:@"rtcuser2"];
}

+ (QBUUser *)qbuserTest {
	return qbuser;
}

+ (SVUser *)svuserTest {
	return svuser;
}

+ (void)init {
	qbuser = [QBUUser user];
	qbuser.login = @"testlogin";
	qbuser.ID = 777;
	qbuser.password = @"testpass";
	
	svuser = [[SVUser alloc] initWithID:@(123) login:@"svlogin" password:@"svpass"];
}

+ (void)reset {
	if(!qbuser){
		qbuser = [QBUUser user];
	}
	qbuser.login = @"testlogin";
	qbuser.ID = 777;
	qbuser.password = @"testpass";
	
	if (!svuser) {
		svuser = [[SVUser alloc] init];
	}
	svuser.ID = @(123);
	svuser.login = @"svlogin";
	svuser.password = @"svpass";
}

@end
