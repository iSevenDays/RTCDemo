//
//  CallServiceTests.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 2/9/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import "BaseTestCase.h"
#import <OCMock.h>
#import <RTCICECandidate.h>

#import "CallService.h"
#import "CallService_Private.h"
#import "CallServiceHelpers.h"

#import "CallClientDelegate.h"
#import "FakeSignalingChannel.h"

#import "SVSignalingMessage.h"
#import "SVSignalingMessageSDP.h"
#import "SVSignalingMessageICE.h"
#import "SVSignalingParams.h"

@interface CallServiceTests : BaseTestCase

@property (nonatomic, strong) CallService<SVSignalingChannelDelegate> *callService;
@property (nonatomic, strong) id mockOutput;
@property (nonatomic, strong) id mockCallService;

@property (nonatomic, strong) SVUser *user1;
@property (nonatomic, strong) SVUser *user2;
@property (nonatomic, strong) SVUser *user3;

@end

@implementation CallServiceTests


- (void)setUp {
	[super setUp];
	self.user1 = [CallServiceHelpers user1];
	self.user2 = [CallServiceHelpers user2];
	self.user3 = [[SVUser alloc] initWithID:@1 login:@"login" password:@""];
	
	self.mockOutput = OCMProtocolMock(@protocol(CallClientDelegate));
	
	self.callService = [[CallService alloc] initWithSignalingChannel:[FakeSignalingChannel new] clientDelegate:self.mockOutput];
	
	self.mockCallService = OCMPartialMock(self.callService);
}

- (void)tearDown {
	[self.callService hangup];
	self.mockCallService = nil;
	self.mockOutput = nil;
}

- (void)testCanConnectWithUserAndHaveConnectState {
	// given
	XCTestExpectation *expectation = [self currentSelectorTestExpectation];
	// when
	[self.callService connectWithUser:self.user1 completion:^(NSError * _Nullable error) {
		XCTAssertNil(error);
		XCTAssertEqual(self.callService.state, kClientStateConnected);
		[expectation fulfill];
	}];
	
	// then
	[self waitForTestExpectations];
}

#pragma mark CallClientDelegate tests

- (void)testHasLocalVideoTrackAfterStartCall {
	// given
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	
	[self.callService startCallWithOpponent:self.user2];

	// then
	OCMVerify([self.mockOutput client:[OCMArg any] didReceiveLocalVideoTrack:[OCMArg any]]);
}

- (void)testCorrectlyChangesClientStateToConnected {
	// given
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	
	// then
	OCMVerify([self.mockOutput client:[OCMArg any] didChangeState:kClientStateConnected]);
}

- (void)testCorrectlyChangesClientStateToDisconnectedAfterHangup {
	// given
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	[self.callService hangup];

	// then
	OCMVerify([self.mockOutput client:[OCMArg any] didChangeState:kClientStateDisconnected]);
}

- (void)testSendsRejectIfAlreadyHasActiveCall {
	// given
	
	SVSignalingMessage *offer = [[SVSignalingMessageSDP alloc] initWithType:SVSignalingMessageType.offer params:@{SVSignalingParams.sdp : @""}];
	offer.sender = self.user3;
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	[self.callService startCallWithOpponent:self.user2];
	
	[self.callService channel:self.callService.signalingChannel didReceiveMessage:offer];
	
	// then
	OCMVerify([self.mockCallService sendRejectToUser:self.user3 completion:[OCMArg any]]);
}

#pragma mark Signaling messages processing

- (void)testCorrectlyProcessesHangupSignalingMessage {
	// given
	SVSignalingMessage *hangup = [SVSignalingMessage messageWithType:SVSignalingMessageType.hangup params:nil];
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	[self.callService startCallWithOpponent:self.user2];
	
	[self.callService processSignalingMessage:hangup];
	
	// then
	OCMVerify([self.mockCallService clearSession]);
}

@end