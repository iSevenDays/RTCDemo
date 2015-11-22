//
//  QBSignalingChannelTests.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/19/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrest/OCHamcrest.h>
#import <OCMock/OCMock.h>

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
	
	__block NSError *connectionError = nil;
	[signalingChannel connectWithUser:testUser completion:^(NSError * _Nullable error) {
		connectionError = error;
		signalingUser = signalingChannel.user;
	}];
	
	assertWithTimeout(10, thatEventually(connectionError), nilValue());
	assertWithTimeout(10, thatEventually(signalingChannel.user), notNilValue());
	assertWithTimeout(10, thatEventually(testUser), equalTo(signalingChannel.user));	
}

- (void)testCorrectlyChangeState_Simulate {
	QBSignalingChannel *signalingChannel = [[QBSignalingChannel alloc] init];
	
	QBSignalingChannel *mockSignalingChannel = OCMPartialMock(signalingChannel);
	
	id<SVSignalingChannelDelegate> mockDelegate = OCMProtocolMock(@protocol(SVSignalingChannelDelegate));
	mockSignalingChannel.delegate = mockDelegate;
	
	
	OCMStub([mockSignalingChannel connectWithUser:OCMOCK_ANY completion:nil]).andDo(^(NSInvocation *invocation){
		mockSignalingChannel.state = SVSignalingChannelState.established;
	});
	
	[mockSignalingChannel connectWithUser:[TestsStorage svuserRealUser1] completion:nil];
	
	
	OCMVerify([mockDelegate channel:signalingChannel didChangeState:SVSignalingChannelState.established]);
}

@end