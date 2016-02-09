//
//  CallServiceHelpers.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 2/9/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import "CallServiceHelpers.h"
#import "SVUser.h"

@implementation CallServiceHelpers

// prod
//		self.user1 = [[SVUser alloc] initWithID:@(8662991) login:@"rtcuser1" password:@"rtcuser1"];
//		self.user2 = [[SVUser alloc] initWithID:@(8663016 login:@"rtcuser2" password:@"rtcuser2"];


+ (SVUser *)user1 {
	return [[SVUser alloc] initWithID:@(6942802) login:@"rtcuser1" password:@"rtcuser1"];
}

+ (SVUser *)user2 {
	return [[SVUser alloc] initWithID:@(6942819) login:@"rtcuser2" password:@"rtcuser2"];
}

@end
