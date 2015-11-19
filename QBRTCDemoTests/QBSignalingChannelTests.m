//
//  QBSignalingChannelTests.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/19/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrest/OCHamcrest.h>

#import "SVUser.h"
#import "QBSignalingChannel.h"
#import "TestsStorage.h"

@interface QBSignalingChannel_Tests : XCTestCase

@property (nonatomic, strong) QBSignalingChannel *signalingChannel;

@end

@implementation QBSignalingChannel_Tests

- (void)setUp {
	[QBSettings setApplicationID:31016];
	[QBSettings setAuthKey:@"aqsHa2AhDO5Z9Th"];
	[QBSettings setAuthSecret:@"825Bv-3ByACjD4O"];
	[QBSettings setAccountKey:@"ZsFuaKozyNC3yLzvN3Xa"];
	
	self.signalingChannel = [[QBSignalingChannel alloc] init];
	
	[QBChat instance] set;
}

- (void)tearDown {
	self.signalingChannel = nil;
}

- (void)testCanConnectWithUser1 {
	
	SVUser *testUser = [TestsStorage svuserRealUser1];
	__block SVUser *signalingUser = nil;
	
	__block NSError *connectionError = nil;
	[self.signalingChannel connectWithUser:testUser completion:^(NSError * _Nullable error) {
		connectionError = error;
		signalingUser = self.signalingChannel.user;
	}];
	
	assertWithTimeout(10, thatEventually(connectionError), nilValue());
	assertWithTimeout(10, thatEventually(self.signalingChannel.user), notNilValue());
	assertWithTimeout(10, thatEventually(testUser), equalTo(self.signalingChannel.user));
}

@end