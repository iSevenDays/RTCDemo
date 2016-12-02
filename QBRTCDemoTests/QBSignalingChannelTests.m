//
//  QBSignalingChannelTests.m
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11/19/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SVUser.h"
#import "QBSignalingChannel.h"
#import "TestsStorage.h"

@interface QBSignalingChannel_Tests : XCTestCase


@end

@implementation QBSignalingChannel_Tests

- (void)setUp {
	[QBSettings setApplicationID:31016];
	[QBSettings setAuthKey:@"aqsHa2AhDO5Z9Th"];
	[QBSettings setAuthSecret:@"825Bv-3ByACjD4O"];
	[QBSettings setAccountKey:@"ZsFuaKozyNC3yLzvN3Xa"];
}

- (void)DISABLED_testCorrectlyConnectWithUser1_Real {
	QBSignalingChannel *signalingChannel = [[QBSignalingChannel alloc] init];
	
	SVUser *testUser = [TestsStorage svuserRealUser1];
	__block SVUser *signalingUser = nil;
	
	XCTestExpectation *expecatationConnectWithUserBlock = [[XCTestExpectation alloc] init];
	
	__block NSError *connectionError = nil;
	[signalingChannel connectWithUser:testUser completion:^(NSError * _Nullable error) {
		connectionError = error;
		signalingUser = signalingChannel.user;
		[expecatationConnectWithUserBlock fulfill];
	}];
	
	[self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
		XCTAssertNil(error);
		XCTAssertNil(connectionError);
		XCTAssertNotNil(signalingChannel.user);
		XCTAssertEqual(testUser, signalingChannel.user);
	}];
}

@end
