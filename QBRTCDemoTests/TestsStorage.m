//
//  TestsStorage.m
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11/19/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "TestsStorage.h"

@implementation TestsStorage

static QBUUser *qbuser = nil;
static SVUser *svuser = nil;

+ (SVUser *)svuserRealUser1 {
	return [[SVUser alloc] initWithID:@(6942802) login:@"UUID_CUSTOM" fullName:@"rtcuser1_fullname" password:@"rtcuser1" tags:@[@"tag1"]];
}

+ (SVUser *)svuserRealUser2 {
	return [[SVUser alloc] initWithID:@(6942802) login:@"UUID_CUSTOM2" fullName:@"rtcuser2_fullname" password:@"rtcuser2" tags:@[@"tag2"]];
}

+ (QBUUser *)qbuserTest {
	
	QBUUser *qbuser = [QBUUser user];
	qbuser.login = @"testlogin";
	qbuser.ID = 777;
	qbuser.password = @"testpass";
	qbuser.fullName = @"full_name";
	qbuser.tags = [@[@"tag"] mutableCopy];
	
	return qbuser;
}

+ (SVUser *)svuserTest {
	return [[SVUser alloc] initWithID:@(123) login:@"svlogin" fullName:@"full_name_sv" password:@"svpass" tags:@[@"svtag"]];
}

@end
