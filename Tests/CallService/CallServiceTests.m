//
//  CallServiceTests.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 2/9/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import "BaseTestCase.h"
#import <OCMock.h>

#import "CallService.h"
#import "CallService_Private.h"
#import "CallServiceHelpers.h"

#import "CallClientDelegate.h"
#import "FakeSignalingChannel.h"

#import "SVSignalingMessage.h"
#import "SVSignalingMessageSDP.h"
#import "SVSignalingMessageICE.h"

@interface CallServiceTests : BaseTestCase

@property (nonatomic, strong) CallService *callService;
@property (nonatomic, strong) id mockOutput;

@property (nonatomic, strong) SVUser *user1;
@property (nonatomic, strong) SVUser *user2;

@end

@implementation CallServiceTests


- (void)setUp {
	[super setUp];
	self.user1 = [CallServiceHelpers user1];
	self.user2 = [CallServiceHelpers user2];
	
	self.mockOutput = OCMProtocolMock(@protocol(CallClientDelegate));
	
	self.callService = [[CallService alloc] initWithSignalingChannel:[FakeSignalingChannel new] clientDelegate:self.mockOutput];
}

- (void)tearDown {
	[self.callService hangup];
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

#pragma mark Signaling messages processing

- (void)testCorrectlyProcessesHangupSignalingMessage {
	// given
	SVSignalingMessage *hangup = [SVSignalingMessage messageWithType:SVSignalingMessageType.hangup params:nil];
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	[self.callService startCallWithOpponent:self.user2];
	
	[self.callService processSignalingMessage:hangup];
	
	// then
	OCMVerify([self.callService clearSession]);
}

@end